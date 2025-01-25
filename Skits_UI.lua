-- Skits_UI.lua
Skits_UI = {}
Skits_UI.speakerData = {}

-- Function to display 3D model with accompanying text
function Skits_UI:DisplaySkits(creatureData, textData, r, g, b)
    local options = Skits_Options.db
    local speaker = creatureData.name

    -- Get adjusted duration
    local duration = Skits_Utils:MessageDuration(textData.text) / (textData.speed or 1)

    -- Compile text data
    textData.duration = duration
    textData.r = r
    textData.g = g
    textData.b = b
    textData.speed = textData.speed or 1

    -- Create Skits
    Skits_Style:NewSpeak(creatureData, textData)

    -- Speaker Data
    local speakerData = self.speakerData[speaker]
    if not speakerData then
        speakerData = {
            name = speaker,
            textData = nil,
            expireHandler = nil,
            markerTextureFrame = nil,
        }
        self.speakerData[speaker] = speakerData
    end
    speakerData.textData = textData

    -- Create Speaker Marker
    self:SpeakerMarker_RemoveFromUnit(speaker)
    self:SpeakerMarker_FindUnitAndAdd(speaker, {r,g,b})

    -- Expire Speaker for this context (not for skits)
    if speakerData.expireHandler then
        speakerData.expireHandler:Cancel()
    end
    speakerData.expireHandler = C_Timer.NewTimer(duration, function()
        local tSpeaker = speaker
        Skits_UI:ExpireSpeaker(tSpeaker)
    end)
end

function Skits_UI:ExpireSpeaker(speaker)
    local speakerData = self.speakerData[speaker]
    if not speakerData then
        return
    end

    -- Stop Timer
    if speakerData.expireHandler then
        speakerData.expireHandler:Cancel()
        speakerData.expireHandler = nil
    end

    -- Speaker Marker Removal
    self:SpeakerMarker_RemoveFromUnit(speakerData.name)

    self.speakerData[speaker] = nil
end

-- ---------------------------------------------------------------------
-- SPEAKER MARKER FUNCTIONS 

function Skits_UI:SpeakerMarker_NameplateAdded(nameplateToken)  
    local options = Skits_Options.db
    if options.style_general_speaker_marker_size == 0 then
        return
    end

    local unitName = Skits_Utils:GetUnitTokenFullName(nameplateToken)
    if not self.speakerData[unitName] then
        return 
    end

    -- Get Nameplate
    local targetNameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken)
    if not targetNameplate then
        return
    end

    -- Remove existing (if any)
    self:SpeakerMarker_RemoveFromUnit(unitName)

    -- Add to new
    Skits_UI:SpeakerMarker_AddToNameplate(nameplateToken)
end

function Skits_UI:SpeakerMarker_NameplateRemoved(nameplateToken)
    local unitName = Skits_Utils:GetUnitTokenFullName(nameplateToken)
    self:SpeakerMarker_RemoveFromUnit(unitName)
end

function Skits_UI:SpeakerMarker_FindUnitAndAdd(unitName)
    local options = Skits_Options.db
    if options.style_general_speaker_marker_size == 0 then
        return
    end

    -- Find speaker
    local targetNameplate = nil
    local speakerToken = nil
    for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
        if nameplate.UnitFrame then
            local unittoken = nameplate.UnitFrame.unit
            local unittokenname = Skits_Utils:GetUnitTokenFullName(unittoken)
            if unittokenname == unitName then    
                self:SpeakerMarker_AddToNameplate(unittoken)
                break
            end
        end
    end   
end

function Skits_UI:SpeakerMarker_AddToNameplate(nameplateToken)
    local options = Skits_Options.db
    if options.style_general_speaker_marker_size == 0 then
        return
    end

    local targetNameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken)
    
    if not targetNameplate then
        return
    end  
    
    -- Collect Unit Name
    local unitName = Skits_Utils:GetUnitTokenFullName(nameplateToken)    
    
    -- speaker  Data
    local speakerData = self.speakerData[unitName]
    if not speakerData then
        return 
    end   

    -- Create a texture frame if it doesn't already exist
    if not targetNameplate.Skits_SpeakerMarker then
        targetNameplate.Skits_SpeakerMarker = targetNameplate:CreateTexture(nil, "OVERLAY")        
        targetNameplate.Skits_SpeakerMarker:SetPoint("TOP", targetNameplate, "BOTTOM", 0, 10)  -- Position above the nameplate
    end 

    local size = options.style_general_speaker_marker_size

    -- Set the texture (example uses a standard WoW icon)
    targetNameplate.Skits_SpeakerMarker:SetTexture("interface\\cursor\\crosshair\\speak")
    targetNameplate.Skits_SpeakerMarker:SetSize(size, size)  -- Set the size of the texture
    --targetNameplate.Skits_SpeakerMarker:SetTexCoord(0.125, 0.25, 0.5, 0.625) 
    targetNameplate.Skits_SpeakerMarker:SetVertexColor(speakerData.textData.r, speakerData.textData.g, speakerData.textData.b)   
    targetNameplate.Skits_SpeakerMarker:Show()

    -- Register texture
    speakerData.markerTextureFrame = targetNameplate.Skits_SpeakerMarker
end

function Skits_UI:SpeakerMarker_RemoveFromUnit(unitName)
    local speakerData = self.speakerData[unitName]
    if not speakerData then
        return 
    end   
    
    local textureFrame = speakerData.markerTextureFrame
    if not textureFrame then
        return 
    end   
    
    textureFrame:Hide()
    speakerData.markerTextureFrame = nil
end
