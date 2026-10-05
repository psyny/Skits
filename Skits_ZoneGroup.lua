-- Skits_ZoneGroup.lua

-- Builds a compact lookup from Skits_ZoneGroup_Defs:
--     groupsByIdx[idx]            = group name
--     groupIdxByName[name]        = idx
--     groupIdxByZoneId[uiMapID]   = idx  (ranges are expanded into direct entries)
-- Indices are 1-based (0 is left free for a future "global" group) and follow the alphabetical order
-- of group names, so they are only stable while the defs don't change. Don't persist them.

Skits_ZoneGroup = {}
Skits_ZoneGroup.groupsByIdx = {}
Skits_ZoneGroup.groupIdxByName = {}
Skits_ZoneGroup.groupIdxByZoneId = {}
Skits_ZoneGroup.zoneIdQty = 0

-- uiMapID -> { idx = <group idx>, matchedId = <uiMapID that had the group> } or false (no group). The map
-- tree doesn't change during a session, so this never needs to be invalidated.
local resolvedCache = {}

-- uiMapID -> ordered list of storage keys (see GetZoneKeyChain)
local keyChainCache = {}

local MAX_RANGE_SIZE = 10000
local MAX_CHAIN_DEPTH = 20

-- Enum.UIMapType values
local UI_MAP_TYPE_COSMIC = 0
local UI_MAP_TYPE_WORLD = 1
local UI_MAP_TYPE_MICRO = 5

Skits_ZoneGroup.GLOBAL_KEY = "global"
local GLOBAL_ONLY_CHAIN = { Skits_ZoneGroup.GLOBAL_KEY }

-- ------------------------------------
-- Build

function Skits_ZoneGroup:Initialize()
    self.groupsByIdx = {}
    self.groupIdxByName = {}
    self.groupIdxByZoneId = {}
    self.zoneIdQty = 0
    resolvedCache = {}
    keyChainCache = {}

    local defs = Skits_ZoneGroup_Defs or {}

    -- Deterministic indices
    local names = {}
    for groupName, _ in pairs(defs) do
        table.insert(names, groupName)
    end
    table.sort(names)

    for idx, groupName in ipairs(names) do
        self.groupsByIdx[idx] = groupName
        self.groupIdxByName[groupName] = idx
    end

    -- Split definitions into ranges and explicit ids
    local ranges = {}
    local explicits = {}
    for idx, groupName in ipairs(names) do
        for _, ele in ipairs(defs[groupName]) do
            if type(ele) == "table" then
                local from, to = ele[1], ele[2]
                if from and to then
                    if from > to then
                        from, to = to, from
                    end
                    if to - from + 1 > MAX_RANGE_SIZE then
                        print("[Skits] Zone group '" .. groupName .. "': range " .. from .. "-" .. to .. " is too large, ignored")
                    else
                        table.insert(ranges, { from = from, to = to, idx = idx })
                    end
                end
            elseif type(ele) == "number" then
                table.insert(explicits, { id = ele, idx = idx })
            end
        end
    end

    -- Wider ranges first, so narrower ranges overwrite them
    table.sort(ranges, function(a, b)
        return (a.to - a.from) > (b.to - b.from)
    end)
    for _, range in ipairs(ranges) do
        for id = range.from, range.to do
            self.groupIdxByZoneId[id] = range.idx
        end
    end

    -- Explicit ids beat ranges
    local explicitOwner = {}
    for _, explicit in ipairs(explicits) do
        local ownerIdx = explicitOwner[explicit.id]
        if ownerIdx and ownerIdx ~= explicit.idx then
            print("[Skits] uiMapID " .. explicit.id .. " is defined in zone groups '" .. self.groupsByIdx[ownerIdx] .. "' and '" .. self.groupsByIdx[explicit.idx] .. "', using the first")
        else
            explicitOwner[explicit.id] = explicit.idx
            self.groupIdxByZoneId[explicit.id] = explicit.idx
        end
    end

    for _, _ in pairs(self.groupIdxByZoneId) do
        self.zoneIdQty = self.zoneIdQty + 1
    end
end

-- ------------------------------------
-- Lookup

function Skits_ZoneGroup:GetGroupNameByIdx(groupIdx)
    return self.groupsByIdx[groupIdx]
end

function Skits_ZoneGroup:GetGroupIdxByName(groupName)
    return self.groupIdxByName[groupName]
end

