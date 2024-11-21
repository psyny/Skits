-- Skits_ID_Store.lua

Skits_ID_Store = {}
Skits_ID_Store.localDbIdxQueue = nil
Skits_ID_Store.localCacheIdxQueue = nil
Skits_ID_Store.localCache = nil
Skits_ID_Store.localPlayerCacheIdxQueue = nil
Skits_ID_Store.localPlayerCache = nil

local LOCAL_DB_MAX_SIZE = 100000
local LOCAL_CACHE_MAX_SIZE = 10000
local LOCAL_PLAYER_CACHE_MAX_SIZE = 1000

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
    local dataIdx = nil
    dataIdx = database.mapNpcNameToIdx[creatureName]
    return self:Locals_GetCreatureDataByIdx(database, idxQueue, dataIdx)
end

function Skits_ID_Store:Locals_SetCreatureData(database, idxQueue, idxLimit, creatureData, updateNewer)
    if creatureData == nil or creatureData.creatureId == nil then
        return
    end

    -- Add DB
    local dataIdx = nil
    dataIdx = database.mapNpcNameToIdx[creatureData.name]
    if not dataIdx then
        -- Add
        dataIdx = database.nextCreatureDataIdx
        database.nextCreatureDataIdx = database.nextCreatureDataIdx + 1

        database.mapNpcNameToIdx[creatureData.name] = dataIdx
        database.mapNpcCreatureIdToIdx[creatureData.creatureId] = dataIdx            
        database.creatureDataByIdx[dataIdx] = creatureData

        database.dataQty = database.dataQty + 1

        -- Update Queue
        idxQueue:AddToHead(dataIdx)
    else       
        local currCreatureData = database.creatureDataByIdx[dataIdx]
        if updateNewer then
             -- Update creature id if its newer (theres a reason to store all the old ones? how would we define its usage?)            
            if creatureData.creatureId > currCreatureData.creatureId then
                currCreatureData.creatureId = creatureData.creatureId
            end   
        else
            -- Update creature id no matter what
            -- Useful for local cache, that usually represents most recent, ephemeral, player interactions.
            currCreatureData.creatureId = creatureData.creatureId
        end
    end

    -- Check DB limits
    self:Locals_Trim(database, idxQueue, idxLimit)
end

function Skits_ID_Store:Locals_Trim(database, idxQueue, dataLimit)
    if database.dataQty > dataLimit then
        return 
    end

    local overLimit = database.dataQty - dataLimit

    -- Get dataIdxs to remove
    removeds = idxQueue:RemoveFirstX(overLimit)   
    for _, dataIdx in ipairs(removeds) do
        database.dataQty = database.dataQty - 1
        if dataIdx then
            local creatureData = database.creatureDataByIdx[dataIdx]
            database.creatureDataByIdx[dataIdx] = nil
            if creatureData then
                database.mapNpcNameToIdx[creatureData.name] = nil
                database.mapNpcCreatureIdToIdx[creatureData.creatureId] = nil            
            end
        end
    end
end

-- ------------------------------------
-- Local Cache Functions

function Skits_ID_Store:LocalCache_Start()
    if not Skits_ID_Store.localCache then
        Skits_ID_Store.localCache = {
            mapNpcNameToIdx = {},
            mapNpcCreatureIdToIdx = {},
                        
            creatureDataByIdx = {},
            creatureDataIdxQueue = {},

            nextCreatureDataIdx = 1,
            dataQty = 0,
        }
    end
end

function Skits_ID_Store:LocalCache_GetCreatureDataByName(creatureName)
    return self:Locals_GetCreatureDataByName(Skits_ID_Store.localCache, Skits_ID_Store:GetLocalCacheIdxQueueController(), creatureName)
end

function Skits_ID_Store:LocalCache_SetCreatureData(creatureData)
    return self:Locals_SetCreatureData(Skits_ID_Store.localCache, Skits_ID_Store:GetLocalCacheIdxQueueController(), LOCAL_CACHE_MAX_SIZE, creatureData, false)
end

-- ------------------------------------
-- Local DB Functions

function Skits_ID_Store:LocalDB_Start()
    if not SkitsDB then
        SkitsDB = {}
    end
    if not SkitsDB.creatureIdStore then
        SkitsDB.creatureIdStore = {
            mapNpcNameToIdx = {},
            mapNpcCreatureIdToIdx = {},
                        
            creatureDataByIdx = {},
            creatureDataIdxQueue = {},

            nextCreatureDataIdx = 1,
            dataQty = 0,
        }
    end
end

function Skits_ID_Store:LocalDB_GetCreatureDataByName(creatureName)
    return self:Locals_GetCreatureDataByName(SkitsDB.creatureIdStore, Skits_ID_Store:GetLocalDbIdxQueueController(), creatureName)
