-- Skits_UI_Utils.lua
Skits_UI_Utils = {}
local textFrameGap = 20  -- Adjustable gap between frames

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

function Skits_UI_Utils:CreateSpeakFrame(speaker, text, textColor, modelDisplayData, parentFrame, altSpeakerSide, textAreaWidth, font, fontSize, showSpeakerName)
    local options = Skits_Options.db
    local modelSize = modelDisplayData and modelDisplayData.modelSize or 100

    -- Create the text frame (new frame always appears at the same position)
    local textFrame = CreateFrame("Frame", nil, parentFrame)
    textFrame:SetSize(textAreaWidth, 100)
    textFrame:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, options.speech_position_bottom_distance)

    -- Create the main text label
    local textLabel = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textLabel:SetFont(font, fontSize)
    textLabel:SetTextColor(textColor.r, textColor.g, textColor.b)
    textLabel:SetWidth(textAreaWidth)  -- Ensure wrapping
    textLabel:SetWordWrap(true)
	
    Skits_UI_Utils:UpdateText(text, textFrame, textLabel, showSpeakerName)

    -- Align textLabel based on speaker order
    if altSpeakerSide then
        textLabel:SetPoint("TOPLEFT", textFrame, "TOPLEFT")
        textLabel:SetJustifyH("LEFT")
    else
        textLabel:SetPoint("TOPRIGHT", textFrame, "TOPRIGHT")
        textLabel:SetJustifyH("RIGHT")
    end

    -- Create the speaker name frame if enabled
    local speakerNameFrame
    if showSpeakerName then
        speakerNameFrame = CreateFrame("Frame", nil, parentFrame)
        speakerNameFrame:SetSize(textAreaWidth, fontSize + 4)
        speakerNameFrame:SetPoint("TOP", textFrame, "TOP", 0, 4)

        local speakerLabel = speakerNameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        speakerLabel:SetFont(font, fontSize)
        speakerLabel:SetText(speaker)
        speakerLabel:SetTextColor(1, 1, 1)

        -- Align speakerLabel within speakerNameFrame based on speakerOrder
        if altSpeakerSide then
            speakerLabel:SetPoint("LEFT", speakerNameFrame, "LEFT")
            speakerLabel:SetJustifyH("LEFT")
        else
            speakerLabel:SetPoint("RIGHT", speakerNameFrame, "RIGHT")
            speakerLabel:SetJustifyH("RIGHT")
        end
    end

    -- Create the model frame
    local modelFrame = CreateFrame("PlayerModel", nil, parentFrame, "BackdropTemplate")
    modelFrame:SetSize(modelSize * 0.75, modelSize)
    modelFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = nil,
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    modelFrame:SetBackdropColor(0, 0, 0, 0.75)

    -- Position the model frame to the left or right of the text based on speaker order
    modelFrame:SetFacing(0)
    if altSpeakerSide then
        modelFrame:SetPoint("TOPRIGHT", textFrame, "TOPLEFT", -10, 0)
    else
        modelFrame:SetPoint("TOPLEFT", textFrame, "TOPRIGHT", 10, 0)
    end

    -- Create the border frame to follow the model frame with 10px offset
    local borderFrame = CreateFrame("Frame", nil, modelFrame, "BackdropTemplate")
    borderFrame:SetPoint("TOPLEFT", modelFrame, "TOPLEFT", -3, 3)
    borderFrame:SetPoint("BOTTOMRIGHT", modelFrame, "BOTTOMRIGHT", 3, -3)
    borderFrame:SetBackdrop({
        bgFile = nil,
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 8,
    })
    borderFrame:SetBackdropBorderColor(1, 1, 1)

    -- Set model and animation    
    local modelSet = false
    if modelDisplayData.hasModel then        
        if modelDisplayData.isPlayer then
            -- Model for Player
            if modelDisplayData.unitToken then
                -- Unit Token
                modelFrame:SetUnit(modelDisplayData.unitToken)
                modelSet = true
            elseif modelDisplayData.raceId then
                -- Generic Model
                local genderModels = displayIdsByRaceAndGender[modelDisplayData.raceId]
                if genderModels then
                    local displayId = genderModels[modelDisplayData.genderId]
                    if displayId then
                        modelFrame:SetDisplayInfo(displayId)
                        modelSet = true
                    end
                end
            end
        else
            -- NPC

            -- Multiple NPC ids
            if not modelSet and modelDisplayData.creatureIds then                
                for index, value in ipairs(modelDisplayData.creatureIds) do
                    modelFrame:ClearModel()
                    modelFrame:SetCreature(value)
                    local modelFileID = modelFrame:GetModelFileID()
                    if modelFileID and modelFileID > 0 then
                        modelSet = true

                        -- Register this NPC id in our local db. So we can avoid going throu this loop again.
                        creatureData = {
                            name = speaker,
                            creatureId = value,
                        }
                        Skits_ID_Store:SetCreatureData(creatureData, false)
                        break
                    end
                end
            end

            -- Multiple Display ids
            if not modelSet and modelDisplayData.displayIds then                
                for index, value in ipairs(modelDisplayData.displayIds) do
                    modelFrame:ClearModel()
                    modelFrame:SetDisplayInfo(value)
                    local modelFileID = modelFrame:GetModelFileID()
                    if modelFileID and modelFileID > 0 then
                        modelSet = true
                        break
                    end
                end
            end

            -- Single NPC ID
            if not modelSet and modelDisplayData.creatureId then         
                modelFrame:SetCreature(modelDisplayData.creatureId)
                modelSet = true
            end
        end      
    end

    if modelSet then
        modelFrame:SetPortraitZoom(Skits_UI.portraitZoom and 1 or 0)
        modelFrame:Show()  
    else 
        modelFrame:Hide()
    end

    return textFrame, textLabel, speakerNameFrame, modelFrame, borderFrame
end

function Skits_UI_Utils:UpdateText(text, textFrame, textLabel, showSpeakerName)
	if showSpeakerName then
		textLabel:SetText("\n" .. text)
	else
		textLabel:SetText(text)
	end

    Skits_UI_Utils:AdjustSpeakFrameHeight(textFrame, textLabel)
    return
end

function Skits_UI_Utils:AdjustSpeakFrameHeight(textFrame, textLabel)
    local options = Skits_Options.db

    local textHeight = textLabel:GetStringHeight()
    local frameWidth, frameHeight = textFrame:GetSize()
    frameHeight = math.max(options.speaker_face_size, textHeight)
    textFrame:SetSize(frameWidth, frameHeight)
end

function Skits_UI_Utils:RemoveFrame(frame) 
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
end