-- Skits_Style_Tales.lua

Skits_Style_Tales = {}

local numberOfSlots = 8
local slotLingerTimeSec = 30
local screenCenterGap = 0.25
local modelDist = 150
local textAreaHeight = 100

local needsLayoutReset = true

-- MainFrames
Skits_Style_Tales.mainFrame = CreateFrame("Frame", "SkitsStyleTales", UIParent)
Skits_Style_Tales.textBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.textBgFrameTexture = Skits_Style_Tales.textBgFrame:CreateTexture(nil, "BACKGROUND")
Skits_Style_Tales.modelBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.modelBgFrameTexture = Skits_Style_Tales.modelBgFrame:CreateTexture(nil, "BACKGROUND")
Skits_Style_Tales.textLeftFrame = CreateFrame("Frame", nil, Skits_Style_Tales.textBgFrame)
Skits_Style_Tales.textLeftSpeakerText = Skits_Style_Tales.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textLeftMessageText = Skits_Style_Tales.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textRightFrame = CreateFrame("Frame", nil, Skits_Style_Tales.textBgFrame)
Skits_Style_Tales.textRightSpeakerText = Skits_Style_Tales.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textRightMessageText = Skits_Style_Tales.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

-- Create Speaker Slots
Skits_Style_Tales.speakerSlots = {}
local tempOnLeft = true
for i = 1, numberOfSlots do
    local speakerSlot = {
        idx = i,
        creatureData = nil,
        modelFrame = nil,
        speakTimestamp = GetTime(),
        msgExpireTimestamp = GetTime(),
        msgExpireHandler = nil,
        slotExpireTimestamp = GetTime(),
        slotExpireHandler = nil,
        onLeft = tempOnLeft,
    }
    tempOnLeft = not tempOnLeft

    local modelFrame = CreateFrame("PlayerModel", nil, Skits_Style_Tales.mainFrame)
    speakerSlot.modelFrame = modelFrame
    table.insert(Skits_Style_Tales.speakerSlots, speakerSlot)
end

-- Last Speak Data
Skits_Style_Tales.lastSpeak = {
    slotGeneral = nil,
    slotLeft = nil,
    slotRight = nil,
}

-- Controls
Skits_Style_Tales.controls = {
    skitExpire = GetTime(),
    skitExpireHandler = nil,
}

