-- Skits_UI_Utils.lua
Skits_UI_Utils = {}

function Skits_UI_Utils:RemoveFrame(frame) 
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
end

local speakPatterns = {
    ["No"] = {"^[Nn][oO][^%w]", 186},
    ["Yes"] = {"^[Yy][Ee][Ss][^%w]", 185},
    ["Haha"] = {"^[Hh][Aa][Hh][Aa]", 70},
    ["Cry"] = {"^%*%s*[Cc][Rr][Yy]%*%s*", 77},
    ["Sob"] = {"^%*%s*[Ss][Oo][Bb]%*%s*", 77},
    ["Laugh"] = {"^%*%s*[Ll][Aa][Uu][Gg][Hh]%s*%*", 70},
    ["Bye"] = {"^[Bb][yy][Ee][^%w]", 67},
    ["Farewell"] = {"^[Ff][Aa][Rr][Ee][Ww][Ee][Ll][Ll][^%w]", 67},
}

function Skits_UI_Utils:GetAnimationIdsFromText(text, addIdle)
    local animations = {}

    for i = 1, #text do
        local char = text:sub(i, i)

        if char == "!" then
            table.insert(animations, 64)
        elseif char == "?" then
            table.insert(animations, 65)
        elseif char == "." then
            table.insert(animations, 60)
        else
            local subText = text:sub(i)
            for _, patternData in pairs(speakPatterns) do
                if subText:match(patternData[1]) then
                    table.insert(animations, patternData[2])
                    break
                end
            end
        end
    end   

    if #animations == 0 then
        table.insert(animations, 60)    
    end    

    if addIdle then
        -- Idle, pauses between talks
        table.insert(animations, 0)    
    end

    return animations
end

function Skits_UI_Utils:GetRadAngle(degree)
    return math.rad(degree)
end


-- MODEL LOADER ---------------------------------------
local displayIdsByRaceAndGender = {
    -- HUMAN
    [1] = { [0] = 53652, [1] = 1474 },
    [33] = { [0] = 53652, [1] = 1474 },
    -- ORC
    [2] = { [0] = 42994, [1] = 42999 },
    -- DWARF
    [3] = { [0] = 48200, [1] = 19173 },
    -- NIGHT ELF
    [4] = { [0] = 40553, [1] = 43043 },
    -- UNDEAD
    [5] = { [0] = 47835, [1] = 39296 },
    -- TAUREN
    [6] = { [0] = 45379, [1] = 49781 },
    -- GNOME
    [7] = { [0] = 48774, [1] = 45230 },
    -- TROLL
    [8] = { [0] = 43027, [1] = 47345 },
    -- GOBLIN
    [9] = { [0] = 43048, [1] = 43049 },
    -- BLOOD ELF
    [10] = { [0] = 43032, [1] = 43038 },
    -- DRAENEI
    [11] = { [0] = 54077, [1] = 54581 },
    -- WORGEN
    [22] = { [0] = 39820, [1] = 37446 },    
    -- PANDAREN  - Neutral, Horde , Alliance
    [24] = { [0] = 43077, [1] = 43081 },
    [25] = { [0] = 43077, [1] = 43081 },
    [26] = { [0] = 43077, [1] = 43081 },
    -- NIGHTBORNE
    [27] = { [0] = 68890, [1] = 67345 },
    -- HIGHMOUNTAIN TAUREN
    [28] = { [0] = 65479, [1] = 73318 },
    -- VOID ELF
    [29] = { [0] = 83232, [1] = 83231 },
    -- LIGHTFORGED DRAENEI
    [30] = { [0] = 82847, [1] = 77524 },
    -- MAG'HAR ORC
    [36] = { [0] = 86338, [1] = 86339 },
    -- ZANDALARI TROLL
    [31] = { [0] = 82848, [1] = 79224 },
    -- KUL TIRAN
    [32] = { [0] = 82612, [1] = 89784 },
    -- VULPERA
    [35] = { [0] = 80327, [1] = 79314 },
    -- DARK IRON DWARF
    [34] = { [0] = 82281, [1] = 82279 },
    -- MECHAGNOME
    [37] = { [0] = 92174, [1] = 92493 },
    -- DRACTHYR - Horde , Alliance
    [52] = { [0] = 104842, [1] = 104840 }, 
    [70] = { [0] = 104841, [1] = 104839 },
    -- EARTHEN - Horde , Alliance
    [84] = { [0] = 117354, [1] = 117414 },
    [85] = { [0] = 117353, [1] = 117355 },
}