end

function Skits_ID_Store:LocalDB_SetCreatureData(creatureData)
    return self:Locals_SetCreatureData(SkitsDB.creatureIdStore, Skits_ID_Store:GetLocalDbIdxQueueController(), LOCAL_DB_MAX_SIZE, creatureData, true)
end

-- ------------------------------------
-- Local Player Cache Functions

function Skits_ID_Store:LocalPlayerCache_Start()
    if not Skits_ID_Store.localPlayerCache then
        Skits_ID_Store.localPlayerCache = {
            mapNpcNameToIdx = {},
            mapNpcCreatureIdToIdx = {},
                        
            creatureDataByIdx = {},
            creatureDataIdxQueue = {},

            nextCreatureDataIdx = 1,
            dataQty = 0,
        }
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
        return nil, "external: CreatureDisplayDB"
    end

    local creatureData = {
        name = creatureName,
        creatureId = nil,
        creatureIds = creatureIds,
        displayIds = displayIds,
    }

    return creatureData, "external: CreatureDisplayDB"
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
        
        return creatureData, "external: CreatureDisplayDB fixed data"
    end

    return nil, "external: CreatureDisplayDB fixed data"
end


-- ------------------------------------
-- Exposed Functions

function Skits_ID_Store:GetCreatureDataByName(creatureName, isPlayer)
    local creatureData = nil
    local source = nil

    -- Player data is only retrieved from the local cache
    if isPlayer then
        creatureData = self:LocalPlayerCache_GetCreatureDataByName(creatureName)
        return creatureData, "local cache"
    end

    -- We will try to retrieve the NPC data from many sources.
    -- Source 1: External Addons Fixed ID log
    -- Source 2 Local Cache (cache since last reload)
    -- Source 3: Other Addons DB    
    -- Source 4: Local DB

    -- Source 1: Other Addons DB
    creatureData, source = self:ExternalDB_GetFixedCreatureDataByName(creatureName)
    if creatureData then
        return creatureData, source
    end      

    -- Source 2: Local Cache
    creatureData = self:LocalCache_GetCreatureDataByName(creatureName)
    if creatureData then
        return creatureData, "local cache"
    end  
    
    -- Source 3: Other Addons DB
    creatureData, source = self:ExternalDB_GetCreatureDataByName(creatureName)
    if creatureData then
        return creatureData, source
    end      

    -- Source 4: Local DB
    creatureData = self:LocalDB_GetCreatureDataByName(creatureName)
    if creatureData then
        return creatureData, "local database"
    end

    -- Nothing was found
    return nil, nil
end

function Skits_ID_Store:SetCreatureData(creatureData, isPlayer)
    -- Save it to the local player cache
    if isPlayer then
        -- Save it to the local cache
        self:LocalPlayerCache_SetCreatureData(creatureData)   
    else 
        -- Save it to the local cache
        self:LocalCache_SetCreatureData(creatureData)    

        -- Save it to the local DB
        self:LocalDB_SetCreatureData(creatureData)
    end
end



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

-- Command to get NPC data
SLASH_SkitsNPCData1 = "/Skitsnpcdata"
SlashCmdList["SkitsNPCData"] = function(creatureName)    
    if not SkitsDB then
        return
    end
    if not SkitsDB.creatureIdStore then
        return
    end

    local creatureData, source = Skits_ID_Store:GetCreatureDataByName(creatureName, false)

    print("[NPC Data]") 
    if not creatureData then
        print(creatureName .. " not found in our DBs")
    else
        print("Name: " .. creatureData.name)

        local creatureId = "nil"
        if creatureData.creatureId then
            creatureId = creatureData.creatureId
        end
        print("NPC ID: " .. creatureId)

        local creatureIds = "{}"
        if creatureData.creatureIds then
            creatureIds = "{" .. table.concat(creatureData.creatureIds," , ") .. "}"
        end
        print("NPC IDs: " .. creatureIds)

        local displayIds = "{}"
        if creatureData.displayIds then
            displayIds = "{" .. table.concat(creatureData.displayIds," , ") .. "}"
        end
        print("Display IDs: " .. displayIds)        

        print("Source: " .. source)
    end
end

-- Command to clear the local db
SLASH_SkitsClearLocalDB1 = "/Skitsclearlocaldb"
SlashCmdList["SkitsClearLocalDB"] = function()    
    if not SkitsDB then
        return
    end

    print("[Cleaning Skits Local NPCID DB]") 

    SkitsDB.creatureIdStore = {
        mapNpcNameToIdx = {},
        mapNpcCreatureIdToIdx = {},
                    
        creatureDataByIdx = {},
        creatureDataIdxQueue = {},

        nextCreatureDataIdx = 1,
        dataQty = 0,
    }
end
