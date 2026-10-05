-- Skits_ID_Store.lua

Skits_ID_Store = {}
Skits_ID_Store.localDbIdxQueue = nil
Skits_ID_Store.localCacheIdxQueue = nil
Skits_ID_Store.localCache = nil
Skits_ID_Store.localPlayerCacheIdxQueue = nil
Skits_ID_Store.localPlayerCache = nil

local LOCAL_DB_MAX_SIZE = 20000
local LOCAL_CACHE_MAX_SIZE = 10000
local LOCAL_PLAYER_CACHE_MAX_SIZE = 1000

-- NPC stores (local DB and local cache) are zoned. Each record is:
--     { name = <npc name>, byKey = { [<zone key>] = { <ids> } } }
-- Zone keys come from Skits_ZoneGroup:GetZoneKeyChain (a group name, "map:<uiMapID>" or "global").
-- <ids> is a flat list: npcIds as positive numbers first, then displayIds as negative numbers.
-- Each kind holds at most MAX_IDS_PER_KIND ids.
--     Local DB: each kind sorted by id, descending (higher id = newer, our best guess).
--     Local cache: each kind ordered by most recently seen.
-- A sighting is written to the most specific key of the current map and to "global".
local ZONED_STORE_VERSION = 2
local MAX_IDS_PER_KIND = 3
local MAX_KEYS_PER_RECORD = 8

-- ------------------------------------------------------------------------------------------------------------

function Skits_ID_Store:Initialize()
    Skits_ID_Store:Locals_Start()

    -- Init our deque from DB
    Skits_ID_Store:GetLocalDbIdxQueueController():BuildDequeFromList(SkitsDB.creatureIdStore.creatureDataIdxQueue)
end

function Skits_ID_Store:PrepareDataForSave()
    Skits_ID_Store:Locals_Start()

    -- Creates an idx list from the deque
    SkitsDB.creatureIdStore.creatureDataIdxQueue = Skits_ID_Store:GetLocalDbIdxQueueController():CreateListFromDeque()
end

function Skits_ID_Store:GetLocalDbIdxQueueController()
    if Skits_ID_Store.localDbIdxQueue then
        return Skits_ID_Store.localDbIdxQueue
    end

    Skits_ID_Store.localDbIdxQueue = Skits_Deque:New()

    return Skits_ID_Store.localDbIdxQueue
end

function Skits_ID_Store:GetLocalCacheIdxQueueController()
    if Skits_ID_Store.localCacheIdxQueue then
        return Skits_ID_Store.localCacheIdxQueue
    end

    Skits_ID_Store.localCacheIdxQueue = Skits_Deque:New()

    return Skits_ID_Store.localCacheIdxQueue
end

function Skits_ID_Store:GetLocalPlayerCacheIdxQueueController()
    if Skits_ID_Store.localPlayerCacheIdxQueue then
        return Skits_ID_Store.localPlayerCacheIdxQueue
    end

    Skits_ID_Store.localPlayerCacheIdxQueue = Skits_Deque:New()

    return Skits_ID_Store.localPlayerCacheIdxQueue
end

-- ------------------------------------------------------------------------------------------------------------

local function NewStore(version)
    return {
        version = version,

        mapNpcNameToIdx = {},

        creatureDataByIdx = {},
        creatureDataIdxQueue = {},

        nextCreatureDataIdx = 1,
        dataQty = 0,
    }
end

-- ------------------------------------
-- Zoned id lists

local function IsValidId(id)
    return type(id) == "number" and id > 0
end