function Skits_Style_Tales:ResetLayouts()
    local options = Skits_Options.db
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", options.speech_font_name)
    local fontSize = options.speech_font_size
    local modelFrameSize = options.speaker_face_size * 2.5

    -- MainFrame
    Skits_Style_Tales.mainFrame:SetSize(GetScreenWidth(), GetScreenHeight()) -- Full screen
    Skits_Style_Tales.mainFrame:SetPoint("CENTER")
    Skits_Style_Tales.mainFrame:SetFrameStrata("TOOLTIP")
    Skits_Style_Tales.mainFrame:EnableMouse(false) -- Allow clicks to pass through
    Skits_Style_Tales.mainFrame:EnableMouseWheel(false) -- Ignore mouse wheel events

    -- Text Background Frame
    Skits_Style_Tales.textBgFrame:SetSize(GetScreenWidth(), textAreaHeight) -- Full width, height 200
    Skits_Style_Tales.textBgFrame:SetPoint("BOTTOM", 0, 0) -- Positioned at the bottom of the screen
    Skits_Style_Tales.textBgFrame:SetFrameLevel(100)

    -- Add the background texture to textBgFrame
    Skits_Style_Tales.textBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/SkitsStyleTalesTextBg.tga") -- Path to your texture
    Skits_Style_Tales.textBgFrameTexture:SetAllPoints(Skits_Style_Tales.textBgFrame) -- Cover the entire frame
    Skits_Style_Tales.textBgFrameTexture:SetHorizTile(true) -- Enable horizontal tiling
    Skits_Style_Tales.textBgFrameTexture:SetVertTile(false) -- Disable vertical tiling

    -- Model Background Frame
    Skits_Style_Tales.modelBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
    Skits_Style_Tales.modelBgFrame:SetSize(GetScreenWidth(), modelFrameSize + 50) -- Full width, height 200
    Skits_Style_Tales.modelBgFrame:SetPoint("BOTTOM", 0, textAreaHeight - 30) -- Positioned at the bottom of the screen
    Skits_Style_Tales.modelBgFrame:SetFrameLevel(0)

    -- Add the background texture to modelBgFrame
    Skits_Style_Tales.modelBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/SkitsStyleTalesModelBg.tga") -- Path to your texture
    Skits_Style_Tales.modelBgFrameTexture:SetAllPoints(Skits_Style_Tales.modelBgFrame) -- Cover the entire frame
    Skits_Style_Tales.modelBgFrameTexture:SetHorizTile(true) -- Enable horizontal tiling
    Skits_Style_Tales.modelBgFrameTexture:SetVertTile(false) -- Disable vertical tiling

    local textWidth = (Skits_Style_Tales.textBgFrame:GetWidth() / 2) - 30

    -- Create the Left Frame
    Skits_Style_Tales.textLeftFrame:SetSize(textWidth, Skits_Style_Tales.textBgFrame:GetHeight())
    Skits_Style_Tales.textLeftFrame:SetPoint("LEFT", Skits_Style_Tales.textBgFrame, "LEFT", 0, 0)

    -- Create Speaker Text for Left Frame
    Skits_Style_Tales.textLeftSpeakerText:SetPoint("TOP", Skits_Style_Tales.textLeftFrame, "TOP", 0, -10)
    Skits_Style_Tales.textLeftSpeakerText:SetFont(font, fontSize)
    Skits_Style_Tales.textLeftSpeakerText:SetJustifyH("CENTER")
    Skits_Style_Tales.textLeftSpeakerText:SetWordWrap(true)

    -- Create Message Text for Left Frame
    Skits_Style_Tales.textLeftMessageText:SetPoint("CENTER", Skits_Style_Tales.textLeftFrame, "CENTER", 0, 0) -- Centered horizontally and vertically
    Skits_Style_Tales.textLeftMessageText:SetSize(textWidth, Skits_Style_Tales.textBgFrame:GetHeight())
    Skits_Style_Tales.textLeftMessageText:SetFont(font, fontSize)
    Skits_Style_Tales.textLeftMessageText:SetJustifyH("CENTER")
    Skits_Style_Tales.textLeftMessageText:SetWordWrap(true)

    -- Create the Right Frame
    Skits_Style_Tales.textRightFrame:SetSize(textWidth, Skits_Style_Tales.textBgFrame:GetHeight())
    Skits_Style_Tales.textRightFrame:SetPoint("RIGHT", Skits_Style_Tales.textBgFrame, "RIGHT", 0, 0)

    -- Create Speaker Text for Right Frame
    Skits_Style_Tales.textRightSpeakerText:SetPoint("TOP", Skits_Style_Tales.textRightFrame, "TOP", 0, -10)
    Skits_Style_Tales.textRightSpeakerText:SetFont(font, fontSize)
    Skits_Style_Tales.textRightSpeakerText:SetJustifyH("CENTER")
    Skits_Style_Tales.textRightSpeakerText:SetWordWrap(true)

    -- Create Message Text for Right Frame
    Skits_Style_Tales.textRightMessageText:SetPoint("CENTER", Skits_Style_Tales.textRightFrame, "CENTER", 0, 0) -- Centered horizontally and vertically
    Skits_Style_Tales.textRightMessageText:SetSize(textWidth, Skits_Style_Tales.textBgFrame:GetHeight())
    Skits_Style_Tales.textRightMessageText:SetFont(font, fontSize)
    Skits_Style_Tales.textRightMessageText:SetJustifyH("CENTER")
    Skits_Style_Tales.textRightMessageText:SetWordWrap(true)

    -- Slots Model Frames updates
    for i = 1, numberOfSlots do
        slot = Skits_Style_Tales.speakerSlots[i]
        slot.modelFrame:SetSize(modelFrameSize, modelFrameSize)

        -- Find Position
        local posIdx = math.floor((slot.idx + 1)/2) - 1
        local centerGap = (GetScreenWidth() * screenCenterGap) / 2
        local centerDist = centerGap + (modelDist * posIdx)
        if slot.onLeft then
            centerDist = -centerDist
        end

        -- Set Position
        slot.modelFrame:SetSize(modelFrameSize, modelFrameSize)
        slot.modelFrame:SetPoint("BOTTOM", Skits_Style_Tales.mainFrame, "BOTTOM", centerDist, textAreaHeight - 30)        
    end    
end

-- SLOTS FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function SlotClearData(slot)
    slot.creatureData = nil

    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
        slot.msgExpireHandler = nil
    end

    if slot.slotExpireHandler then
        slot.slotExpireHandler:Cancel()
        slot.slotExpireHandler = nil
    end  
end