-- Direct lookup only, no parent fallback
function Skits_ZoneGroup:GetZoneGroupIdxForUiMapId(uiMapId)
    return self.groupIdxByZoneId[uiMapId]
end

-- Returns: groupName, groupIdx, matchedUiMapId (the map in the parent chain that defined the group)
-- uiMapId defaults to the player's current map. Returns nil if no map in the chain has a group.
function Skits_ZoneGroup:GetZoneGroup(uiMapId)
    uiMapId = uiMapId or C_Map.GetBestMapForUnit("player")
    if not uiMapId then
        return nil
    end

    local resolved = resolvedCache[uiMapId]
    if resolved == nil then
        resolved = false

        local currId = uiMapId
        local depth = 0
        while currId and currId ~= 0 and depth < MAX_CHAIN_DEPTH do
            local groupIdx = self.groupIdxByZoneId[currId]
            if groupIdx then
                resolved = { idx = groupIdx, matchedId = currId }
                break
            end

            local mapInfo = C_Map.GetMapInfo(currId)
            if not mapInfo then
                break
            end
            currId = mapInfo.parentMapID
            depth = depth + 1
        end

        resolvedCache[uiMapId] = resolved
    end

    if not resolved then
        return nil
    end

    return self.groupsByIdx[resolved.idx], resolved.idx, resolved.matchedId
end

-- Storage keys for a map, most specific first, always ending with GLOBAL_KEY.
-- Walks the parent chain: a map with a group gives its group name, a map without one gives "map:<uiMapID>".
-- Micro, World and Cosmic maps without a group are skipped (too narrow / too broad to be useful).
-- Example: Dornogal -> { "TheWarWithin", "global" }, Elwynn Forest -> { "map:37", "map:13", "global" }
function Skits_ZoneGroup:GetZoneKeyChain(uiMapId)
    uiMapId = uiMapId or C_Map.GetBestMapForUnit("player")
    if not uiMapId then
        return GLOBAL_ONLY_CHAIN
    end

    local chain = keyChainCache[uiMapId]
    if chain then
        return chain
    end

    chain = {}
    local seen = {}
    local currId = uiMapId
    local depth = 0
    while currId and currId ~= 0 and depth < MAX_CHAIN_DEPTH do
        local mapInfo = C_Map.GetMapInfo(currId)

        local key = nil
        local groupIdx = self.groupIdxByZoneId[currId]
        if groupIdx then
            key = self.groupsByIdx[groupIdx]
        elseif mapInfo then
            local mapType = mapInfo.mapType
            if mapType ~= UI_MAP_TYPE_MICRO and mapType ~= UI_MAP_TYPE_WORLD and mapType ~= UI_MAP_TYPE_COSMIC then
                key = "map:" .. currId
            end
        end

        if key and not seen[key] then
            seen[key] = true
            table.insert(chain, key)
        end

        if not mapInfo then
            break
        end
        currId = mapInfo.parentMapID
        depth = depth + 1
    end

    table.insert(chain, self.GLOBAL_KEY)

    keyChainCache[uiMapId] = chain
    return chain
end

-- ------------------------------------
-- Init

Skits_ZoneGroup:Initialize()

-- ------------------------------------
-- Commands

-- Command to print the zone group of the current map
SLASH_SkitsZoneGroup1 = "/skitsZoneGroup"
SlashCmdList["SkitsZoneGroup"] = function()
    local uiMapId = C_Map.GetBestMapForUnit("player")

    print("[Zone Group]")
    if not uiMapId then
        print("No uiMapID for player")
        return
    end

    local mapInfo = C_Map.GetMapInfo(uiMapId)
    print("current map: " .. uiMapId .. " - " .. ((mapInfo and mapInfo.name) or "?"))

    local groupName, groupIdx, matchedId = Skits_ZoneGroup:GetZoneGroup(uiMapId)
    if not groupName then
        print("group: none")
    else
        local matchedInfo = C_Map.GetMapInfo(matchedId)
        print("group: " .. groupName .. " (idx " .. groupIdx .. ")")
        print("matched at: " .. matchedId .. " - " .. ((matchedInfo and matchedInfo.name) or "?"))
    end

    print("key chain: " .. table.concat(Skits_ZoneGroup:GetZoneKeyChain(uiMapId), " > "))

    print("loaded: " .. #Skits_ZoneGroup.groupsByIdx .. " groups, " .. Skits_ZoneGroup.zoneIdQty .. " uiMapIDs")
end