-- Adds an id to a zoned id list (see header). Returns true if the list changed.
local function AddIdToList(list, id, isDisplayId, recentFirst)
    if not IsValidId(id) then
        return false
    end

    local stored = id
    if isDisplayId then
        stored = -id
    end

    -- Segment of the list holding this kind of id
    local npcQty = 0
    while list[npcQty + 1] and list[npcQty + 1] > 0 do
        npcQty = npcQty + 1
    end

    local segStart, segEnd = 1, npcQty
    if isDisplayId then
        segStart, segEnd = npcQty + 1, #list
    end

    local existingPos = nil
    for i = segStart, segEnd do
        if list[i] == stored then
            existingPos = i
            break
        end
    end

    local insertPos = nil
    if existingPos then
        -- Sorted lists are already in place. Recent lists only move it to the front.
        if not recentFirst or existingPos == segStart then
            return false
        end
        table.remove(list, existingPos)
        segEnd = segEnd - 1
        insertPos = segStart
    elseif recentFirst then
        insertPos = segStart
    else
        insertPos = segEnd + 1
        for i = segStart, segEnd do
            if math.abs(list[i]) < id then
                insertPos = i
                break
            end
        end

        -- Would be trimmed right away
        if insertPos >= segStart + MAX_IDS_PER_KIND then
            return false
        end
    end

    table.insert(list, insertPos, stored)
    segEnd = segEnd + 1

    if segEnd - segStart + 1 > MAX_IDS_PER_KIND then
        table.remove(list, segEnd)
    end

    return true
end

local function GetOrCreateKeyList(byKey, key)
    local list = byKey[key]
    if list then
        return list
    end

    -- Key limit: drop any non global key (rare: npc seen in many regions)
    local keyQty = 0
    for _ in pairs(byKey) do
        keyQty = keyQty + 1
    end
    if keyQty >= MAX_KEYS_PER_RECORD then
        for k, _ in pairs(byKey) do
            if k ~= Skits_ZoneGroup.GLOBAL_KEY then
                byKey[k] = nil
                break
            end
        end
    end

    list = {}
    byKey[key] = list
    return list
end

-- ------------------------------------
-- Locals Functions (cache, DB)

function Skits_ID_Store:Locals_Start()
    self:LocalDB_Start()
    self:LocalCache_Start()
    self:LocalPlayerCache_Start()
end

function Skits_ID_Store:Locals_GetCreatureDataByIdx(database, idxQueue, dataIdx)
    local creatureData = nil

    if dataIdx then
        creatureData = database.creatureDataByIdx[dataIdx]

        -- Update to the Deque
        idxQueue:AddToHead(dataIdx)
    end

    return creatureData
end

function Skits_ID_Store:Locals_GetCreatureDataByName(database, idxQueue, creatureName)
    if issecretvalue(creatureName) then
        return
    end

    local dataIdx = nil
    dataIdx = database.mapNpcNameToIdx[creatureName]
    return self:Locals_GetCreatureDataByIdx(database, idxQueue, dataIdx)
end

-- Flat (not zoned) set. Used by the player cache.
function Skits_ID_Store:Locals_SetCreatureData(database, idxQueue, idxLimit, creatureData, updateNewer)
    if creatureData == nil then
        return
    end

    if issecretvalue(creatureData.name) then
        return
    end

    -- Check if we have the creature in the db
    local dataIdx = nil
    dataIdx = database.mapNpcNameToIdx[creatureData.name]

    local dbCreatureData = {}
    if not dataIdx then
        dbCreatureData.name = creatureData.name
        dbCreatureData.creatureId = creatureData.creatureId
        dbCreatureData.displayId = creatureData.displayId

        dataIdx = database.nextCreatureDataIdx
        database.nextCreatureDataIdx = database.nextCreatureDataIdx + 1

        database.mapNpcNameToIdx[dbCreatureData.name] = dataIdx
        database.creatureDataByIdx[dataIdx] = dbCreatureData

        database.dataQty = database.dataQty + 1

        -- Update Queue
        idxQueue:AddToHead(dataIdx)
    else
        dbCreatureData = database.creatureDataByIdx[dataIdx]

        -- Newer Update Logic
        if updateNewer then
            if not dbCreatureData.creatureId or (creatureData.creatureId and creatureData.creatureId > dbCreatureData.creatureId) then
                dbCreatureData.creatureId = creatureData.creatureId
            end
            if not dbCreatureData.displayId or (creatureData.displayId and creatureData.displayId > dbCreatureData.displayId) then
                dbCreatureData.displayId = creatureData.displayId
            end
        else
            -- Update creature id no matter what
            if creatureData.creatureId then
                dbCreatureData.creatureId = creatureData.creatureId
            end
            if creatureData.displayId then
                dbCreatureData.displayId = creatureData.displayId
            end
        end
    end

    -- Check DB limits
    self:Locals_Trim(database, idxQueue, idxLimit)