local function SlotFindOldest(onLeft)
    local oldestIdx = 1
    local oldestTimestamp = nil

    for i = 1, numberOfSlots do
        local slot = Skits_Style_Tales.speakerSlots[i]
        if (onLeft and slot.onLeft) or (not onLeft and not slot.onLeft) then            
            if not oldestTimestamp or slot.speakTimestamp < oldestTimestamp then
                oldestIdx = i
                oldestTimestamp = slot.speakTimestamp
            end
        end
    end

    return Skits_Style_Tales.speakerSlots[oldestIdx]
end

local function SlotFindOneToUse(onLeft)
    for i = 1, numberOfSlots do
        local slot = Skits_Style_Tales.speakerSlots[i]
        if (onLeft and slot.onLeft) or (not onLeft and not slot.onLeft) then                    
            if not slot.creatureData then
                return slot
            end
        end
    end

    return SlotFindOldest(onLeft)
end

local function SlotFindSpeaker(speakerName)
    local currTime = GetTime()
    for i = 1, numberOfSlots do
        local slot = Skits_Style_Tales.speakerSlots[i]
        if slot.creatureData and slot.creatureData.name == speakerName then
            return slot
        end
    end
    return nil
end

local function SlotSetCurrentSpeaker(slot, creatureData)
    Skits_Style_Tales.lastSpeak.slotGeneral = slot

    if slot.onLeft then
        Skits_Style_Tales.lastSpeak.slotLeft = slot
    else
        Skits_Style_Tales.lastSpeak.slotRight = slot
    end

    slot.creatureData = creatureData
end

local function SlotToBack(slot)
    slot.modelFrame:SetFrameLevel(50)
end

local function SlotToFront(slot)    
    slot.modelFrame:SetFrameLevel(55)
    slot.modelFrame:Show()
end

local function SlotExpireMsg(slot)
    -- For now, do nothing
    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
    end
    slot.msgExpireHandler = nil
end

local function SlotExpireSlot(slot)
    slot.modelFrame:Hide()

    SlotExpireMsg(slot)
    SlotClearData(slot)
end



-- MESSAGE FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function MsgAdd(creatureData, textData, slot, duration)
    -- Adjust duration according to remaining time of last message
    local currTime = GetTime()
    local adjustedDuration = duration
    local remainingDuration = 0

    local targetTimestamp = nil
    if slot.onLeft then
        if Skits_Style_Tales.lastSpeak.slotRight then
            targetTimestamp = Skits_Style_Tales.lastSpeak.slotRight.msgExpireTimestamp
        end
    else
        if Skits_Style_Tales.lastSpeak.slotLeft then
            targetTimestamp = Skits_Style_Tales.lastSpeak.slotLeft.msgExpireTimestamp
        end
    end
    if targetTimestamp then
        remainingDuration = targetTimestamp - currTime
        if remainingDuration < 0 then
            remainingDuration = 0
        end        
    end
    adjustedDuration = adjustedDuration + remainingDuration

    -- Update Slot Expire Timestamps
    slot.speakTimestamp = GetTime()
    slot.msgExpireTimestamp = slot.speakTimestamp + adjustedDuration

    -- Update Slot Expire Handlers
    local diff = 0

    diff = slot.msgExpireTimestamp - currTime
    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
    end
    slot.msgExpireHandler = C_Timer.NewTimer(diff, function()
        local lslot = slot
        SlotExpireMsg(slot)
    end)    

    -- Update Skit Expire
    if Skits_Style_Tales.controls.skitExpire < slot.msgExpireTimestamp then
        -- Update Timestamp
        Skits_Style_Tales.controls.skitExpire = slot.msgExpireTimestamp

        -- Update Timer
        diff = Skits_Style_Tales.controls.skitExpire - currTime
        if Skits_Style_Tales.controls.skitExpireHandler then
            Skits_Style_Tales.controls.skitExpireHandler:Cancel()
        end
        Skits_Style_Tales.controls.skitExpireHandler = C_Timer.NewTimer(diff, function()
            Skits_Style_Tales:CloseSkit()
        end)    
    end

    -- Add Message Text
    local speakerTextEle = nil
    local messageTextEle = nil
    if slot.onLeft then
        speakerTextEle = Skits_Style_Tales.textLeftSpeakerText
        messageTextEle = Skits_Style_Tales.textLeftMessageText
    else
        speakerTextEle = Skits_Style_Tales.textRightSpeakerText
        messageTextEle = Skits_Style_Tales.textRightMessageText
    end
    speakerTextEle:SetText(creatureData.name)
    speakerTextEle:SetTextColor(1, 1, 1)

    messageTextEle:SetText(textData.text)
    messageTextEle:SetTextColor(textData.r, textData.g, textData.b)
