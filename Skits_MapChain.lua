-- Skits_MapChain.lua

-- Storage keys for NPC data, built from the uiMapID tree (C_Map parentMapID):
--     <uiMapID>    data seen in that map
--     GLOBAL_KEY   data seen anywhere
-- A sighting is written to the exact map, its continent and GLOBAL_KEY (see GetWriteKeys).
-- Reading walks the exact map and all its parents, then GLOBAL_KEY (see GetReadKeys).
-- The map tree doesn't change during a session, so both are cached per uiMapID.

Skits_MapChain = {}

Skits_MapChain.GLOBAL_KEY = 0

local MAX_CHAIN_DEPTH = 20

-- Enum.UIMapType values
local UI_MAP_TYPE_CONTINENT = 2

local GLOBAL_ONLY_KEYS = { Skits_MapChain.GLOBAL_KEY }

-- uiMapID -> keys
local readKeysCache = {}
local writeKeysCache = {}

-- ------------------------------------
-- Keys

-- Keys to read for a map, most specific first: the map, each parent map, then GLOBAL_KEY.
-- Example: Dornogal micro map -> { <micro>, 2339 Dornogal, 2248 Isle of Dorn, 2274 Khaz Algar, 947 Azeroth, 946 Cosmic, 0 }
-- uiMapId defaults to the player's current map.
function Skits_MapChain:GetReadKeys(uiMapId)
    uiMapId = uiMapId or C_Map.GetBestMapForUnit("player")
    if not uiMapId or uiMapId == 0 then
        return GLOBAL_ONLY_KEYS
    end

    local keys = readKeysCache[uiMapId]
    if keys then
        return keys
    end

    keys = {}
    local currId = uiMapId
    local depth = 0
    while currId and currId ~= 0 and depth < MAX_CHAIN_DEPTH do
        table.insert(keys, currId)

        local mapInfo = C_Map.GetMapInfo(currId)
        if not mapInfo then
            break
        end
        currId = mapInfo.parentMapID
        depth = depth + 1
    end
    table.insert(keys, self.GLOBAL_KEY)

    readKeysCache[uiMapId] = keys
    return keys
end

-- Keys a sighting on a map is written to: the map itself, its continent (nearest continent in the
-- map and its parents), and GLOBAL_KEY. The keys in between are skipped to save memory.
-- Example: Dornogal micro map -> { <micro>, 2274 Khaz Algar, 0 }
-- uiMapId defaults to the player's current map.
function Skits_MapChain:GetWriteKeys(uiMapId)
    uiMapId = uiMapId or C_Map.GetBestMapForUnit("player")
    if not uiMapId or uiMapId == 0 then
        return GLOBAL_ONLY_KEYS
    end

    local keys = writeKeysCache[uiMapId]
    if keys then
        return keys
    end

    keys = { uiMapId }

    local currId = uiMapId
    local depth = 0
    while currId and currId ~= 0 and depth < MAX_CHAIN_DEPTH do
        local mapInfo = C_Map.GetMapInfo(currId)
        if not mapInfo then
            break
        end
        if mapInfo.mapType == UI_MAP_TYPE_CONTINENT then
            if currId ~= uiMapId then
                table.insert(keys, currId)
            end
            break
        end
        currId = mapInfo.parentMapID
        depth = depth + 1
    end
    table.insert(keys, self.GLOBAL_KEY)

    writeKeysCache[uiMapId] = keys
    return keys
end

-- ------------------------------------
-- Commands

-- Command to print the uiMapID chain (current map up to the root) and the storage keys
local UI_MAP_TYPE_NAMES = {
    [0] = "Cosmic",
    [1] = "World",
    [2] = "Continent",
    [3] = "Zone",
    [4] = "Dungeon",
    [5] = "Micro",
    [6] = "Orphan",
}

SLASH_SkitsMapChain1 = "/skitsMapChain"
SlashCmdList["SkitsMapChain"] = function()
    local uiMapId = C_Map.GetBestMapForUnit("player")

    print("[Map Chain]")
    if not uiMapId then
        print("No uiMapID for player")
        return
    end

    local currId = uiMapId
    local guard = 0
    while currId and currId ~= 0 and guard < MAX_CHAIN_DEPTH do
        local mapInfo = C_Map.GetMapInfo(currId)
        if not mapInfo then
            print("mapID: " .. currId .. " (no map info)")
            break
        end

        local typeName = UI_MAP_TYPE_NAMES[mapInfo.mapType] or "Unknown"
        print("mapID: " .. mapInfo.mapID)
        print("name: " .. (mapInfo.name or ""))
        print("type: " .. typeName .. " (" .. (mapInfo.mapType or "nil") .. ")")

        currId = mapInfo.parentMapID
        guard = guard + 1
    end

    print("read keys: " .. table.concat(Skits_MapChain:GetReadKeys(uiMapId), " > "))
    print("write keys: " .. table.concat(Skits_MapChain:GetWriteKeys(uiMapId), ", "))
end