end

-- Zoned set. Used by the NPC local DB and local cache.
function Skits_ID_Store:Locals_SetZonedCreatureData(database, idxQueue, idxLimit, creatureData, writeKeys, recentFirst)
    if creatureData == nil then
        return
    end

    if issecretvalue(creatureData.name) then
        return
    end

    local hasNpcId = IsValidId(creatureData.creatureId)
    local hasDisplayId = IsValidId(creatureData.displayId)
    if not hasNpcId and not hasDisplayId then
        return
    end

    -- Get or create the record
    local dataIdx = database.mapNpcNameToIdx[creatureData.name]
    local record = nil
    if dataIdx then
        record = database.creatureDataByIdx[dataIdx]
    end

    if not record then
        record = {
            name = creatureData.name,
            byKey = {},
        }

        dataIdx = database.nextCreatureDataIdx
        database.nextCreatureDataIdx = database.nextCreatureDataIdx + 1

        database.mapNpcNameToIdx[record.name] = dataIdx
        database.creatureDataByIdx[dataIdx] = record

        database.dataQty = database.dataQty + 1
    end

    idxQueue:AddToHead(dataIdx)

    -- Write to every key
    for _, key in ipairs(writeKeys) do
        local list = GetOrCreateKeyList(record.byKey, key)
        if hasNpcId then
            AddIdToList(list, creatureData.creatureId, false, recentFirst)
        end
        if hasDisplayId then
            AddIdToList(list, creatureData.displayId, true, recentFirst)
        end
    end

    -- Check DB limits
    self:Locals_Trim(database, idxQueue, idxLimit)
end

function Skits_ID_Store:Locals_Trim(database, idxQueue, dataLimit)
    if database.dataQty <= dataLimit then
        return
    end

    local overLimit = database.dataQty - dataLimit

    -- Get dataIdxs to remove
    local removeds = idxQueue:RemoveFirstX(overLimit)
    for _, dataIdx in ipairs(removeds) do
        database.dataQty = database.dataQty - 1
        if dataIdx then
            local creatureData = database.creatureDataByIdx[dataIdx]
            database.creatureDataByIdx[dataIdx] = nil
            if creatureData then
                database.mapNpcNameToIdx[creatureData.name] = nil
            end
        end
    end
end

-- Keys a sighting on uiMapId is written to: the most specific key and global.
local function GetWriteKeys(uiMapId)
    local chain = Skits_ZoneGroup:GetZoneKeyChain(uiMapId)
    if #chain > 1 then
        return { chain[1], Skits_ZoneGroup.GLOBAL_KEY }
    end
    return chain
end

-- ------------------------------------
-- Local Cache Functions

function Skits_ID_Store:LocalCache_Start()
    if not Skits_ID_Store.localCache then
        Skits_ID_Store.localCache = NewStore(ZONED_STORE_VERSION)
    end
end

function Skits_ID_Store:LocalCache_GetCreatureDataByName(creatureName)
    return self:Locals_GetCreatureDataByName(Skits_ID_Store.localCache, Skits_ID_Store:GetLocalCacheIdxQueueController(), creatureName)
end

function Skits_ID_Store:LocalCache_SetCreatureData(creatureData, writeKeys)
    return self:Locals_SetZonedCreatureData(Skits_ID_Store.localCache, Skits_ID_Store:GetLocalCacheIdxQueueController(), LOCAL_CACHE_MAX_SIZE, creatureData, writeKeys, true)
end

-- ------------------------------------
-- Local DB Functions

-- v1 records: { name, creatureId, displayId, isDisplayIdNewer, creatureIds?, displayIds? }
-- v2 records: { name, byKey = { global = { <ids> } } }
local function MigrateLocalDbToZoned(store)
    local migratedQty = 0
    for dataIdx, oldRecord in pairs(store.creatureDataByIdx) do
        local list = {}

        AddIdToList(list, oldRecord.creatureId, false, false)
        if type(oldRecord.creatureIds) == "table" then
            for _, id in ipairs(oldRecord.creatureIds) do
                AddIdToList(list, id, false, false)
            end
        end

        AddIdToList(list, oldRecord.displayId, true, false)
        if type(oldRecord.displayIds) == "table" then
            for _, id in ipairs(oldRecord.displayIds) do
                AddIdToList(list, id, true, false)
            end
        end

        local byKey = {}
        if #list > 0 then
            byKey[Skits_ZoneGroup.GLOBAL_KEY] = list
        end

        store.creatureDataByIdx[dataIdx] = {
            name = oldRecord.name,
            byKey = byKey,
        }
        migratedQty = migratedQty + 1
    end

    store.version = ZONED_STORE_VERSION
    return migratedQty