local npcIdsByRaceAndGender = {
    -- HUMAN
    [1] = { [0] = 18941, [1] = 18935 },
    [33] = { [0] = 18941, [1] = 18935 },
    -- ORC
    [2] = { [0] = 19117, [1] = 19109 },
    -- DWARF
    [3] = { [0] = 19115, [1] = 19108 },
    -- NIGHT ELF
    [4] = { [0] = 19116, [1] = 19112 },
    -- UNDEAD
    [5] = { [0] = 19119, [1] = 19110 },
    -- TAUREN
    [6] = { [0] = 19118, [1] = 19111 },
    -- GNOME
    [7] = { [0] = 19122, [1] = 19121 },
    -- TROLL
    [8] = { [0] = 19124, [1] = 19123 },
    -- GOBLIN
    [9] = { [0] = 106502, [1] = 80123 },
    -- BLOOD ELF
    [10] = { [0] = 19113, [1] = 19106 },
    -- DRAENEI
    [11] = { [0] = 19114, [1] = 19107 },
    -- WORGEN
    [22] = { [0] = 79369, [1] = 79615 },    
    -- PANDAREN  - Neutral, Horde , Alliance
    [24] = { [0] = 63483, [1] = 78013 },
    [25] = { [0] = 63483, [1] = 78013 },
    [26] = { [0] = 63483, [1] = 78013 },
    -- NIGHTBORNE
    [27] = { [0] = 101359, [1] = 101358 },
    -- HIGHMOUNTAIN TAUREN
    [28] = { [0] = 80021, [1] = 80019 },
    -- VOID ELF
    [29] = { [0] = 101089, [1] = 101090 },
    -- LIGHTFORGED DRAENEI
    [30] = { [0] = 97115, [1] = 99579 },
    -- MAG'HAR ORC
    [36] = { [0] = 158141, [1] = 139503 },
    -- ZANDALARI TROLL
    [31] = { [0] = 94432, [1] = 131528 },
    -- KUL TIRAN
    [32] = { [0] = 98297, [1] = 98857 },
    -- VULPERA
    [35] = { [0] = 99038, [1] = 122771 },
    -- DARK IRON DWARF
    [34] = { [0] = 132389, [1] = 132390 },
    -- MECHAGNOME
    [37] = { [0] = 153286, [1] = 153271 },
    -- DRACTHYR - Horde , Alliance
    [52] = { [0] = 198434, [1] = 198434 }, 
    [70] = { [0] = 198434, [1] = 198434 },
    -- EARTHEN - Horde , Alliance
    [84] = { [0] = 210158, [1] = 228111 },
    [85] = { [0] = 210158, [1] = 228111 },
}

function Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, light, pauseAfter, fallbackId, fallbackLight) 
    local displayOptions = {
        portraitZoom = portraitZoom,
        scale = scale,
        rotation = rotation,
        animations = animations,
        pauseAfter = pauseAfter,
        light = light,
        fallbackId = fallbackId,
        fallbackLight = fallbackLight,
    }

    return displayOptions
end

function Skits_UI_Utils:BuildLoadOptions(modelFrame, callback) 
    local loadOptions = {
        modelFrame = modelFrame,
        callback = callback,
    }

    return loadOptions
end