end


-- MODEL FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function ModelAdd(creatureData, textData, slot, duration)
    local options = Skits_Options.db

    -- Model: Rotation
    local minAngle = 350
    local maxAngle = 370    
    local randomAngle = math.random() * (maxAngle - minAngle) + minAngle
    if randomAngle >= 360 then
        randomAngle = randomAngle - 360
    end
    local rotation = Skits_UI_Utils:GetRadAngle(randomAngle)

    -- Model: display options
    local hourLight = Skits_Style_Utils:GetHourLight()

    local portraitZoom = 0.5
    local rotation = rotation
    local animations = Skits_UI_Utils:GetAnimationIdsFromText(textData.text, true)
    local pauseAfter = math.random() * 2
    local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, animations, hourLight, pauseAfter) 

    -- Model Frame: Load Model
    local loadOptions = {
        modelFrame = slot.modelFrame,
        callback = nil,
    }
    Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)

    -- Set back the previous slot on the same side
    local targetSlot = Skits_Style_Tales.lastSpeak.slotRight
    if slot.onLeft then
        targetSlot = Skits_Style_Tales.lastSpeak.slotLeft
    end
    if targetSlot and targetSlot.idx ~= slot.idx then
        -- Change Light (back should be darker)
        local a = hourLight.ambientIntensity
        local d = hourLight.diffuseIntensity
        hourLight.ambientIntensity = 0.2
        hourLight.diffuseIntensity = 0.2
        targetSlot.modelFrame:SetLight(true, hourLight)
        hourLight.ambientIntensity = a
        hourLight.diffuseIntensity = d

        -- Add a expire timer
        if targetSlot.slotExpireHandler then
            targetSlot.slotExpireHandler:Cancel()
        end
        targetSlot.slotExpireHandler = C_Timer.NewTimer(slotLingerTimeSec, function()
            local tslot = targetSlot
            SlotExpireSlot(tslot)
        end)            

        -- Send to back
        SlotToBack(targetSlot)
    end

    -- Set Current model front
    slot.modelFrame:SetLight(true, hourLight)
    SlotToFront(slot)
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Tales:NewSpeak(creatureData, textData)
    if needsLayoutReset then
        self:ResetLayouts()
        needsLayoutReset = false
    end

    -- Finding a Slot
    -- Is Speaker Still Around?
    local slot = SlotFindSpeaker(creatureData.name)
    if not slot then
        -- Not around, use oldest slot on the opposite side of the last speaker
        local findOnLeft = true
        if Skits_Style_Tales.lastSpeak.slotGeneral then
            findOnLeft = not Skits_Style_Tales.lastSpeak.slotGeneral.onLeft
        end
        slot = SlotFindOneToUse(findOnLeft)
    end

    -- Duration Calculation
    local duration = Skits_Utils:MessageDuration(textData.text)

    -- Message
    MsgAdd(creatureData, textData, slot, duration)

    -- Model
    ModelAdd(creatureData, textData, slot, duration)

    -- Update Controls
    SlotSetCurrentSpeaker(slot, creatureData)

    -- Show
    self:ShowSkit()
    --Skits_Style_Tales.mainFrame:SetAlpha(0.5)
end

function Skits_Style_Tales:CloseSkit()
    -- Reset Slots
    for i = 1, numberOfSlots do
        local speakerSlot = self.speakerSlots[i]
        speakerSlot.modelFrame:ClearModel()
        speakerSlot.modelFrame:Hide()
        SlotClearData(speakerSlot)
    end

    -- Reset Text
    Skits_Style_Tales.textLeftSpeakerText:SetText("")
    Skits_Style_Tales.textLeftMessageText:SetText("")
    Skits_Style_Tales.textRightSpeakerText:SetText("")
    Skits_Style_Tales.textRightMessageText:SetText("")

    -- Reset Controls
    self.lastSpeak.slotGeneral = nil
    self.lastSpeak.slotLeft = nil
    self.lastSpeak.slotRight = nil

    if self.controls.skitExpireHandler then
        self.controls.skitExpireHandler:Cancel()
    end      

    self:HideSkit() 
end

function Skits_Style_Tales:HideSkit()
    Skits_Style_Tales.mainFrame:Hide()
end

function Skits_Style_Tales:ShowSkit()
    Skits_Style_Tales.mainFrame:Show()
end


-- When finish loading this file
Skits_Style_Tales:CloseSkit()