end

function Skits_ID_Store:LocalDB_Start()
    if not SkitsDB then
        SkitsDB = {}
    end

    -- Debug
    if not SkitsDB.debugMode then
        SkitsDB.debugMode = false
    end

    if not SkitsDB.creatureIdStore then
        SkitsDB.creatureIdStore = NewStore(ZONED_STORE_VERSION)
    elseif SkitsDB.creatureIdStore.version ~= ZONED_STORE_VERSION then
        local migratedQty = MigrateLocalDbToZoned(SkitsDB.creatureIdStore)
        if SkitsDB.debugMode then
            print("[Skits] Local NPC DB migrated to zoned format: " .. migratedQty .. " entries")
        end
    end
end

function Skits_ID_Store:LocalDB_GetCreatureDataByName(creatureName)
    return self:Locals_GetCreatureDataByName(SkitsDB.creatureIdStore, Skits_ID_Store:GetLocalDbIdxQueueController(), creatureName)
end

function Skits_ID_Store:LocalDB_SetCreatureData(creatureData, writeKeys)
    return self:Locals_SetZonedCreatureData(SkitsDB.creatureIdStore, Skits_ID_Store:GetLocalDbIdxQueueController(), LOCAL_DB_MAX_SIZE, creatureData, writeKeys, false)
end

-- ------------------------------------
-- Local Player Cache Functions

function Skits_ID_Store:LocalPlayerCache_Start()
    if not Skits_ID_Store.localPlayerCache then
        Skits_ID_Store.localPlayerCache = NewStore(nil)
    end
end

function Skits_ID_Store:LocalPlayerCache_GetCreatureDataByName(creatureName)
    return self:Locals_GetCreatureDataByName(Skits_ID_Store.localPlayerCache, Skits_ID_Store:GetLocalPlayerCacheIdxQueueController(), creatureName)
end

function Skits_ID_Store:LocalPlayerCache_SetCreatureData(creatureData)
    return self:Locals_SetCreatureData(Skits_ID_Store.localPlayerCache, Skits_ID_Store:GetLocalPlayerCacheIdxQueueController(), LOCAL_PLAYER_CACHE_MAX_SIZE, creatureData, true)
end

-- ------------------------------------------------------------------------------------------------------------

-- ------------------------------------
-- External DB functions

function Skits_ID_Store:ExternalDB_GetCreatureDataByName(creatureName)
    -- Try CreatureDisplayDB
    if not CreatureDisplayDB then
        return nil
    end

    local displayIds = CreatureDisplayDB:GetDisplayIdsByName(creatureName)
    local creatureIds = CreatureDisplayDB:GetNpcIdsByName(creatureName)
    if not displayIds then
        return nil, {"external: CreatureDisplayDB"}
    end

    local creatureData = {
        name = creatureName,
        creatureId = nil,
        creatureIds = creatureIds,
        displayIds = displayIds,
    }

    return creatureData, {"external: CreatureDisplayDB"}
end

function Skits_ID_Store:ExternalDB_GetFixedCreatureDataByName(creatureName)
    -- Try CreatureDisplayDB
    if not CreatureDisplayDB then
        return nil
    end

    local creatureId = CreatureDisplayDB:GetFixedNpcIdForCurrentZone(creatureName)

    if creatureId then
        local creatureData = {
            name = creatureName,
            creatureId = creatureId,
        }

        return creatureData, {"external: CreatureDisplayDB fixed data"}
    end

    return nil, {"external: CreatureDisplayDB fixed data"}
end


-- ------------------------------------
-- Exposed Functions

