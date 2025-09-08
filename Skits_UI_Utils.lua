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


-- MODEL LOADER -----------------------------------------------------------------------------------

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

        -- DEBUG: Print when target size is set
        if SkitsDB.debugMode then
            print("[DEBUG] " .. loaderData.creatureData.name .. " | LoadModelApplyLoadOptions: Setting scale to " .. displayOptions.scale)
        end        
        
        -- FIX: Re-apply the target size after scale change to ensure proper bounds
        if modelFrame.targetSize then
            -- modelFrame:SetSize(modelFrame.targetSize.w, modelFrame.targetSize.h)
        end
    end  

    if loaderData.fallback then
        if displayOptions.fallbackLight then
            displayOptions.light = displayOptions.fallbackLight
            modelFrame:SetLight(true, displayOptions.light)
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
            if displayOptions.pauseAfter <= 0 then     
                modelFrame.pauseOn = GetTime()           
                modelFrame:SetPaused(true) 
            else
                modelFrame.pauseOn = GetTime() + displayOptions.pauseAfter
                local thisModelFrame = modelFrame
                modelFrame.pauseHandler = C_Timer.NewTimer(displayOptions.pauseAfter, function()
                    thisModelFrame:SetPaused(true) 
                end) 
            end
        end
    end 
end

function Skits_UI_Utils:LoadReAppeared(loaderData)
    local displayOptions = loaderData.displayOptions
    local modelFrame = loaderData.loadOptions.modelFrame

    if not displayOptions then
        return
    end    

    if not modelFrame then
        return
    end

    if modelFrame.pauseOn then
        local timeNow = GetTime()
        if modelFrame.pauseOn <= timeNow then
            modelFrame:SetPaused(true) 
        else
            local diff = modelFrame.pauseOn - timeNow
            local thisModelFrame = modelFrame

            if modelFrame.pauseHandler then
                modelFrame.pauseHandler:Cancel()
            end
            modelFrame.pauseHandler = C_Timer.NewTimer(diff, function()
                thisModelFrame:SetPaused(true) 
            end) 
        end
    else
        modelFrame:SetPaused(false) 
    end
end

