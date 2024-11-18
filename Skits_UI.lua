-- Skits_UI.lua
Skits_UI = {}
Skits_UI.portraitZoom = true  -- Set default to true for a chat-like headshot effect
Skits_UI.speakerOrder = true  -- Toggle for left/right positioning
Skits_UI.activeMessages = {}  -- Stores each set of frames with properties
Skits_UI.lastSpeaker = ''
Skits_UI.lastMsgTimestamp = nil
Skits_UI.remainingDuration = 0

Skits_UI.speakers = {}
Skits_UI.speakersTextureFrames = {}
Skits_UI.speakersColors = {}


local textFrameGap = 10
local nextMsgId = 0
local lastMsgData = nil

local animationData = {
    [0] = { id = 0, zoom = 0.90, desc = "Idle" },
    [60] = { id = 60, zoom = 0.90, desc = "Talking" },
    [64] = { id = 64, zoom = 0.90, desc = "Yelling" },
    [65] = { id = 65, zoom = 0.90, desc = "Questioning" },
    [67] = { id = 67, zoom = 0.90, desc = "Weaving" },
    [73] = { id = 73, zoom = 0.90, desc = "Cursing" },
    [77] = { id = 77, zoom = 0.90, desc = "Crying" },
    [185] = { id = 185, zoom = 0.90, desc = "Yes" },
    [186] = { id = 186, zoom = 0.90, desc = "No" },
    
}

function Skits_UI:GetAnimationIDFromText(text)
    local animations = {}

    -- Exclamations
    if text:find("!") ~= nil then
        table.insert(animations, 64)
    end   

    -- Questions
    if text:find("?") ~= nil then
        table.insert(animations, 65)
    end       

    -- Find no
    if text:find("[Nn][Oo][^%w]") ~= nil then
        table.insert(animations, 186)
    end

    -- Find yes
    if text:find("[Yy][Ee[Ss][^%w]") ~= nil then
        table.insert(animations, 185)
    end    

    -- Simple talking, always there
    table.insert(animations, 60)

    -- Idle, pauses between talks
    table.insert(animations, 0)    

    return animations
end