-- Appends an id to the result's ordered ids ({id, isDisplayId}), skipping duplicates
local function AddIdToResult(result, seen, id, isDisplayId)
    if not IsValidId(id) then
        return false
    end

    local seenKey = id
    if isDisplayId then
        seenKey = -id
    end
    if seen[seenKey] then
        return false
    end
    seen[seenKey] = true

    table.insert(result.ids, {id, isDisplayId})

    if isDisplayId then
        if not result.displayId then
            result.displayId = id
        end
    elseif not result.creatureId then
        result.creatureId = id
    end

    return true
end

-- Appends a zoned id list to the result. Returns true if anything was added.
local function AddZonedListToResult(result, seen, list)
    local added = false
    for _, stored in ipairs(list) do
        if stored > 0 then
            added = AddIdToResult(result, seen, stored, false) or added
        else
            added = AddIdToResult(result, seen, -stored, true) or added
        end
    end
    return added
end

-- uiMapId is optional, defaults to the player's current map.
function Skits_ID_Store:GetCreatureDataByName(creatureName, isPlayer, uiMapId)
    -- Player data is only retrieved from the local cache
    if isPlayer then
        local creatureData = self:LocalPlayerCache_GetCreatureDataByName(creatureName)
        return creatureData, {"player local cache"}
    end

    if issecretvalue(creatureName) then
        return nil, {}
    end

    -- We will try to retrieve the NPC data from many sources, most specific first.
    -- Source 1: External Addons Fixed ID log
    -- Source 2: Local Cache and Local DB, for each zone key from the most specific to global
    -- Source 3: Other Addons DB

    local result = {
        name = creatureName,
        ids = {},
    }
    local seen = {}
    local allSources = {}

    -- Source 1: Other Addons DB - Fixed Creature data
    local creatureData, sources = self:ExternalDB_GetFixedCreatureDataByName(creatureName)
    if creatureData then
        if AddIdToResult(result, seen, creatureData.creatureId, false) then
            Skits_Utils:AddListToList(sources, allSources, false)
        end
    end

    -- Source 2: Local Cache and Local DB, by zone key
    local cacheRecord = self:LocalCache_GetCreatureDataByName(creatureName)
    local dbRecord = self:LocalDB_GetCreatureDataByName(creatureName)
    if cacheRecord or dbRecord then
        for _, key in ipairs(Skits_ZoneGroup:GetZoneKeyChain(uiMapId)) do
            if cacheRecord and cacheRecord.byKey[key] then
                if AddZonedListToResult(result, seen, cacheRecord.byKey[key]) then
                    table.insert(allSources, "local cache [" .. key .. "]")
                end
            end
            if dbRecord and dbRecord.byKey[key] then
                if AddZonedListToResult(result, seen, dbRecord.byKey[key]) then
                    table.insert(allSources, "local database [" .. key .. "]")
                end
            end
        end
    end

    -- Source 3: Other Addons DB
    creatureData, sources = self:ExternalDB_GetCreatureDataByName(creatureName)
    if creatureData then
        local added = false
        if creatureData.creatureIds then
            for _, id in ipairs(creatureData.creatureIds) do
                added = AddIdToResult(result, seen, id, false) or added
            end
        end
        if creatureData.displayIds then
            for _, id in ipairs(creatureData.displayIds) do
                added = AddIdToResult(result, seen, id, true) or added
            end
        end
        if added then
            Skits_Utils:AddListToList(sources, allSources, false)
        end
    end

    -- Nothing was found
    if #result.ids == 0 then
        return nil, {}
    end

    return result, allSources
end

-- uiMapId is optional, defaults to the player's current map.
function Skits_ID_Store:SetCreatureData(creatureData, isPlayer, uiMapId)
    -- Save it to the local player cache
    if isPlayer then
        -- Save it to the local cache
        self:LocalPlayerCache_SetCreatureData(creatureData)
    else
        local writeKeys = GetWriteKeys(uiMapId)

        -- Save it to the local cache
        self:LocalCache_SetCreatureData(creatureData, writeKeys)

        -- Save it to the local DB
        self:LocalDB_SetCreatureData(creatureData, writeKeys)
    end
end


-- COMMANDs -------------------------------------------------