function Skits_UI_Utils:LoadModelStopTimer(loaderData)
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
    local lastPhase = loaderData.attemptPhase

    loaderData.attemptPhase = 99
    Skits_UI_Utils:LoadModelStopTimer(loaderData)

    local loadResults = {
        loaderData = loaderData,
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
    Skits_Utils:PrintInfo("[FRAME MODEL LOADED]", true)
    Skits_Utils:PrintInfo("Creature Name: " .. loaderData.creatureData.name, true)
    Skits_Utils:PrintInfo("Attempts: " .. loaderData.attemptTotal, true)
    Skits_Utils:PrintInfo("Last Phase: " .. lastPhase, true)
    if loaderData.attemptLastIdIsDisplay then
        Skits_Utils:PrintInfo("Display Id: " .. loaderData.attemptLastId, true)
    else
        Skits_Utils:PrintInfo("Npc Id: " .. loaderData.attemptLastId, true)
    end
end

local function LoadModelStartTimer(loaderData)
    if not loaderData then
        return
    end

    Skits_UI_Utils:LoadModelStopTimer(loaderData)

    local modelFrame = loaderData.loadOptions.modelFrame
    local tloaderData = loaderData
    modelFrame:SetScript("OnModelLoaded", function(self)     
        LoadModelFinished(tloaderData)
    end)        

    local tloaderData = loaderData
    loaderData.loaderHandle = C_Timer.NewTimer(0.2, function()
        Skits_UI_Utils:LoadModelAux(tloaderData)
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
    loadOptions.modelFrame.pauseOn = nil

    Skits_UI_Utils:LoadModelAux(loaderData)
    return loaderData
end


function Skits_UI_Utils:LoadModelAux(loaderData)
    if not loaderData then
        return
    end

    local creatureData = loaderData.creatureData
    if not creatureData then
        return
    end

    --Skits_Utils:PrintInfo("Trying to load a model: " .. creatureData.name .. " | Phase: " .. loaderData.attemptPhase .. " | Attempt: " .. loaderData.attemptTotal, true)

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
    local maxAttempts = 50
    if creatureData.isPlayer then        
        -- Player   
        maxAttempts = 10

        if loaderData.attemptPhase == 1 then    
            if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
                loaderData.attemptCurrent = 1
                loaderData.attemptPhase = 10
            else        
                -- Model for Player
                local isTokenValid = true

                if not creatureData.unitToken then
                    isTokenValid = false
                else
                    local currTokenName = Skits_Utils:GetUnitTokenFullName(creatureData.unitToken)
                    if currTokenName == "" or creatureData.name ~= currTokenName then
                        isTokenValid = false
                    end
                end

                if isTokenValid then
                    -- Unit Token
                    modelFrame:SetUnit(creatureData.unitToken)
                elseif creatureData.raceId then
                    -- Generic Model
                    local genderModels = displayIdsByRaceAndGender[creatureData.raceId]
                    if genderModels then
                        local displayId = genderModels[creatureData.genderId]
                        if displayId then
                            modelFrame:SetDisplayInfo(displayId)
                        end
                    end
                end
            end
        end
    else
        -- NPC
        maxAttempts = 30

        -- We still dont have a model, try fetch it (maybe we got this information after the frame was created)
        if loaderData.attemptPhase == 0 then
            --Skits_Utils:PrintInfo("No display id data for: " .. creatureData.name, true)  

            local newCreatureData, _ = Skits_ID_Store:GetCreatureDataByName(creatureData.name, false)
            if newCreatureData then
                --Skits_Utils:PrintInfo("New display data found for: " .. creatureData.name, true)  
                creatureData.creatureId = newCreatureData.creatureId
                creatureData.displayId = newCreatureData.displayId
                creatureData.ids = newCreatureData.ids
                loaderData.attemptPhase = 1
            else
                if loaderData.attemptCurrent > loaderData.loadModelAttemptsPerIdx then
                    --Skits_Utils:PrintInfo("No display data found for: " .. creatureData.name, true)  
                    loaderData.attemptCurrent = 0
                    loaderData.attemptIdx = 1                    
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
                    loaderData.attemptCurrent = 0
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

                        --Skits_Utils:PrintInfo("Attempting to load id: " .. currId .. " | for: " .. loaderData.creatureData.name, true)                        
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
    end

    -- Fallback Display Id
    if loaderData.attemptPhase == 10 then
        if not LoadModelIsLoaded(loaderData) then
            --Skits_Utils:PrintInfo("Swithing to fallback: " .. loaderData.creatureData.name, true)    
            loaderData.attemptPhase = 99
    
            loaderData.fallback = true
            if loaderData.displayOptions.fallbackId then
                local gender = Skits_UI:GetGenderForName(creatureData.name)
                local displayId = loaderData.displayOptions.fallbackId[gender] or Skits_Style_Utils.fallbackId[gender]
                modelFrame:SetDisplayInfo(displayId)
            end
        end    
    end      
    
    -- Is model already loaded?
    if LoadModelIsLoaded(loaderData) then
        LoadModelFinished(loaderData)
        return 
    end    
    
    -- Timer to check again if the model has been loaded
    if loaderData.attemptPhase < 99 and loaderData.attemptTotal < maxAttempts then
        LoadModelStartTimer(loaderData)
    end        
end

-- ---------------------------------------------------------------------------------
-- Faded Frame
-- ---------------------------------------------------------------------------------

local fadedFrame_texCoords = {
    TOPLEFT = { 0, 1/3, 0, 1/3 },      -- Top-left square
    TOPMID = { 1/3, 2/3, 0, 1/3 },     -- Top-middle square
    TOPRIGHT = { 2/3, 1, 0, 1/3 },     -- Top-right square
    RIGHTMID = { 2/3, 1, 1/3, 2/3 },   -- Right-middle square
    BOTTOMRIGHT = { 2/3, 1, 2/3, 1 },  -- Bottom-right square
    BOTTOMMID = { 1/3, 2/3, 2/3, 1 },  -- Bottom-middle square
    BOTTOMLEFT = { 0, 1/3, 2/3, 1 },   -- Bottom-left square
    LEFTMID = { 0, 1/3, 1/3, 2/3 },    -- Left-middle square
    CENTER = { 1/3, 2/3, 1/3, 2/3 },   -- Center square
}
local function CreateFadedFrame_aux_setTexture(texturePath, frame, alpha, position)
    -- Create the texture
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(texturePath)
    texture:SetAllPoints(frame)
    texture:SetAlpha(alpha)

    -- Get texcoords and rotation for the specified position
    local coords = fadedFrame_texCoords[position]
    if not coords then
        coords = fadedFrame_texCoords["CENTER"]
    end

    -- Apply coords
    local left, right, top, bottom = coords[1], coords[2], coords[3], coords[4]
    texture:SetTexCoord(left, right, top, bottom)

    return texture
end

local function FadedFrame_aux_setParameters(fadedFrame, parameters)
    if not fadedFrame.parameters then
        fadedFrame.parameters = parameters
        return
    end

	for k, v in pairs(parameters) do 
        if k and v then
            fadedFrame.parameters[k] = v
        end
    end 
end

function Skits_UI_Utils:ResizeFadedFrame(fadedFrame, parameters)    
    FadedFrame_aux_setParameters(fadedFrame, parameters)

    local p = fadedFrame.parameters

    local totalWidth = p.contentWidth + p.leftSize + p.rightSize
    local totalHeight = p.contentHeight + p.topSize + p.bottomSize

    fadedFrame.main:SetSize(p.contentWidth, p.contentHeight)
    fadedFrame.content:SetAllPoints(fadedFrame.main)
    fadedFrame.bg:SetAllPoints(fadedFrame.main)

    fadedFrame.center:SetSize(p.contentWidth, p.contentHeight)
    fadedFrame.center:SetPoint("TOPLEFT", fadedFrame.bg, "TOPLEFT", 0, 0)

    local c = fadedFrame.center

    fadedFrame.topLeft:SetSize(p.leftSize, p.topSize)
    fadedFrame.topLeft:SetPoint("BOTTOMRIGHT", c, "TOPLEFT", 0, 0)

    fadedFrame.topMid:SetSize(p.contentWidth, p.topSize)
    fadedFrame.topMid:SetPoint("BOTTOMLEFT", c, "TOPLEFT", 0, 0)    

    fadedFrame.topRight:SetSize(p.rightSize, p.topSize)
    fadedFrame.topRight:SetPoint("BOTTOMLEFT", c, "TOPRIGHT", 0, 0)       

    fadedFrame.rightMid:SetSize(p.rightSize, p.contentHeight)
    fadedFrame.rightMid:SetPoint("BOTTOMLEFT", c, "BOTTOMRIGHT", 0, 0)         
    
    fadedFrame.bottomRight:SetSize(p.rightSize, p.bottomSize)
    fadedFrame.bottomRight:SetPoint("TOPLEFT", c, "BOTTOMRIGHT", 0, 0)      
    
    fadedFrame.bottomMid:SetSize(p.contentWidth, p.bottomSize)
    fadedFrame.bottomMid:SetPoint("TOPLEFT", c, "BOTTOMLEFT", 0, 0)       

    fadedFrame.bottomLeft:SetSize(p.leftSize, p.bottomSize)
    fadedFrame.bottomLeft:SetPoint("TOPRIGHT", c, "BOTTOMLEFT", 0, 0)        

    fadedFrame.leftMid:SetSize(p.leftSize, p.contentHeight)
    fadedFrame.leftMid:SetPoint("TOPRIGHT", c, "TOPLEFT", 0, 0)          
end

function Skits_UI_Utils:CreateFadedFrame(parameters)
    local fadedFrame = {
        parameters = nil,
        main = nil,
        content = nil,
        bg = nil,
        center = nil,
        topLeft = nil,
        topMid = nil,
        topRight = nil,
        rightMid = nil,
        bottomRight = nil,
        bottomMid = nil,
        bottomLeft = nil,
        leftMid = nil,
    }

    -- Set parametrs
    FadedFrame_aux_setParameters(fadedFrame, parameters)

    -- Main Frame: Container of the frame
    fadedFrame.main = CreateFrame("Frame", nil, parameters.parent)

    -- Content Frame: Frame contents
    fadedFrame.content = CreateFrame("Frame", nil, fadedFrame.main)
    fadedFrame.content:SetFrameLevel(100)
    
    -- Background Frame: Background art container
    fadedFrame.bg = CreateFrame("Frame", nil, fadedFrame.main)
    fadedFrame.bg:SetFrameLevel(1)

    -- Background Frame Parts: Parts of the bg container
    fadedFrame.center = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.topLeft = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.topMid = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.topRight = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.rightMid = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.bottomRight = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.bottomMid = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.bottomLeft = CreateFrame("Frame", nil, fadedFrame.bg)    
    fadedFrame.leftMid = CreateFrame("Frame", nil, fadedFrame.bg)    

    -- Set their sizes
    Skits_UI_Utils:ResizeFadedFrame(fadedFrame, parameters)

    -- Create textures
    local texturePath = "Interface/AddOns/Skits/Textures/SkitsFadedFrame.tga"
    local alpha = fadedFrame.parameters.alpha

    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.center, alpha, "CENTER")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.topLeft, alpha, "TOPLEFT")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.topMid, alpha, "TOPMID")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.topRight, alpha, "TOPRIGHT")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.rightMid, alpha, "RIGHTMID")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.bottomRight, alpha, "BOTTOMRIGHT")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.bottomMid, alpha, "BOTTOMMID")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.bottomLeft, alpha, "BOTTOMLEFT")
    CreateFadedFrame_aux_setTexture(texturePath, fadedFrame.leftMid, alpha, "LEFTMID")        

    return fadedFrame
end

function Skits_UI_Utils:ModelFrameSetTargetSize(modelframe, w, h)
    modelframe.targetSize = {
        w = w,
        h = h,
    }

    -- DEBUG: Print when target size is set
    if SkitsDB.debugMode then
        print("[DEBUG] ModelFrameSetTargetSize: w=" .. w .. ", h=" .. h)
    end

    return modelframe
end

function Skits_UI_Utils:ModelFrameSetVisible(modelframe, visible)
    local targetSize = modelframe.targetSize

    if not targetSize then 
        if visible then
            modelframe:Show()
        else
            modelframe:Hide()
        end
    else
        if visible then
            -- DEBUG: Print when size is applied
            if SkitsDB.debugMode then
                print("[DEBUG] ModelFrameSetVisible: Setting size to w=" .. targetSize.w .. ", h=" .. targetSize.h)
            end
            modelframe:SetSize(targetSize.w, targetSize.h)
        else
            modelframe:SetSize(0.01, 0.01)
        end
    end

    return modelframe
end

