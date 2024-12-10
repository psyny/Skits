-- Skits_Style_Warcraft.lua

Skits_Style_Warcraft = {}
Skits_Style_Warcraft.name = Skits_Style_Utils.enum_styles.WARCRAFT

Skits_Style_Warcraft.speakerOrder = true  -- Toggle for left/right positioning
Skits_Style_Warcraft.activeMessages = {}  -- Stores each set of frames with properties
Skits_Style_Warcraft.lastSpeaker = ''
Skits_Style_Warcraft.lastMsgTimestamp = nil
Skits_Style_Warcraft.remainingDuration = 0
Skits_Style_Warcraft.skitExpireTimestamp = GetTime()

local textFrameGap = 20
local nextMsgId = 0
local lastMsgData = nil

Skits_Style_Warcraft.mainFrame = CreateFrame("Frame", "SkitsStyleWarcraft", UIParent)
Skits_Style_Warcraft.mainFrame:SetAllPoints(UIParent)
Skits_Style_Warcraft.mainFrame:EnableMouse(false)
Skits_Style_Warcraft.mainFrame:EnableMouseWheel(false)


function Skits_Style_Warcraft:CreateSpeakFrame(creatureData, textData, displayOptions, frameSize, parentFrame, altSpeakerSide, textAreaWidth, font, fontSize, showSpeakerName)
    local options = Skits_Options.db

    local speaker = creatureData.name

    -- Create the text frame (new frame always appears at the same position)
    local textFrame = CreateFrame("Frame", nil, parentFrame)
    textFrame:SetSize(textAreaWidth, 100)
    textFrame:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, options.style_warcraft_speech_position_bottom_distance)

    -- Create the main text label
    local textLabel = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textLabel:SetFont(font, fontSize)
    textLabel:SetTextColor(textData.r, textData.g, textData.b)
    textLabel:SetWidth(textAreaWidth)  -- Ensure wrapping
    textLabel:SetWordWrap(true)
	
    self:UpdateText(textData.text, textFrame, textLabel, showSpeakerName)

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
    modelFrame:SetSize(frameSize * 0.75, frameSize)
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

    -- Create and register the speaker frame
    local loadOptions = {
        modelFrame = modelFrame,
        callback = nil,
    }    
    Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)

    modelFrame:Show()    

    return textFrame, textLabel, speakerNameFrame, modelFrame, borderFrame
end

function Skits_Style_Warcraft:UpdateText(text, textFrame, textLabel, showSpeakerName)
	if showSpeakerName then
		textLabel:SetText("\n" .. text)
	else
		textLabel:SetText(text)
	end

    self:AdjustSpeakFrameHeight(textFrame, textLabel)
    return
end

function Skits_Style_Warcraft:AdjustSpeakFrameHeight(textFrame, textLabel)
    local options = Skits_Options.db

    local textHeight = textLabel:GetStringHeight()
    local frameWidth, frameHeight = textFrame:GetSize()
    frameHeight = math.max(options.style_warcraft_speaker_face_size, textHeight)
    textFrame:SetSize(frameWidth, frameHeight)
end

-- ------------------------------------------


function Skits_Style_Warcraft:IncreaseText(msgData, newText, newDur)
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
    if textHeight > options.style_warcraft_speaker_face_size then
        return false
    end

    -- Change text value
    local currText = msgData.textLabel:GetText()
    currText = currText .. "\n\n" .. newText    
    msgData.textLabel:SetText(currText)
    self:AdjustSpeakFrameHeight(msgData.textFrame, msgData.textLabel)

    -- Update duration
    msgData.duration = msgData.duration + newDur
    msgData.timerHandle:Cancel()
    self:SetMessageTimer(msgData)

    return true
end

function Skits_Style_Warcraft:SetMessageTimer(msgData)
    local currTime = GetTime()
    local enlapsedTime = currTime - msgData.timestamp
    local remainingDuration = msgData.duration - enlapsedTime
    
    local skitExpireTimestamp = currTime + remainingDuration
    if skitExpireTimestamp > self.skitExpireTimestamp then
        self.skitExpireTimestamp = skitExpireTimestamp
    end

    local thisMsgId = msgData.msgId
    local timerHandle = C_Timer.NewTimer(remainingDuration, function()        
        self:RemoveMessage(thisMsgId)
    end)
    msgData.timerHandle = timerHandle
end

function Skits_Style_Warcraft:GetMessageData(msgId)
    for i, msgData in ipairs(self.activeMessages) do
        if msgData and msgData.msgId == msgId then
            return msgData, i
        end
    end
    return nil, 0
end

function Skits_Style_Warcraft:RemoveMessage(msgId)
    -- Get message data
    local msgData, i = self:GetMessageData(msgId)

    if not msgData then
        return
    end

    -- Clean message data and frame
    if msgData.textFrame then Skits_UI_Utils:RemoveFrame(msgData.textFrame) self.activeMessages[i].textFrame = nil end
    if msgData.modelFrame then Skits_UI_Utils:RemoveFrame(msgData.modelFrame) self.activeMessages[i].modelFrame = nil end
    if msgData.borderFrame then Skits_UI_Utils:RemoveFrame(msgData.borderFrame) self.activeMessages[i].borderFrame = nil end
    if msgData.speakerNameFrame then Skits_UI_Utils:RemoveFrame(msgData.speakerNameFrame) self.activeMessages[i].speakerNameFrame = nil end

    table.remove(self.activeMessages, i)

    -- Speaker has more to say
    if speakerStillHasMessages then
        return
    end
end