-- Command to see local db stats
SLASH_SkitsLocalDBStats1 = "/Skitslocaldbstats"
SlashCmdList["SkitsLocalDBStats"] = function()
    if not SkitsDB then
        return
    end
    if not SkitsDB.creatureIdStore then
        return
    end

    print("[NPCID DB Stats]")
    print("Number of Data Entries: " .. SkitsDB.creatureIdStore.dataQty )
end

local function ZonedListToString(list)
    local parts = {}
    for _, stored in ipairs(list) do
        if stored > 0 then
            table.insert(parts, "npc " .. stored)
        else
            table.insert(parts, "dis " .. -stored)
        end
    end
    return table.concat(parts, ", ")
end

local function PrintZonedRecord(label, record)
    if not record then
        print(label .. ": none")
        return
    end

    print(label .. ":")
    for key, list in pairs(record.byKey) do
        print("  [" .. key .. "] " .. ZonedListToString(list))
    end
end

local function PrintNpcData(creatureName)
    local creatureData, sources = Skits_ID_Store:GetCreatureDataByName(creatureName, false)

    print("[NPC Data]")
    print("KEY CHAIN: " .. table.concat(Skits_ZoneGroup:GetZoneKeyChain(), " > "))

    if not creatureData then
        print(creatureName .. " not found in our DBs")
    else
        print("NAME: " .. creatureData.name)
        print("NPC ID: " .. (creatureData.creatureId or "nil"))
        print("DISPLAY ID: " .. (creatureData.displayId or "nil"))

        print("ORDERED IDS:")
        for _, id in ipairs(creatureData.ids) do
            if id[2] then
                print("DisId: " .. id[1])
            else
                print("NpcId: " .. id[1])
            end
        end

        local sourcesStr = "{}"
        if sources then
            sourcesStr = "{" .. table.concat(sources," , ") .. "}"
        end
        print("SOURCES: " .. sourcesStr)
    end

    PrintZonedRecord("LOCAL CACHE", Skits_ID_Store:LocalCache_GetCreatureDataByName(creatureName))
    PrintZonedRecord("LOCAL DB", Skits_ID_Store:LocalDB_GetCreatureDataByName(creatureName))
end

-- Command to get NPC data by name
SLASH_SkitsNPCData1 = "/Skitsnpcdata"
SlashCmdList["SkitsNPCData"] = function(creatureName)
    if not SkitsDB then
        return
    end
    if not SkitsDB.creatureIdStore then
        return
    end

    PrintNpcData(creatureName)
end


-- Command to get target NPC data
SLASH_SkitsTargetData1 = "/Skitstargetdata"
SlashCmdList["SkitsTargetData"] = function()
    if not SkitsDB then
        return
    end
    if not SkitsDB.creatureIdStore then
        return
    end

    local creatureName = nil
    local unittoken = "target"
    if UnitExists(unittoken) then
        creatureName, _ = UnitName(unittoken)
    end

    if creatureName then
        PrintNpcData(creatureName)
    end
    return
end

-- Command to clear the local db
SLASH_SkitsClearLocalDB1 = "/Skitsclearlocaldb"
SlashCmdList["SkitsClearLocalDB"] = function()
    if not SkitsDB then
        return
    end

    print("[Cleaning Skits Local NPCID DB]")

    SkitsDB.creatureIdStore = NewStore(ZONED_STORE_VERSION)
    Skits_ID_Store:GetLocalDbIdxQueueController():Reset()
end

-- Command to print the uiMapID chain (current map up to the root)
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

    local guard = 0
    while uiMapId and uiMapId ~= 0 and guard < 20 do
        local mapInfo = C_Map.GetMapInfo(uiMapId)
        if not mapInfo then
            print("mapID: " .. uiMapId .. " (no map info)")
            break
        end

        local typeName = UI_MAP_TYPE_NAMES[mapInfo.mapType] or "Unknown"
        print("mapID: " .. mapInfo.mapID)
        print("name: " .. (mapInfo.name or ""))
        print("type: " .. typeName .. " (" .. (mapInfo.mapType or "nil") .. ")")

        uiMapId = mapInfo.parentMapID
        guard = guard + 1
    end
end
