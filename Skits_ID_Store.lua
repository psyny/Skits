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
    if creatureData == nil then
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
            -- Update creature id only if its newer (theres a reason to store all the old ones? how would we define its usage?)            
            if not dbCreatureData.creatureId or (creatureData.creatureId and creatureData.creatureId > dbCreatureData.creatureId) then
                dbCreatureData.creatureId = creatureData.creatureId
            end   
            if not dbCreatureData.displayId or (creatureData.displayId and creatureData.displayId > dbCreatureData.displayId) then
                dbCreatureData.displayId = creatureData.displayId
            end              
        else
            -- Update creature id no matter what
            -- Useful for local cache, that usually represents most recent, ephemeral, player interactions.
            if creatureData.creatureId then
                dbCreatureData.creatureId = creatureData.creatureId
            end
            if creatureData.displayId then
                dbCreatureData.displayId = creatureData.displayId
            end            
        end         
    end

    if creatureData.displayId then
        dbCreatureData.isDisplayIdNewer = creatureData.displayId and true
    end

    -- Update DB Lists
    if false then
        -- WIP: Currently is adding too much stuttering
        if not dbCreatureData.creatureIds then
            dbCreatureData.creatureIds = {}
        end
        if not dbCreatureData.displayIds then
            dbCreatureData.displayIds = {}
        end

        if creatureData.creatureId then
            Skits_Utils:AddEleToList(creatureData.creatureId, dbCreatureData.creatureIds)
        end
        if creatureData.displayId then
            Skits_Utils:AddEleToList(creatureData.displayId, dbCreatureData.displayIds)
        end

        if creatureData.creatureIds then
            Skits_Utils:AddListToList(creatureData.creatureIds, dbCreatureData.creatureIds, true)
        end
        if creatureData.displayIds then
            Skits_Utils:AddListToList(creatureData.displayIds, dbCreatureData.displayIds, true)
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

local function addToCreatureData(newCreatureData, currCreatureData, newSources, currSources)
    -- Sources Update
    if currSources then
        Skits_Utils:AddListToList(newSources, currSources, false)
    end

    -- Basic Creature Data
    if not currCreatureData.name and newCreatureData.name then
        currCreatureData.name = newCreatureData.name
    end

    if not currCreatureData.creatureId and newCreatureData.creatureId then
        currCreatureData.creatureId = newCreatureData.creatureId
    end

    if not currCreatureData.displayId and newCreatureData.displayId then
        currCreatureData.displayId = newCreatureData.displayId
    end

    -- Advanced Creature Data: Ordered Ids
    if not currCreatureData.ids then
        currCreatureData.ids = {}
    end

    if newCreatureData.isDisplayIdNewer then
        if newCreatureData.displayId then
            local idData = {newCreatureData.displayId, true}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end   
        if newCreatureData.creatureId then
            local idData = {newCreatureData.creatureId, false}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end      
    else 
        if newCreatureData.creatureId then
            local idData = {newCreatureData.creatureId, false}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end  
        if newCreatureData.displayId then
            local idData = {newCreatureData.displayId, true}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end 
    end
 
    if newCreatureData.creatureIds then    
        for _, id in ipairs(newCreatureData.creatureIds) do
            local idData = {id, false}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end
    end
 
    if newCreatureData.displayIds then    
        for _, id in ipairs(newCreatureData.displayIds) do
            local idData = {id, true}
            Skits_Utils:AddEleToList(idData, currCreatureData.ids)
        end
    end    
end

function Skits_ID_Store:GetCreatureDataByName(creatureName, isPlayer)
    local creatureData = nil
    local source = nil

    -- Player data is only retrieved from the local cache
    if isPlayer then
        creatureData = self:LocalPlayerCache_GetCreatureDataByName(creatureName)
        return creatureData, {"player local cache"}
    end

    -- We will try to retrieve the NPC data from many sources.
    -- Source 1: External Addons Fixed ID log
    -- Source 2: Local Cache (cache since last reload)
    -- Source 3: Local DB    
    -- Source 4: Other Addons DB    


    local allCreatureData = {}
    local allSources = {}
    local hadSomeData = false

    -- Source 1: Other Addons DB - Fixed Creature data
    creatureData, sources = self:ExternalDB_GetFixedCreatureDataByName(creatureName)
    if creatureData then
        hadSomeData = true
        addToCreatureData(creatureData, allCreatureData, sources, allSources)
    end      

    -- Source 2: Local Cache
    creatureData = self:LocalCache_GetCreatureDataByName(creatureName)
    if creatureData then
        hadSomeData = true
        addToCreatureData(creatureData, allCreatureData, {"local cache"}, allSources)
    end  
    
    -- Source 3: Local DB
    creatureData = self:LocalDB_GetCreatureDataByName(creatureName)
    if creatureData then
        hadSomeData = true
        addToCreatureData(creatureData, allCreatureData, {"local database"}, allSources)
    end

    -- Source 4: Other Addons DB
    creatureData, sources = self:ExternalDB_GetCreatureDataByName(creatureName)
    if creatureData then
        hadSomeData = true
        addToCreatureData(creatureData, allCreatureData, sources, allSources)
    end      

    -- Nothing was found
    if hadSomeData then
        return allCreatureData, allSources
    else
        return nil, {}
    end    
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

local function PrintNpcData(creatureName)
    local creatureData, sources = Skits_ID_Store:GetCreatureDataByName(creatureName, false)

    print("[NPC Data]") 
    if not creatureData then
        print(creatureName .. " not found in our DBs")
    else
        print("NAME: " .. creatureData.name)

        local creatureId = "nil"
        if creatureData.creatureId then
            creatureId = creatureData.creatureId
        end
        print("NPC ID: " .. creatureId)

        local displayId = "nil"
        if creatureData.displayId then
            displayId = creatureData.displayId
        end
        print("DISPLAY ID: " .. displayId)

        print("ORDERED IDS:")
        if creatureData.ids then
            for _, id in ipairs(creatureData.ids) do
                if id[2] then
                    print("DisId: " .. id[1])
                else
                    print("NpcId: " .. id[1])
                end
            end
        end
        
        local sourcesStr = "{}"
        if sources then
            sourcesStr = "{" .. table.concat(sources," , ") .. "}"
        end
        print("SOURCES: " .. sourcesStr)
    end
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

    SkitsDB.creatureIdStore = {
        mapNpcNameToIdx = {},
                    
        creatureDataByIdx = {},
        creatureDataIdxQueue = {},

        nextCreatureDataIdx = 1,
        dataQty = 0,
    }
end