local function LoadModelApplyLoadOptions(loaderData, setAnimations)
    local displayOptions = loaderData.displayOptions
    local modelFrame = loaderData.loadOptions.modelFrame

    if not displayOptions then
        return
    end    

    if displayOptions.portraitZoom then
        modelFrame:SetPortraitZoom(displayOptions.portraitZoom)
    end    

    if displayOptions.rotation then
        modelFrame:SetRotation(displayOptions.rotation)
    end  
    
    if displayOptions.scale then
        --local posx = Skits_Utils:Interpolation(-15, 15, 0, 2, displayOptions.scale)
        --modelFrame:SetPosition(posx, 0, 0) 
        modelFrame:SetModelScale(displayOptions.scale)
    end  

    if loaderData.fallback then
        if displayOptions.fallbackLight then
            modelFrame:SetLight(true, displayOptions.fallbackLight)
        end  
    else
        if displayOptions.light then
            modelFrame:SetLight(true, displayOptions.light)
        end  
    end

    if setAnimations then
        if displayOptions.animations and #displayOptions.animations > 0 then
            local animationId = displayOptions.animations[math.random(#displayOptions.animations)]
            modelFrame:SetAnimation(animationId)
        end

        if displayOptions.pauseAfter then
            C_Timer.NewTimer(displayOptions.pauseAfter, function()
                local thisModelFrame = modelFrame
                thisModelFrame:SetPaused(true) 
            end)   
        end   
    end 
end

local function LoadModelStopTimer(loaderData)
    if not loaderData then
        return
    end

    if loaderData.loaderHandle then
        loaderData.loaderHandle:Cancel()
        loaderData.loaderHandle = nil
    end

    local modelFrame = loaderData.loadOptions.modelFrame
    modelFrame:SetScript("OnModelLoaded", nil)    
end

local function LoadModelIsLoaded(loaderData)
    local modelFrame = loaderData.loadOptions.modelFrame
    local modelFileID = modelFrame:GetModelFileID()
    if modelFileID and modelFileID > 0 then
        return true
    end   

    return false
end

local function LoadModelFinished(loaderData)
    LoadModelStopTimer(loaderData)

    local loadResults = {
        creatureData = loaderData.creatureData,
        loadedIsDisplay = loaderData.attemptLastIdIsDisplay,
        loadedId = loaderData.attemptLastId,
    }    

    -- Broadcast Results
    if loaderData.loadOptions.callback then
        loaderData.loadOptions.callback(loadResults)
    end

    -- Display Options
    LoadModelApplyLoadOptions(loaderData, true)

    -- Debug Print
    if SkitsDB.debugMode then
        if not loaderData.creatureData.isPlayer then
            print("[FRAME MODEL LOADED]")
            print("Creature Name: " .. loaderData.creatureData.name)
            print("Attempts: " .. loaderData.attemptTotal)
            print("Phase: " .. loaderData.attemptPhase)
            if loaderData.attemptLastIdIsDisplay then
                print("Display Id: " .. loaderData.attemptLastId)
            else
                print("Npc Id: " .. loaderData.attemptLastId)
            end    
        end
    end    
end

local function LoadModelStartTimer(loaderData)
    if not loaderData then
        return
    end

    LoadModelStopTimer(loaderData)

    local modelFrame = loaderData.loadOptions.modelFrame
    modelFrame:SetScript("OnModelLoaded", function(self)
        local tloaderData = loaderData
        LoadModelFinished(tloaderData)
    end)        

    loaderData.loaderHandle = C_Timer.NewTimer(0.2, function()
        Skits_UI_Utils:LoadModelAux(loaderData)
    end)
end

function Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)
    local attemptPhase = 1
    if (not creatureData.creatureIds or #creatureData.creatureIds == 0) and (not creatureData.displayIds or #creatureData.displayIds == 0) and (not creatureData.creatureId) and (not creatureData.displayId) then
        attemptPhase = 0
    end
    
    loaderData = {
        creatureData = creatureData,
        loadOptions = loadOptions,   
        displayOptions = displayOptions,           

        loaderHandle = nil,
        attemptIdx = 1,
        attemptPhase = attemptPhase,
        attemptCurrent = 0,
        attemptTotal = 0,
        attemptLastId = 0,
        attemptLastIdIsDisplay = true,
        fallback = false,

        loadModelAttemptsPerIdx = 2,
    } 

    loadOptions.modelFrame:ClearModel()

    Skits_UI_Utils:LoadModelAux(loaderData)
end


function Skits_UI_Utils:LoadModelAux(loaderData)
    if not loaderData then
        return
    end

    local creatureData = loaderData.creatureData
    if not creatureData then
        return
    end

    -- Useful Variables
    local modelFrame = loaderData.loadOptions.modelFrame

    if false then
        -- Pre Set Model Frame Options
        LoadModelApplyLoadOptions(loaderData, false)

        -- Is model already loaded?
        if LoadModelIsLoaded(loaderData) then
            LoadModelFinished(loaderData)
            return 
        end
    end

    -- Attempt Control
    loaderData.attemptCurrent = loaderData.attemptCurrent + 1
    loaderData.attemptTotal = loaderData.attemptTotal + 1    
    
    -- Set model (trying to load it)
    modelFrame:SetPosition(0, 0, 0) 
    modelFrame:SetModelScale(1.0)
    if creatureData.isPlayer then
        -- Player        
        if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
            loaderData.attemptCurrent = 1
            loaderData.attemptPhase = 10
        else        
            -- Model for Player
            if creatureData.unitToken then
                -- Unit Token
                modelFrame:SetUnit(creatureData.unitToken)
                modelSet = true
            elseif creatureData.raceId then
                -- Generic Model
                local genderModels = displayIdsByRaceAndGender[creatureData.raceId]
                if genderModels then
                    local displayId = genderModels[creatureData.genderId]
                    if displayId then
                        modelFrame:SetDisplayInfo(displayId)
                        modelSet = true
                    end
                end
            end
        end
    else
        -- NPC

        -- We still dont have a model, try fetch it (maybe we got this information after the frame was created)
        if loaderData.attemptPhase == 0 then
            local creatureData, _ = Skits_ID_Store:GetCreatureDataByName(loaderData.speakerName, false)
            if creatureData then
                creatureData.creatureId = creatureData.creatureId
                creatureData.ids = creatureData.ids
                loaderData.attemptPhase = 1
            else
                loaderData.attemptCurrent = 1
                if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx * 5 then
                    loaderData.attemptIdx = 1
                    loaderData.attemptCurrent = 1
                    loaderData.attemptPhase = 10
                end
            end            
        end

        -- Ordered Ids
        if loaderData.attemptPhase == 1 then   
            if not creatureData.ids or #creatureData.ids == 0 then
                loaderData.attemptPhase = 2
            else
                local shouldAttempt = true
                if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
                    loaderData.attemptCurrent = 1
                    loaderData.attemptIdx = loaderData.attemptIdx + 1
                    if loaderData.attemptIdx > #creatureData.ids then
                        loaderData.attemptIdx = 1
                        loaderData.attemptPhase = 2
                        shouldAttempt = false
                    end
                end

                if shouldAttempt then
                    local currIdData = creatureData.ids[loaderData.attemptIdx]
                    if currIdData then
                        local currId = currIdData[1]
                        local isDisplayId = currIdData[2]
                        loaderData.attemptLastId = currId
                        loaderData.attemptLastIdIsDisplay = isDisplayId                                                             
                        --modelFrame:ClearModel()
                        if isDisplayId then
                            modelFrame:SetDisplayInfo(currId)
                        else
                            modelFrame:SetCreature(currId)
                        end

                        if SkitsDB.debugMode then
                            print("Attempting to load id: " .. currId)
                        end                            
                    end
                end                                 
            end
        end  

        -- Single Display Id
        if loaderData.attemptPhase == 2 then
            if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
                loaderData.attemptCurrent = 0
                loaderData.attemptPhase = 3
            else
                if not creatureData.displayId then         
                    loaderData.attemptPhase = 3
                else
                    loaderData.attemptLastId = creatureData.displayId
                    loaderData.attemptLastIdIsDisplay = true                       
                    modelFrame:SetDisplayInfo(creatureData.displayId)
                end
            end
        end

        -- Single NPC Id
        if loaderData.attemptPhase == 3 then
            if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
                loaderData.attemptCurrent = 0
                loaderData.attemptPhase = 10
            else
                if not creatureData.creatureId then         
                    loaderData.attemptPhase = 10
                else
                    loaderData.attemptLastId = creatureData.creatureId
                    loaderData.attemptLastIdIsDisplay = false                        
                    modelFrame:SetCreature(creatureData.creatureId)
                end
            end
        end

        -- Fallback Display Id
        if loaderData.attemptPhase == 10 then
            loaderData.attemptPhase = 99

            loaderData.fallback = true
            if loaderData.displayOptions.fallbackId then
                modelFrame:SetDisplayInfo(loaderData.displayOptions.fallbackId)
            end
        end        
    end
    
    -- Is model already loaded?
    if LoadModelIsLoaded(loaderData) then
        LoadModelFinished(loaderData)
        return 
    end    
    
    -- Timer to check again if the model has been loaded
    if loaderData.attemptPhase < 99 then
        LoadModelStartTimer(loaderData)
    end        
end