-- Function to set up a looping animation with a locked animation ID
function Skits_UI:SetLoopingAnimation(modelFrame, animationIDs)
    local animationId = animationIDs[math.random(#animationIDs)]
    local animationInfo = animationData[animationId]

    modelFrame:SetAnimation(animationInfo.id)
    modelFrame:SetPortraitZoom(animationInfo.zoom)
    
    local minAngle = 350
    local maxAngle = 370
    local randomAngle = math.random() * (maxAngle - minAngle) + minAngle
    if randomAngle >= 360 then
        randomAngle = randomAngle - 360
    end
    modelFrame:SetFacing(math.rad(randomAngle))

    -- Lock the animation ID in the script by capturing it in a closure    
    modelFrame:SetScript("OnAnimFinished", function(self)
        local animationId = animationIDs[math.random(#animationIDs)]
        local animationInfo = animationData[animationId]

        self:SetAnimation(animationInfo.id)
        self:SetPortraitZoom(animationInfo.zoom)     
    end)
end

-- Function to display 3D model with accompanying text
function Skits_UI:Display3DModelWithText(creatureData, isPlayer, text, duration, r, g, b)
    if not self:ShouldDisplaySpeech() then
        return
    end

    local options = Skits_Options.db
    local speaker = creatureData.name

    -- Get adjusted duration
    duration = duration + 2 -- Add some seconds to the talk, to consider player reaction to the skit and not only the text length.
    duration = math.max(duration, options.speech_duration_min)
    duration = math.min(duration, options.speech_duration_max)

    local currentTime = GetTime()
    local remainingDur = 0
    
    if Skits_UI.lastMsgTimestamp ~= nil then
        remainingDur = math.max(0, self.remainingDuration - (currentTime - Skits_UI.lastMsgTimestamp))

    end
    local adjustedDuration = math.min(options.speech_duration_max * 2, remainingDur + duration)

    -- Update duration tracking
    self.lastMsgTimestamp = currentTime
    self.remainingDuration = adjustedDuration

    -- Update Last Speak Frame
    if self.lastSpeaker == speaker then
        -- Same speaker, check if the last message is still valid
        msgData, i = self:GetMessageData(lastMsgData.msgId)
        
        if msgData ~= nil then
            local success = self:IncreaseText(msgData, text, duration)
            if success == true then
                return
            end
        end
    else
        Skits_UI.speakerOrder = not Skits_UI.speakerOrder
    end

    -- Create Speaker Marker
    self:SpeakerMarker_RemoveFromUnit(speaker)
    self.speakersColors[speaker] = {r,g,b}
    self.speakers[speaker] = true
    self:SpeakerMarker_FindUnitAndAdd(speaker, {r,g,b})

    -- Create Speak Frame
    Skits_UI.lastSpeaker = speaker
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", Skits_Options.db.speech_font_name)
    local fontSize = Skits_Options.db.speech_font_size
    local textAreaWidth = Skits_Options.db.speech_frame_size
    local showSpeakerName = Skits_Options.db.speaker_name_enabled

    textColor = {
        r = r,
        g = g,
        b = b,
    }

    local hasModel = false
    if isPlayer then
        if creatureData.unitToken or creatureData.raceId then
            hasModel = true
        end
    else
        if creatureData.creatureId or creatureData.creatureIds or creatureData.displayIds then
            hasModel = true
        end
    end

    local modelDisplayData = {
        hasModel = hasModel,
        modelSize = modelFrameSize,
        isPlayer = isPlayer,
        creatureId = creatureData.creatureId,
        creatureIds = creatureData.creatureIds,
        displayIds = creatureData.displayIds,
        unitToken = creatureData.unitToken,
        raceId = creatureData.raceId,
        genderId = creatureData.genderId,
    }

    local modelFrameSize = Skits_Options.db.speaker_face_size
    if not Skits_Options.db.speaker_face_enabled then
        modelDisplayData.hasModel = false
    end

    local textFrame, textLabel, speakerNameFrame, modelFrame, borderFrame = Skits_UI_Speaker:CreateSpeakFrame(speaker, text, textColor, modelDisplayData, UIParent, self.speakerOrder, textAreaWidth, font, fontSize, showSpeakerName)
    if modelDisplayData.hasModel then
        modelFrame:SetPosition(0, 0, -0.05)     
        local animationIds = self:GetAnimationIDFromText(text)
        self:SetLoopingAnimation(modelFrame, animationIds)
    end    

    -- Move existing frames up by the height of the new textFrame plus the gap
    if lastMsgData then
        if lastMsgData.textFrame then
            lastMsgData.textFrame:SetPoint("BOTTOM", textFrame, "TOP", 0, textFrameGap)
        end
    end

    -- Store the frames and their properties
    local msgId = nextMsgId
    nextMsgId = nextMsgId + 1

    -- Make msg data
    local msgData = {
        msgId = msgId,
        speaker = speaker,
        textFrame = textFrame,
        textLabel = textLabel,
        modelFrame = modelFrame,
        borderFrame = borderFrame,
        speakerNameFrame = speakerNameFrame,
        timestamp = currentTime,
        duration = adjustedDuration,
        timerHandle = timerHandle,
    }
    lastMsgData = msgData

    -- Set timer to fade
    self:SetMessageTimer(msgData)    

    -- Register Message
    table.insert(self.activeMessages, msgData)    

    -- Trim messages
    self:TrimMessages()
end

function Skits_UI:ShouldDisplaySpeech()
    local options = Skits_Options.db

    -- Check if the overall speech screen display is enabled
    if options.speech_screen_max == 0 then
        return false
    end

    -- Check if we are in combat, and if combat display is enabled
    if Skits_Utils:IsInCombat() and options.speech_screen_combat_max == 0 then
        return false
    end

    -- Check if we are in a solo instance, and if solo instance display is enabled
    if Skits_Utils:IsInInstanceSolo() and options.speech_screen_solo_instance_max == 0 then
        return false
    end

    -- Check if we are in a group instance, and if group instance display is enabled
    if Skits_Utils:IsInInstanceGroup() and options.speech_screen_group_instance_max == 0  then
        return false
    end

    -- If none of the specific cases apply, default to enabling the speech screen
    return true
end

function Skits_UI:IncreaseText(msgData, newText, newDur)
    -- No text frame
    if msgData.textFrame == nil then
        return false
    end

    -- Its expired?
    local expiration = msgData.timestamp + msgData.duration
    if GetTime() >= expiration then
        return false
    end

    local options = Skits_Options.db

    -- Already too big, wall of text
    local textHeight = msgData.textFrame:GetHeight()
    if textHeight > options.speaker_face_size then
        return false
    end

    -- Change text value
    local currText = msgData.textLabel:GetText()
    currText = currText .. "\n\n" .. newText    
    msgData.textLabel:SetText(currText)
    -- Skits_UI_Speaker:UpdateText(oldText, msgData.textFrame, msgData.textLabel, options.speaker_face_enabled)
    -- Readjust frame size
    Skits_UI_Speaker:AdjustSpeakFrameHeight(msgData.textFrame, msgData.textLabel)

    -- Update duration
    msgData.duration = msgData.duration + newDur
    msgData.timerHandle:Cancel()
    Skits_UI:SetMessageTimer(msgData)

    return true
end

function Skits_UI:SetMessageTimer(msgData)
    local currTime = GetTime()
    local enlapsedTime = currTime - msgData.timestamp
    local remainingDuration = msgData.duration - enlapsedTime

    local timerHandle = C_Timer.NewTimer(remainingDuration, function()
        local thisMsgId = msgData.msgId
        Skits_UI:RemoveMessage(thisMsgId)
    end)
    msgData.timerHandle = timerHandle
end

function Skits_UI:GetMessageData(msgId)
    for i, msgData in ipairs(Skits_UI.activeMessages) do
        if msgData and msgData.msgId == msgId then
            return msgData, i
        end
    end
    return nil, 0
end

function Skits_UI:RemoveMessage(msgId)
    -- Get message data
    local msgData, i = Skits_UI:GetMessageData(msgId)

    if not msgData then
        return
    end

    -- Clean message data and frame
    if msgData.textFrame then Skits_UI_Utils:RemoveFrame(msgData.textFrame) Skits_UI.activeMessages[i].textFrame = nil end
    if msgData.modelFrame then Skits_UI_Utils:RemoveFrame(msgData.modelFrame) Skits_UI.activeMessages[i].modelFrame = nil end
    if msgData.borderFrame then Skits_UI_Utils:RemoveFrame(msgData.borderFrame) Skits_UI.activeMessages[i].borderFrame = nil end
    if msgData.speakerNameFrame then Skits_UI_Utils:RemoveFrame(msgData.speakerNameFrame) Skits_UI.activeMessages[i].speakerNameFrame = nil end

    table.remove(Skits_UI.activeMessages, i)

    -- Clean speaker marker
    local msgSpeaker = msgData.speaker
    local speakerStillHasMessages = false
    for i, msgData in ipairs(Skits_UI.activeMessages) do
        if msgData and msgData.spaker == msgSpeaker then
            speakerStillHasMessages = true
            break
        end
    end

    -- Speaker has more to say
    if speakerStillHasMessages then
        return
    end

    -- Speaker has nothing more to say
    self.speakers[msgSpeaker] = nil
    self.speakersColors[msgSpeaker] = nil
    self:SpeakerMarker_RemoveFromUnit(msgSpeaker)
end

function Skits_UI:RemoveOldestMessages(newTableSize)
    local forMax = #Skits_UI.activeMessages
    for i = 1, forMax do
        if #Skits_UI.activeMessages <= newTableSize then
            break
        end        
        if i > #Skits_UI.activeMessages then
            break
        end
        Skits_UI:RemoveMessage(Skits_UI.activeMessages[i].msgId)
    end
end

function Skits_UI:TrimMessages()
    -- Find max messages we can have
    local options = Skits_Options.db
    local maxMessages = options.speech_screen_max
    if Skits_Utils:IsInCombat() then
        maxMessages = math.min(maxMessages, options.speech_screen_combat_max)
    end

    local inInstance, instanceType, playerCount = Skits_Utils:IsInInstance()
    if inInstance then
        if playerCount <= 1 then
            maxMessages = math.min(maxMessages, options.speech_screen_solo_instance_max)
        end
        if playerCount > 1 then
            maxMessages = math.min(maxMessages, options.speech_screen_group_instance_max)
        end
    end

    -- trim it
    Skits_UI:RemoveOldestMessages(maxMessages)
end

-- ---------------------------------------------------------------------
-- SPEAKER MARKER FUNCTIONS 

function Skits_UI:SpeakerMarker_NameplateAdded(nameplateToken)  
    local options = Skits_Options.db
    if options.speaker_marker_size == 0 then
        return
    end

    local unitName = Skits:GetUnitTokenFullName(nameplateToken)
    if not self.speakers[unitName] then
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
    local unitName = Skits:GetUnitTokenFullName(nameplateToken)
    self:SpeakerMarker_RemoveFromUnit(unitName)
end

function Skits_UI:SpeakerMarker_FindUnitAndAdd(unitName)
    local options = Skits_Options.db
    if options.speaker_marker_size == 0 then
        return
    end

    -- Find speaker
    local targetNameplate = nil
    local speakerToken = nil
    for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
        if nameplate.UnitFrame then
            local unittoken = nameplate.UnitFrame.unit
            local unittokenname = Skits:GetUnitTokenFullName(unittoken)
            if unittokenname == unitName then                
                local color = self.speakersColors[unitName]
                self:SpeakerMarker_AddToNameplate(unittoken)
                break
            end
        end
    end   
end

function Skits_UI:SpeakerMarker_AddToNameplate(nameplateToken)
    local options = Skits_Options.db
    if options.speaker_marker_size == 0 then
        return
    end

    local targetNameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken)
    
    if not targetNameplate then
        return
    end  
    
    -- Collect Unit Name
    local unitName = Skits:GetUnitTokenFullName(nameplateToken)    
    local color = self.speakersColors[unitName]    
    
    -- Create a texture frame if it doesn't already exist
    if not targetNameplate.Skits_SpeakerMarker then
        targetNameplate.Skits_SpeakerMarker = targetNameplate:CreateTexture(nil, "OVERLAY")        
        targetNameplate.Skits_SpeakerMarker:SetPoint("TOP", targetNameplate, "BOTTOM", 0, 10)  -- Position above the nameplate
    end 

    local size = options.speaker_marker_size

    -- Set the texture (example uses a standard WoW icon)
    targetNameplate.Skits_SpeakerMarker:SetTexture("interface\\cursor\\crosshair\\speak")
    targetNameplate.Skits_SpeakerMarker:SetSize(size, size)  -- Set the size of the texture
    --targetNameplate.Skits_SpeakerMarker:SetTexCoord(0.125, 0.25, 0.5, 0.625) 
    targetNameplate.Skits_SpeakerMarker:SetVertexColor(color[1], color[2], color[3])   
    targetNameplate.Skits_SpeakerMarker:Show()

    -- Register texture
    self.speakersTextureFrames[unitName] = targetNameplate.Skits_SpeakerMarker
end

function Skits_UI:SpeakerMarker_RemoveFromUnit(unitName)
    local textureFrame = self.speakersTextureFrames[unitName]
    if not textureFrame then
        return
    end

    textureFrame:Hide()
    self.speakersTextureFrames[unitName] = nil
end