function Skits_Style_Warcraft:RemoveOldestMessages(newTableSize)
    local forMax = #self.activeMessages
    for i = 1, forMax do
        if #self.activeMessages <= newTableSize then
            break
        end        
        if i > #self.activeMessages then
            break
        end
        self:RemoveMessage(self.activeMessages[i].msgId)
    end
end

function Skits_Style_Warcraft:TrimMessages()
    -- Find max messages we can have
    local options = Skits_Options.db
    local maxMessages = options.style_warcraft_speech_screen_max
    if Skits_Utils:IsInCombat() then
        maxMessages = math.min(maxMessages, options.style_warcraft_speech_screen_combat_max)
    end

    local inInstance, instanceType, playerCount = Skits_Utils:IsInInstance()
    if inInstance then
        if playerCount <= 1 then
            maxMessages = math.min(maxMessages, options.style_warcraft_speech_screen_solo_instance_max)
        end
        if playerCount > 1 then
            maxMessages = math.min(maxMessages, options.style_warcraft_speech_screen_group_instance_max)
        end
    end

    -- trim it
    Skits_Style_Warcraft:RemoveOldestMessages(maxMessages)
end

-- Function to set up a looping animation with a locked animation ID
function Skits_Style_Warcraft:SetLoopingAnimation(modelFrame, animationIDs)
    local animationData = {
        modelFrame = modelFrame,
        ids = animationIDs,
        current = 1,
    }
    local animationNum = animationData.ids[animationData.current]
    modelFrame:SetAnimation(animationNum)

    -- Lock the animation ID in the script by capturing it in a closure    
    modelFrame:SetScript("OnAnimFinished", function(self)
        local animationData = animationData
        local animationNum = animationData.ids[animationData.current]
        animationData.current = animationData.current + 1
        if animationData.current > #animationData.ids then
            animationData.current = #animationData.ids
        end

        self:SetAnimation(animationNum) 
    end)
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Warcraft:NewSpeak(creatureData, textData)
    local options = Skits_Options.db
    local speaker = creatureData.name

    -- Get adjusted duration
    local duration = textData.duration

    local currentTime = GetTime()
    local remainingDur = 0
    
    if self.lastMsgTimestamp ~= nil then
        remainingDur = math.max(0, self.remainingDuration - (currentTime - self.lastMsgTimestamp))

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
            local success = self:IncreaseText(msgData, textData.text, duration)
            if success == true then
                return
            end
        end
    else
        self.speakerOrder = not self.speakerOrder
    end

    -- Create Speak Frame
    self.lastSpeaker = speaker
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", options.style_warcraft_speech_font_name)
    local fontSize = options.style_warcraft_speech_font_size
    local textAreaWidth = options.style_warcraft_speech_frame_size
    local showSpeakerName = options.style_warcraft_speaker_name_enabled

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

    local modelFrameSize = options.style_warcraft_speaker_face_size
    if not options.style_warcraft_speaker_face_enabled then
        modelDisplayData.hasModel = false
    end

    local minAngle = 350
    local maxAngle = 370    
    local randomAngle = math.random() * (maxAngle - minAngle) + minAngle
    if randomAngle >= 360 then
        randomAngle = randomAngle - 360
    end
    local rotation = Skits_UI_Utils:GetRadAngle(randomAngle)
    local portraitZoom = 0.9
    local scale = 1.0
    local animations = Skits_UI_Utils:GetAnimationIdsFromText(textData.text, true)
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden        
    local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, nil, nil, fallbackId, fallbackLight) 

    local textFrame, textLabel, speakerNameFrame, modelFrame, borderFrame = Skits_Style_Warcraft:CreateSpeakFrame(creatureData, textData, displayOptions, modelFrameSize, Skits_Style_Warcraft.mainFrame, self.speakerOrder, textAreaWidth, font, fontSize, showSpeakerName)
    modelFrame:SetPosition(0, 0, -0.05)    
    self:SetLoopingAnimation(modelFrame, animations)

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
        timerHandle = nil,
    }
    lastMsgData = msgData

    -- Set timer to fade
    self:SetMessageTimer(msgData)    

    -- Register Message
    table.insert(self.activeMessages, msgData)    

    -- Trim messages
    self:TrimMessages()
end

function Skits_Style_Warcraft:ResetLayout()
    local options = Skits_Options.db
    self.mainFrame:SetAllPoints(UIParent)
    self.mainFrame:SetFrameStrata(options.style_warcraft_strata)
    return
end

function Skits_Style_Warcraft:CloseSkit()
    self:HideSkit() 
end

function Skits_Style_Warcraft:HideSkit()
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    end
end

function Skits_Style_Warcraft:ShowSkit()
    if not self.mainFrame:IsShown() then
        self.mainFrame:Show()
    end
end

function Skits_Style_Warcraft:ShouldDisplay()
    local options = Skits_Options.db

    -- Check if the overall speech screen display is enabled
    if options.style_warcraft_speech_screen_max == 0 then
        return false
    end

    -- Check if we are in combat, and if combat display is enabled
    if Skits_Utils:IsInCombat() and options.style_warcraft_speech_screen_combat_max == 0 then
        return false
    end

    -- Check if we are in a solo instance, and if solo instance display is enabled
    if Skits_Utils:IsInInstanceSolo() and options.style_warcraft_speech_screen_solo_instance_max == 0 then
        return false
    end

    -- Check if we are in a group instance, and if group instance display is enabled
    if Skits_Utils:IsInInstanceGroup() and options.style_warcraft_speech_screen_group_instance_max == 0  then
        return false
    end

    -- If none of the specific cases apply, default to enabling the speech screen
    return true
end

function Skits_Style_Warcraft:IsActive()
    local isActive = false
    if self.skitExpireTimestamp > GetTime() then
        isActive = true
    end
    return isActive
end