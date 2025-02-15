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


local suffixes_male = {
    ["an"] = 0.05903665814151748,
    ["l"] = 0.04443734015345269,
    ["g"] = 0.044224211423699915,
    ["h"] = 0.03676470588235294,
    ["ar"] = 0.029838022165387893,
    ["in"] = 0.029624893435635125,
    ["m"] = 0.02951832907075874,
    ["ng"] = 0.02951832907075874,
    ["jin"] = 0.029411764705882353,
    ["k"] = 0.022271952259164535,
    ["ver"] = 0.02216538789428815,
    ["ane"] = 0.02216538789428815,
    ["han"] = 0.02216538789428815,
    ["os"] = 0.022058823529411766,
    ["al"] = 0.022058823529411766,
    ["us"] = 0.022058823529411766,
    ["ul"] = 0.022058823529411766,
    ["th"] = 0.022058823529411766,
    ["mer"] = 0.022058823529411766,
    ["ing"] = 0.022058823529411766,
    ["hul"] = 0.022058823529411766,
    ["or"] = 0.014919011082693947,
    ["rd"] = 0.014812446717817562,
    ["ard"] = 0.014812446717817562,
    ["u"] = 0.014705882352941176,
    ["ll"] = 0.014705882352941176,
    ["gg"] = 0.014705882352941176,
    ["of"] = 0.014705882352941176,
    ["im"] = 0.014705882352941176,
    ["am"] = 0.014705882352941176,
    ["ok"] = 0.014705882352941176,
    ["ir"] = 0.014705882352941176,
    ["der"] = 0.014705882352941176,
    ["ros"] = 0.014705882352941176,
    ["all"] = 0.014705882352941176,
    ["ian"] = 0.014705882352941176,
    ["lor"] = 0.014705882352941176,
    ["oof"] = 0.014705882352941176,
    ["gar"] = 0.014705882352941176,
    ["rim"] = 0.014705882352941176,
    ["ang"] = 0.014705882352941176,
    ["din"] = 0.014705882352941176,
    ["eam"] = 0.014705882352941176,
    ["har"] = 0.014705882352941176,
    ["que"] = 0.014705882352941176,
    ["ron"] = 0.014705882352941176,
    ["f"] = 0.007459505541346973,
    ["ue"] = 0.007459505541346973,
    ["ine"] = 0.007459505541346973,
}

local suffixes_female = {
    ["a"] = 0.3112745098039216,
    ["ra"] = 0.15217391304347827,
    ["na"] = 0.043478260869565216,
    ["ara"] = 0.043478260869565216,
    ["ss"] = 0.036231884057971016,
    ["dra"] = 0.036231884057971016,
    ["ner"] = 0.036231884057971016,
    ["ha"] = 0.028985507246376812,
    ["ess"] = 0.028985507246376812,
    ["ind"] = 0.028985507246376812,
    ["tha"] = 0.028985507246376812,
    ["ana"] = 0.028985507246376812,
    ["de"] = 0.028878942881500426,
    ["ia"] = 0.021739130434782608,
    ["la"] = 0.021739130434782608,
    ["era"] = 0.021739130434782608,
    ["lla"] = 0.021739130434782608,
    ["nd"] = 0.021632566069906226,
    ["w"] = 0.014492753623188406,
    ["x"] = 0.014492753623188406,
    ["el"] = 0.014492753623188406,
    ["ow"] = 0.014492753623188406,
    ["ya"] = 0.014492753623188406,
    ["ora"] = 0.014492753623188406,
    ["ade"] = 0.014492753623188406,
    ["per"] = 0.014492753623188406,
    ["oon"] = 0.014492753623188406,
    ["rin"] = 0.014492753623188406,
    ["ide"] = 0.014492753623188406,
    ["ji"] = 0.01438618925831202,
    ["nji"] = 0.01438618925831202,
    ["ras"] = 0.01438618925831202,
}

function Skits_UI:GetGenderForName(fullname)
    -- Split the fullname into words
    local names = {}
    for name in string.gmatch(fullname, "%S+") do
        table.insert(names, name)
    end

    -- Generate suffixes
    local name_suffixes = {}
    for _, name in ipairs(names) do
        for i = 1, 3 do
            local size = i
            local suffix = name
            if size < #name then
                suffix = string.sub(name, -size)
            end
            table.insert(name_suffixes, suffix)
        end
    end

    -- Count male and female votes
    local mvotes = 0
    local fvotes = 0
    for _, suffix in ipairs(name_suffixes) do
        if suffixes_male[suffix] then
            mvotes = mvotes + 1
        end
        if suffixes_female[suffix] then
            fvotes = fvotes + 1
        end
    end

    -- Decide
    if mvotes == fvotes then
        if #fullname % 2 == 1 then
            return "m"
        else
            return "f"
        end
    elseif mvotes > fvotes then
        return "m"
    else
        return "f"
    end
end