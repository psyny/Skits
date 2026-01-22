-- Skits_Style_Departure.lua

Skits_Style_Departure = {}
Skits_Style_Departure.name = Skits_Style_Utils.enum_styles.DEPARTURE

local numberOfSlots = 2
local textAreaHeight = 100

local isVisible = false
local needsLayoutReset = true

-- MainFrames
Skits_Style_Departure.mainFrame = CreateFrame("Frame", "SkitsStyleDeparture", UIParent)

-- Model Bg Frames
Skits_Style_Departure.modelLeftBgFrame = CreateFrame("Frame", nil, Skits_Style_Departure.mainFrame)
Skits_Style_Departure.modelLeftBgFrameTexture = Skits_Style_Departure.modelLeftBgFrame:CreateTexture(nil, "BACKGROUND")

Skits_Style_Departure.modelRightBgFrame = CreateFrame("Frame", nil, Skits_Style_Departure.mainFrame)
Skits_Style_Departure.modelRightBgFrameTexture = Skits_Style_Departure.modelRightBgFrame:CreateTexture(nil, "BACKGROUND")

-- Left Text Frames
Skits_Style_Departure.textLeftFrame = CreateFrame("Frame", nil, Skits_Style_Departure.mainFrame)
Skits_Style_Departure.textLeftSpeakerText = Skits_Style_Departure.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Departure.textLeftMessageText = Skits_Style_Departure.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fadedFrameParameters = {
    parent = Skits_Style_Departure.textLeftFrame,
    alpha = 0.9,
    contentHeight = textAreaHeight,
    contentWidth = GetScreenWidth() * 0.5,
    leftSize = 2,
    rightSize = GetScreenWidth() * 0.25,
    topSize = 20,
    bottomSize = 2,
}  
Skits_Style_Departure.textLeftFrameBgBorder = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 

-- Right Text Frames
Skits_Style_Departure.textRightFrame = CreateFrame("Frame", nil, Skits_Style_Departure.mainFrame)
Skits_Style_Departure.textRightSpeakerText = Skits_Style_Departure.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Departure.textRightMessageText = Skits_Style_Departure.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fadedFrameParameters = {
    parent = Skits_Style_Departure.textRightFrame,
    alpha = 0.9,
    contentHeight = textAreaHeight,
    contentWidth = GetScreenWidth() * 0.5,
    leftSize = GetScreenWidth() * 0.25,
    rightSize = 2,
    topSize = 20,
    bottomSize = 2,
}  
Skits_Style_Departure.textRightFrameBgBorder = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 

-- Create Speaker Slots
Skits_Style_Departure.speakerSlots = {}
local tempOnLeft = false
for i = 1, numberOfSlots do
    local speakerSlot = {
        idx = i,
        creatureData = nil,
        modelFrame = nil,
        modelLight = nil,
        speakTimestamp = GetTime(),
        msgExpireTimestamp = GetTime(),    
        msgExpireHandler = nil,
        msgExpireDuration = 0,
        slotExpireTimestamp = GetTime(),
        slotExpireHandler = nil,
        onLeft = tempOnLeft,
        loaderData = nil,
        pendingModelData = nil, -- Stores model data when style is hidden: {creatureData, textData, duration, displayOptions}
        storedModelData = nil, -- Always stores last model data for reloading: {creatureData, textData, displayOptions}
        position = nil,
        positionUpdate = {ox = 0, oy = 0, tx = 0, ty = 0, cd = 0, td = 0, h = nil},
    }
    tempOnLeft = not tempOnLeft

    local modelFrame = CreateFrame("PlayerModel", nil, Skits_Style_Departure.mainFrame)
    speakerSlot.modelFrame = modelFrame
    speakerSlot.modelFrame.slot = speakerSlot
    Skits_UI_Utils:ModelFrameSetVisible(speakerSlot.modelFrame, isVisible)
    table.insert(Skits_Style_Departure.speakerSlots, speakerSlot)
end

-- Speaker Positions
Skits_Style_Departure.speakerPositions = {
    left = {},
    right = {},
    leftOut = {x = 0, y = 0, slot = nil, idx = 0, onLeft = true},
    rightOut = {x = 0, y = 0, slot = nil, idx = 0, onLeft = false},
}
for i = 1, numberOfSlots do
    table.insert(Skits_Style_Departure.speakerPositions.left, {x = 0, y = 0, slot = nil, idx = i, onLeft = true})
    table.insert(Skits_Style_Departure.speakerPositions.right, {x = 0, y = 0, slot = nil, idx = i, onLeft = false})
end

-- Last Speak Data
Skits_Style_Departure.lastSpeak = {
    slotGeneral = nil,
    slotLeft = nil,
    slotRight = nil,
}

-- Controls
Skits_Style_Departure.controls = {
    skitExpire = GetTime(),
    skitExpireHandler = nil,
}

-- Layout Functions --------------------------------
local function LayoutUpdateBackgrounds()
    local options = Skits_Options.db

    -- Update Message Frames
    local mainSlotLeft = Skits_Style_Departure.speakerPositions.left[1].slot
    local mainSlotRight = Skits_Style_Departure.speakerPositions.right[1].slot

    -- Flags
    local hasLeft = mainSlotLeft and mainSlotLeft.creatureData
    local hasRight = mainSlotRight and mainSlotRight.creatureData

    -- Checks
    if not isVisible then
        Skits_Style_Departure.modelLeftBgFrame:Hide()
        Skits_Style_Departure.textLeftFrameBgBorder.bg:Hide()
        Skits_Style_Departure.textLeftFrame:Hide()
    
        Skits_Style_Departure.modelRightBgFrame:Hide()
        Skits_Style_Departure.textRightFrameBgBorder.bg:Hide()
        Skits_Style_Departure.textRightFrame:Hide()

    elseif hasLeft and hasRight then
        Skits_Style_Departure.textLeftFrame:Show()
        Skits_Style_Departure.textLeftFrameBgBorder.bg:Show()        
        Skits_Style_Departure.textRightFrame:Show()
        Skits_Style_Departure.textRightFrameBgBorder.bg:Show()
        
        Skits_Style_Departure.modelLeftBgFrame:Show()
        Skits_Style_Departure.modelLeftBgFrameTexture:Show()
        Skits_Style_Departure.modelRightBgFrame:Show()
        Skits_Style_Departure.modelRightBgFrameTexture:Show()

    elseif hasLeft then
        Skits_Style_Departure.textLeftFrame:Show()
        Skits_Style_Departure.textLeftFrameBgBorder.bg:Show()        
        Skits_Style_Departure.textRightFrame:Hide()
        Skits_Style_Departure.textRightFrameBgBorder.bg:Hide()
        
        Skits_Style_Departure.modelLeftBgFrame:Show()
        Skits_Style_Departure.modelLeftBgFrameTexture:Show()
        Skits_Style_Departure.modelRightBgFrame:Hide()
        Skits_Style_Departure.modelRightBgFrameTexture:Hide()

    elseif hasRight then
        Skits_Style_Departure.textLeftFrame:Hide()
        Skits_Style_Departure.textLeftFrameBgBorder.bg:Hide()        
        Skits_Style_Departure.textRightFrame:Show()
        Skits_Style_Departure.textRightFrameBgBorder.bg:Show()
        
        Skits_Style_Departure.modelLeftBgFrame:Hide()
        Skits_Style_Departure.modelLeftBgFrameTexture:Hide()
        Skits_Style_Departure.modelRightBgFrame:Show()
        Skits_Style_Departure.modelRightBgFrameTexture:Show()         
    end

    -- Click Behavior
    if isVisible and (options.style_departure_click_left ~= "PASS" or options.style_departure_click_right ~= "PASS") then
        Skits_Style_Departure.textLeftFrame:EnableMouse(true)
        Skits_Style_Departure.textRightFrame:EnableMouse(true)

        local function OnClick(Skits_Style_Departure, button)
            if button == "LeftButton" then
                Skits_Style:MouseClickAction(options.style_departure_click_left, Skits_Style_Departure.name)
            elseif button == "RightButton" then
                Skits_Style:MouseClickAction(options.style_departure_click_right, Skits_Style_Departure.name)
            end
        end
    
        Skits_Style_Departure.textLeftFrame:SetScript("OnMouseDown", OnClick)    
        Skits_Style_Departure.textRightFrame:SetScript("OnMouseDown", OnClick)          
    else
        Skits_Style_Departure.textLeftFrame:EnableMouse(false)
        Skits_Style_Departure.textRightFrame:EnableMouse(false)
    end    
end

function Skits_Style_Departure:ResetLayouts()
    if isVisible == false then
        needsLayoutReset = true
        return
    end
    if needsLayoutReset == false then
        return
    end
    needsLayoutReset = false

    local options = Skits_Options.db
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", options.style_departure_speech_font_name)    
    local fontSize = options.style_departure_speech_font_size

    local optionsModelSize = options.style_departure_model_size
    local modelFrameSize = optionsModelSize
    local modelDist = optionsModelSize * 0.2

    -- MainFrame
    self.mainFrame:SetSize(GetScreenWidth(), GetScreenHeight()) -- Full screen
    self.mainFrame:SetPoint("CENTER")
    self.mainFrame:SetFrameStrata(options.style_departure_strata)
    self.mainFrame:EnableMouse(false) -- Allow clicks to pass through
    self.mainFrame:EnableMouseWheel(false) -- Ignore mouse wheel events

    -- Model Background Frame Adjustments --------------------------------------------------

    -- Left
    self.modelLeftBgFrame:SetSize(optionsModelSize * 0.9, optionsModelSize * 0.7)
    self.modelLeftBgFrame:SetPoint("BOTTOMLEFT", 0, 0)
    self.modelLeftBgFrame:SetFrameLevel(50)

    self.modelLeftBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgCircular.tga")
    self.modelLeftBgFrameTexture:SetTexCoord(1, 0, 0, 1)
    self.modelLeftBgFrameTexture:SetAllPoints(self.modelLeftBgFrame)
    self.modelLeftBgFrameTexture:SetHorizTile(false)
    self.modelLeftBgFrameTexture:SetVertTile(false)

    -- Right
    self.modelRightBgFrame:SetSize(optionsModelSize * 0.9, optionsModelSize * 0.7)
    self.modelRightBgFrame:SetPoint("BOTTOMRIGHT", 0, 0)
    self.modelRightBgFrame:SetFrameLevel(50)

    self.modelRightBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgCircular.tga")
    self.modelRightBgFrameTexture:SetAllPoints(self.modelRightBgFrame)
    self.modelRightBgFrameTexture:SetHorizTile(false)
    self.modelRightBgFrameTexture:SetVertTile(false)

    -- Text Frame --------------------------------------------------
    local textWidth = (GetScreenWidth() * 0.25)
    local fadedFrameParameters = nil
    local speakerNameHeight = 0   

    -- Left Frame
    self.textLeftFrame:SetSize(textWidth, textAreaHeight)
    self.textLeftFrame:SetPoint("BOTTOMLEFT", 0, 0)   
    fadedFrameParameters = {
        parent = Skits_Style_Departure.textLeftFrame,
        alpha = 0.1,
        contentHeight = textAreaHeight,
        contentWidth = textWidth,
        leftSize = textWidth,
        rightSize = textWidth,
        topSize = 2,
        bottomSize = 2,
    }  

    Skits_UI_Utils:ResizeFadedFrame(self.textLeftFrameBgBorder, fadedFrameParameters)
    self.textLeftFrameBgBorder.main:SetPoint("BOTTOMLEFT", Skits_Style_Departure.textLeftFrame, "BOTTOMLEFT", 0, 0)   
    
    self.textLeftSpeakerText:SetPoint("LEFT", self.textLeftFrame, "BOTTOMLEFT", 0, 0)
    self.textLeftSpeakerText:SetFont(font, fontSize)
    self.textLeftSpeakerText:SetJustifyH("LEFT")
    self.textLeftSpeakerText:SetJustifyV("MIDDLE")
    self.textLeftSpeakerText:SetWordWrap(true)
    self.textLeftSpeakerText:SetText(" ")
    speakerNameHeight = self.textLeftSpeakerText:GetStringHeight() + 5

    self.textLeftMessageText:SetPoint("BOTTOMLEFT", self.textLeftFrame, "BOTTOMLEFT", 0, 0) -- Centered horizontally and vertically
    self.textLeftMessageText:SetSize(textWidth, textAreaHeight)
    self.textLeftMessageText:SetFont(font, fontSize)
    self.textLeftMessageText:SetJustifyH("LEFT")
    self.textLeftMessageText:SetJustifyV("BOTTOM")
    self.textLeftMessageText:SetWordWrap(true)    

    -- Right Frame
    self.textRightFrame:SetSize(textWidth, textAreaHeight)
    self.textRightFrame:SetPoint("BOTTOMRIGHT", 0, 0)
    fadedFrameParameters = {
        parent = Skits_Style_Departure.textRightFrame,
        alpha = 0.1,
        contentHeight = textAreaHeight,
        contentWidth = textWidth,
        leftSize = textWidth,
        rightSize = textWidth,
        topSize = 2,
        bottomSize = 2,
    }  
    Skits_UI_Utils:ResizeFadedFrame(self.textRightFrameBgBorder, fadedFrameParameters)
    self.textRightFrameBgBorder.main:SetPoint("BOTTOMRIGHT", Skits_Style_Departure.textRightFrame, "BOTTOMRIGHT", 0, 0)   
    
    self.textRightSpeakerText:SetPoint("RIGHT", self.textRightFrame, "BOTTOMRIGHT", 0, 0)
    self.textRightSpeakerText:SetFont(font, fontSize)
    self.textRightSpeakerText:SetJustifyH("RIGHT")
    self.textRightSpeakerText:SetJustifyV("MIDDLE")
    self.textRightSpeakerText:SetWordWrap(true)
    self.textRightSpeakerText:SetText(" ")
    speakerNameHeight = self.textRightSpeakerText:GetStringHeight() + 5

    self.textRightMessageText:SetPoint("BOTTOMRIGHT", self.textRightFrame, "BOTTOMRIGHT", 0, -speakerNameHeight) -- Centered horizontally and vertically
    self.textRightMessageText:SetSize(textWidth, textAreaHeight)
    self.textRightMessageText:SetFont(font, fontSize)
    self.textRightMessageText:SetJustifyH("RIGHT")
    self.textRightMessageText:SetJustifyV("BOTTOM")
    self.textRightMessageText:SetWordWrap(true)    

    -- Text Frame Levels
    self.textLeftFrame:SetFrameLevel(100)
    self.textLeftFrameBgBorder.main:SetFrameLevel(95)
    self.textLeftFrameBgBorder.bg:SetFrameLevel(95)
    self.textRightFrame:SetFrameLevel(100)
    self.textRightFrameBgBorder.main:SetFrameLevel(95)
    self.textRightFrameBgBorder.bg:SetFrameLevel(95)

    -- Slots ------------------------------------

    -- Slots Model Frames updates
    for i = 1, numberOfSlots do
        slot = self.speakerSlots[i]
        Skits_UI_Utils:ModelFrameSetTargetSize(slot.modelFrame, modelFrameSize, modelFrameSize)
        Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
    end    

    -- Slot Positions
    local slotPosY = -(modelFrameSize * 0.35)
    local slotBaseX = -(modelFrameSize * 0.25)
    local slotPosX = 0
    for i = 1, numberOfSlots do
        -- Calculate Position
        slotPosX = slotBaseX + ((i-1) * modelDist * -1)

        -- Register it
        self.speakerPositions.left[i].x = slotPosX
        self.speakerPositions.left[i].y = slotPosY

        self.speakerPositions.right[i].x = -slotPosX
        self.speakerPositions.right[i].y = slotPosY
    end
    self.speakerPositions.leftOut.x = -(modelFrameSize)
    self.speakerPositions.leftOut.y = slotPosY

    self.speakerPositions.rightOut.x = (modelFrameSize)
    self.speakerPositions.rightOut.y = slotPosY
end

-- SLOTS FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function SlotClearData(slot)
    if not slot then
        return
    end

    -- Clear model only if visible (to avoid issues with hidden frames)
    if isVisible then
        slot.modelFrame:SetDisplayInfo(0)
        slot.modelFrame:ClearModel()
    end
    
    slot.creatureData = nil

    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
        slot.msgExpireHandler = nil
    end
    slot.msgExpireDuration = 0   

    if slot.slotExpireHandler then
        slot.slotExpireHandler:Cancel()
        slot.slotExpireHandler = nil
    end  

    if slot.position then
        slot.position.slot = nil
    end
    slot.position = nil

    slot.modelLight = nil

    if slot.positionUpdate.h then
        slot.positionUpdate.h:Cancel()
    end
    slot.positionUpdate.h = nil    

    -- Model Loader Stop
    if slot.loaderData then
        Skits_UI_Utils:LoadModelStopTimer(slot.loaderData)
        slot.loaderData = nil
    end

    -- Clear pending and stored model data
    slot.pendingModelData = nil
    slot.storedModelData = nil
end

local function SlotExpireMsg(slot, hideMessage)
    if hideMessage then
        local speakerTextEle = nil
        local messageTextEle = nil    
        if slot.position and slot.position.onLeft then
            speakerTextEle = Skits_Style_Departure.textLeftSpeakerText
            messageTextEle = Skits_Style_Departure.textLeftMessageText
        else
            speakerTextEle = Skits_Style_Departure.textRightSpeakerText
            messageTextEle = Skits_Style_Departure.textRightMessageText
        end

        speakerTextEle:SetText("")
        messageTextEle:SetText("")
    end

    -- Stop Timer
    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
    end
    slot.msgExpireHandler = nil
end

local function SlotExpireSlot(slot, hideMessage)
    Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, false)

    SlotExpireMsg(slot, hideMessage)
    SlotClearData(slot)

    LayoutUpdateBackgrounds()
end

local function SlotFindOldest()
    local oldestIdx = 1
    local oldestTimestamp = nil

    for i = 1, numberOfSlots do
        local slot = Skits_Style_Departure.speakerSlots[i]      
        if not oldestTimestamp or slot.speakTimestamp < oldestTimestamp then
            oldestIdx = i
            oldestTimestamp = slot.speakTimestamp
        end
    end

    return Skits_Style_Departure.speakerSlots[oldestIdx]
end

local function SlotFindOneToUse(onLeft)
    -- Use a Free Slot
    for i = 1, numberOfSlots do
        local slot = Skits_Style_Departure.speakerSlots[i]
        if not slot.creatureData then
            return slot
        end
    end

    -- Free slot not found, get oldest
    return SlotFindOldest(onLeft)
end

local function SlotFindSpeaker(speakerName)
    local currTime = GetTime()
    for i = 1, numberOfSlots do
        local slot = Skits_Style_Departure.speakerSlots[i]
        if slot.creatureData and slot.creatureData.name == speakerName then
            return slot
        end
    end
    return nil
end

local function SlotSetCurrentSpeaker(slot, creatureData)
    Skits_Style_Departure.lastSpeak.slotGeneral = slot

    if slot.onLeft then
        Skits_Style_Departure.lastSpeak.slotLeft = slot
    else
        Skits_Style_Departure.lastSpeak.slotRight = slot
    end

    slot.creatureData = creatureData
end

local function SlotToBack(slot)
    if not slot then
        return
    end

    local options = Skits_Options.db
    if options.style_departure_previous_speaker_lingertime <= 0 then
        slot.modelFrame:SetFrameLevel(40)
        SlotExpireSlot(slot, false)
    end

    -- Set Light to the Back Version
    local light = slot.modelLight
    if slot.loaderData and slot.loaderData.displayOptions and slot.loaderData.displayOptions.light then
        light = slot.loaderData.displayOptions.light
    end
    local dim = 0.8
    local a = light.ambientIntensity
    local d = light.diffuseIntensity
    light.ambientIntensity = dim
    light.diffuseIntensity = dim
    slot.modelFrame:SetLight(true, light)
    light.ambientIntensity = a
    light.diffuseIntensity = d

    -- Add a expire timer
    if slot.slotExpireHandler then
        slot.slotExpireHandler:Cancel()
    end
    local tslot = slot
    slot.slotExpireHandler = C_Timer.NewTimer(options.style_departure_previous_speaker_lingertime, function()        
        SlotExpireSlot(tslot, false)
    end)   

    -- Set Level
    slot.modelFrame:SetFrameLevel(40)
end

local function SlotToFront(slot)    
    if not slot then
        return
    end

    -- Cancel Slot Expire
    if slot.slotExpireHandler then
        slot.slotExpireHandler:Cancel()
    end
    slot.slotExpireHandler = nil     

    -- Set Light to the Front Version
    slot.modelFrame:SetLight(true, slot.modelLight)

    -- Set Level    
    slot.modelFrame:SetFrameLevel(60)
    Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
end

-- POSITION FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function PositionGetFreeSecondayOriented(onLeft)
    local positionArray = Skits_Style_Departure.speakerPositions.right
    if onLeft then
        positionArray = Skits_Style_Departure.speakerPositions.left
    end

    for i = 2, math.ceil(numberOfSlots) do
        local position = positionArray[i]
        if position.slot == nil then
            return position
        end
    end

    return nil
end


local function PositionGetOldestSecondayOriented(onLeft)
    local positionArray = Skits_Style_Departure.speakerPositions.right
    if onLeft then
        positionArray = Skits_Style_Departure.speakerPositions.left
    end

    local oldestPos = nil
    for i = 2, math.ceil(numberOfSlots) do
        local position = positionArray[i]
        if position.slot then
            if oldestPos == nil or oldestPos.slot.speakTimestamp > position.slot.speakTimestamp then
                oldestPos = position
            end
        end
    end

    return oldestPos
end


local function PositionGetOneSeconday(startWithLeft)
    local pos = nil

    -- First, try to get a free secondary one
    pos = PositionGetFreeSecondayOriented(startWithLeft)
    if pos then
        return pos
    end

    pos = PositionGetFreeSecondayOriented(not startWithLeft)
    if pos then
        return pos
    end

    -- No free secondary found, find the oldest
    pos = PositionGetFreeSecondayOriented(startWithLeft)

    return pos
end


local function PositionGetMainOldest()
    local leftPos = Skits_Style_Departure.speakerPositions.left[1]
    local rightPos = Skits_Style_Departure.speakerPositions.right[1]

    if not leftPos.slot then
        return leftPos
    end

    if not rightPos.slot or rightPos.slot.speakTimestamp < leftPos.slot.speakTimestamp then
        return rightPos
    end

    return leftPos
end

local function PositionSetSlotToPositionUpdate(self, delta)
    local slot = self.slot
    local up = slot.positionUpdate

    up.cd = up.cd + delta

    local ending = false
    if up.cd >= up.td then
        up.cd = up.td
        ending = true
    end

    local cx = Skits_Utils:Interpolation(up.ox, up.tx, 0, up.td, up.cd)
    local cy = Skits_Utils:Interpolation(up.oy, up.ty, 0, up.td, up.cd)

    if slot.position and slot.position.onLeft then
        slot.modelFrame:ClearAllPoints()
        slot.modelFrame:SetPoint("BOTTOMLEFT", Skits_Style_Departure.mainFrame, "BOTTOMLEFT", cx, cy) 
    else
        slot.modelFrame:ClearAllPoints()
        slot.modelFrame:SetPoint("BOTTOMRIGHT", Skits_Style_Departure.mainFrame, "BOTTOMRIGHT", cx, cy) 
    end
    
    if ending then
        self:SetScript("OnUpdate", nil)
    end
end

local function PositionSetSlotToPosition(slot, toPosition, instant)
    local duration = 0.25

    -- Reasons to be instant (besides given parameter)
    if not isVisible then
        instant = true
    elseif duration <= 0 then
        instant = true
    end

    if toPosition.idx == 1 then
        -- Primary position, set to front
        SlotToFront(slot)
    else
        -- Secondary position, set to back
        SlotToBack(slot)
    end

    if instant then
        local up = slot.positionUpdate
        up.tx = toPosition.x
        up.ty = toPosition.y
        up.ox = up.tx
        up.oy = up.ty
        up.cd = 0
        up.td = 0

        if up.h then
            up.h:Cancel()
        end
        up.h = nil

        if slot.position.onLeft then
            slot.modelFrame:ClearAllPoints()
            slot.modelFrame:SetPoint("BOTTOMLEFT", Skits_Style_Departure.mainFrame, "BOTTOMLEFT", toPosition.x, toPosition.y) 
        else
            slot.modelFrame:ClearAllPoints()
            slot.modelFrame:SetPoint("BOTTOMRIGHT", Skits_Style_Departure.mainFrame, "BOTTOMRIGHT", toPosition.x, toPosition.y) 
        end
    else         
        local up = slot.positionUpdate
        up.ox = Skits_Utils:Interpolation(up.ox, up.tx, 0, up.td, up.cd)
        up.oy = Skits_Utils:Interpolation(up.oy, up.ty, 0, up.td, up.cd)     
        up.tx = toPosition.x
        up.ty = toPosition.y
        up.cd = 0
        up.td = duration

        slot.modelFrame:SetScript("OnUpdate", PositionSetSlotToPositionUpdate)

        if up.h then
            up.h:Cancel()
        end      
        local tslot = slot
        local tpos = toPosition        
        up.h = C_Timer.NewTimer(duration, function()
            PositionSetSlotToPosition(tslot, tpos, true)
        end)   
    end
end

local function PositionGoto(slot, position, instant)
    -- Reasons to be instant (besides given parameter)
    if not isVisible then
        instant = true
    elseif not slot.position then
        instant = true
    end

    -- First, clear current position
    local oldPosition = slot.position 
    if oldPosition then
        slot.position.slot = nil
    end

    -- Expire new position slot
    if position.slot then
        SlotExpireSlot(position.slot, false)
    end

    -- Set given slot on new pos
    slot.position = position
    position.slot = slot
    slot.onLeft = position.onLeft

    -- Set to position
    PositionSetSlotToPosition(slot, position, instant)
end


local function PositionSwap(slot1, slot2, instant)
    -- Reasons to be instant (besides given parameter)
    if not isVisible then
        instant = true
    elseif not slot.position then
        instant = true
    end

    -- Remember old positions
    local oldPosition1 = slot1.position
    local oldPosition2 = slot2.position

    -- Swap values
    oldPosition2.slot = slot1
    oldPosition1.slot = slot2
    slot1.position = oldPosition2
    slot2.position = oldPosition1

    -- Set to positions
    PositionSetSlotToPosition(slot1, slot1.position, instant)
    PositionSetSlotToPosition(slot2, slot2.position, instant)
end


-- MESSAGE FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function MsgAdd(creatureData, textData, slot, duration)
    local options = Skits_Options.db

    -- Adjust duration according to remaining time of last message
    local currTime = GetTime()
    local adjustedDuration = duration    
    local maxDuration = duration    

    local lastTimestamp = nil
    if slot.position.onLeft then
        if Skits_Style_Departure.lastSpeak.slotRight then
            lastTimestamp = Skits_Style_Departure.lastSpeak.slotRight.msgExpireTimestamp
            maxDuration = maxDuration + Skits_Style_Departure.lastSpeak.slotRight.msgExpireDuration
        end
    else
        if Skits_Style_Departure.lastSpeak.slotLeft then
            lastTimestamp = Skits_Style_Departure.lastSpeak.slotLeft.msgExpireTimestamp
            maxDuration = maxDuration + Skits_Style_Departure.lastSpeak.slotLeft.msgExpireDuration
        end
    end

    local remainingDuration = 0
    if lastTimestamp then
        remainingDuration = lastTimestamp - currTime
        if remainingDuration < 0 then
            remainingDuration = 0
        end        
    end
    adjustedDuration = adjustedDuration + remainingDuration
    adjustedDuration = math.min(adjustedDuration, maxDuration)

    -- Update Expire Timestamps
    slot.speakTimestamp = GetTime()
    slot.msgExpireTimestamp = slot.speakTimestamp + adjustedDuration
    slot.msgExpireDuration = duration

    -- Update Expire Handlers
    local diff = 0

    diff = slot.msgExpireTimestamp - currTime
    if slot.msgExpireHandler then
        slot.msgExpireHandler:Cancel()
    end
    local lslot = slot
    slot.msgExpireHandler = C_Timer.NewTimer(diff, function()        
        SlotExpireMsg(lslot, false)
    end)    

    -- Update Skit Expire
    if Skits_Style_Departure.controls.skitExpire < slot.msgExpireTimestamp then
        -- Update Timestamp
        Skits_Style_Departure.controls.skitExpire = slot.msgExpireTimestamp

        -- Update Timer
        diff = Skits_Style_Departure.controls.skitExpire - currTime
        if Skits_Style_Departure.controls.skitExpireHandler then
            Skits_Style_Departure.controls.skitExpireHandler:Cancel()
        end
        Skits_Style_Departure.controls.skitExpireHandler = C_Timer.NewTimer(diff, function()
            Skits_Style_Departure:CloseSkit()
        end)    
    end

    -- Add Message Text
    local speakerTextHeight = 0
    local messageTextHeight = 0
    local textWidth = GetScreenWidth() * 0.25
    local fadedFrameParameters = nil
    if slot.position.onLeft then
        Skits_Style_Departure.textLeftSpeakerText:SetText(creatureData.name)
        Skits_Style_Departure.textLeftSpeakerText:SetTextColor(1, 1, 1)
        eleTextHeight = Skits_Style_Departure.textLeftSpeakerText:GetStringHeight()

        Skits_Style_Departure.textLeftMessageText:SetText(textData.text)
        Skits_Style_Departure.textLeftMessageText:SetTextColor(textData.r, textData.g, textData.b)
        Skits_Style_Departure.textLeftMessageText:SetPoint("BOTTOMLEFT", Skits_Style_Departure.textLeftFrame, "BOTTOMLEFT", (eleTextHeight*2), eleTextHeight * 2)
        messageTextHeight = Skits_Style_Departure.textLeftMessageText:GetStringHeight()
        textWidth = math.min(textWidth, Skits_Style_Departure.textLeftMessageText:GetStringWidth())

        Skits_Style_Departure.textLeftSpeakerText:SetPoint("LEFT", Skits_Style_Departure.textLeftFrame, "BOTTOMLEFT", (eleTextHeight*2), messageTextHeight + (eleTextHeight * 3) )

        fadedFrameParameters = {
            parent = Skits_Style_Departure.textLeftFrame,
            alpha = 0.9,
            contentHeight = messageTextHeight + (eleTextHeight*1.8),
            contentWidth = math.max(1, textWidth - (eleTextHeight*5)),
            leftSize = (eleTextHeight*1),
            rightSize = (eleTextHeight*20),
            topSize = 4,
            bottomSize = 4,
        }  
        Skits_UI_Utils:ResizeFadedFrame(Skits_Style_Departure.textLeftFrameBgBorder, fadedFrameParameters)
        Skits_Style_Departure.textLeftFrameBgBorder.main:SetPoint("BOTTOMLEFT", Skits_Style_Departure.textLeftFrame, "BOTTOMLEFT", (eleTextHeight*2), eleTextHeight)     

    else

        Skits_Style_Departure.textRightSpeakerText:SetText(creatureData.name)
        Skits_Style_Departure.textRightSpeakerText:SetTextColor(1, 1, 1)
        eleTextHeight = Skits_Style_Departure.textRightSpeakerText:GetStringHeight()

        Skits_Style_Departure.textRightMessageText:SetText(textData.text)
        Skits_Style_Departure.textRightMessageText:SetTextColor(textData.r, textData.g, textData.b)
        Skits_Style_Departure.textRightMessageText:SetPoint("BOTTOMRIGHT", Skits_Style_Departure.textRightFrame, "BOTTOMRIGHT", -(eleTextHeight*2), eleTextHeight * 2)
        messageTextHeight = Skits_Style_Departure.textRightMessageText:GetStringHeight()
        textWidth = math.min(textWidth, Skits_Style_Departure.textRightMessageText:GetStringWidth())

        Skits_Style_Departure.textRightSpeakerText:SetPoint("RIGHT", Skits_Style_Departure.textRightFrame, "BOTTOMRIGHT", -(eleTextHeight*2), messageTextHeight + (eleTextHeight * 3) )

        fadedFrameParameters = {
            parent = Skits_Style_Departure.textRightFrame,
            alpha = 0.9,
            contentHeight = messageTextHeight + (eleTextHeight*1.8),
            contentWidth = math.max(1, textWidth - (eleTextHeight*5)),
            leftSize = (eleTextHeight*20),
            rightSize = (eleTextHeight*1),
            topSize = 4,
            bottomSize = 4,
        }  
        Skits_UI_Utils:ResizeFadedFrame(Skits_Style_Departure.textRightFrameBgBorder, fadedFrameParameters)
        Skits_Style_Departure.textRightFrameBgBorder.main:SetPoint("BOTTOMRIGHT", Skits_Style_Departure.textRightFrame, "BOTTOMRIGHT", -(eleTextHeight*2), eleTextHeight)    
    end
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
    local hourLight = slot.modelLight

    local portraitZoom = 0
    local rotation = rotation
    local scale = nil
    local animations = {0}
    local posePoint = 0.0
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden    
    if options.style_departure_model_poser then
        animations = Skits_UI_Utils:GetAnimationIdsFromText(textData.text, true)
        posePoint = (math.random() * 1.0)
    end    
    local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, hourLight, posePoint, fallbackId, fallbackLight) 

    -- Always store model data for potential reloading
    slot.storedModelData = {
        creatureData = creatureData,
        textData = textData,
        duration = duration,
        displayOptions = displayOptions,
    }

    -- Only load model if style is visible (SetDisplayInfo/SetUnit don't work well with hidden frames)
    if isVisible then
        -- Model Frame: Load Model
        local loadOptions = {
            modelFrame = slot.modelFrame,
            callback = nil,
        }
        
        local loaderData = Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)
        Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
        slot.loaderData = loaderData
        slot.pendingModelData = nil -- Clear any pending data since we loaded it
    else
        -- Store model data to load when style becomes visible
        slot.pendingModelData = slot.storedModelData
        slot.loaderData = nil
    end
end

-- Skit General Visibility Control --------------------------------------------------------
local function HideSkit()
    if isVisible == false then
        return    
    end
    isVisible = false

    -- Hide all frames
    LayoutUpdateBackgrounds()

    -- Clear models and save state for reloading later
    for i = 1, numberOfSlots do
        slot = Skits_Style_Departure.speakerSlots[i]
        
        -- If slot has active model data, save it as pending for reload
        if slot.creatureData and slot.loaderData then
            -- Use stored model data if available, otherwise mark as needing reload
            if slot.storedModelData then
                slot.pendingModelData = slot.storedModelData
            end
            
            -- Stop loader timer
            Skits_UI_Utils:LoadModelStopTimer(slot.loaderData)
            
            -- Clear model (only works when frame is still technically visible/sized)
            slot.modelFrame:SetDisplayInfo(0)
            slot.modelFrame:ClearModel()
            slot.loaderData = nil
        end
        
        Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
    end 

    return
end

local function ShowSkit()
    if isVisible == true then
        return    
    end
    isVisible = true

    Skits_Style_Departure:ResetLayouts()        

    -- Show all frames
    LayoutUpdateBackgrounds()

    -- Show model slots and load pending models
    local currTime = GetTime()
    for i = 1, numberOfSlots do
        slot = Skits_Style_Departure.speakerSlots[i]
        if slot then
            Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)

            -- Check if we have pending model data to load
            if slot.pendingModelData then
                -- Check if message hasn't expired
                if slot.msgExpireTimestamp and slot.msgExpireTimestamp > currTime then
                    -- Reload the model
                    local pending = slot.pendingModelData
                    
                    -- Use stored display options or regenerate if needed
                    local displayOptions = pending.displayOptions
                    if not displayOptions then
                        local options = Skits_Options.db
                        local hourLight = slot.modelLight or Skits_Style_Utils:GetHourLight()
                        
                        local minAngle = 350
                        local maxAngle = 370    
                        local randomAngle = math.random() * (maxAngle - minAngle) + minAngle
                        if randomAngle >= 360 then
                            randomAngle = randomAngle - 360
                        end
                        local rotation = Skits_UI_Utils:GetRadAngle(randomAngle)
                        
                        local portraitZoom = 0
                        local scale = nil
                        local animations = {0}
                        local posePoint = 0.0
                        local fallbackId = Skits_Style_Utils.fallbackId
                        local fallbackLight = Skits_Style_Utils.lightPresets.hidden    
                        if options.style_departure_model_poser then
                            animations = Skits_UI_Utils:GetAnimationIdsFromText(pending.textData.text, true)
                            posePoint = (math.random() * 1.0)
                        end    
                        displayOptions = Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, hourLight, posePoint, fallbackId, fallbackLight)
                    end
                    
                    -- Load model now that we're visible
                    local loadOptions = {
                        modelFrame = slot.modelFrame,
                        callback = nil,
                    }
                    
                    slot.loaderData = Skits_UI_Utils:LoadModel(pending.creatureData, displayOptions, loadOptions)
                    slot.pendingModelData = nil -- Clear pending data
                else
                    -- Message expired, clear pending data
                    slot.pendingModelData = nil
                    slot.storedModelData = nil
                end
            elseif slot.loaderData then
                -- Model was already loaded, just reappear
                Skits_UI_Utils:LoadReAppeared(slot.loaderData)
            end            
        end
    end   

    return
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Departure:NewSpeak(creatureData, textData)
    self:ResetLayouts()

    -- Duration
    local duration = textData.duration

    -- Model Light for current hour
    local hourLight = Skits_Style_Utils:GetHourLight()

    -- Finding a Slot and Position it
    -- Is Speaker StILL Slotted?
    local slot = SlotFindSpeaker(creatureData.name)
    local mainOldestPos = nil
    if slot then
        slot.modelLight = hourLight

        local mainSlotLeft = Skits_Style_Departure.speakerPositions.left[1].slot
        local mainSlotRight = Skits_Style_Departure.speakerPositions.right[1].slot

        if (mainSlotLeft and mainSlotLeft.idx == slot.idx) or (mainSlotRight and mainSlotRight.idx == slot.idx) then
            -- Aready in a main position
            -- There is anything to be done? I dont think so
        else
            -- Not on main positions
            -- Get Oldest Primary/Main position
            mainOldestPos = PositionGetMainOldest()

            --  Find a new position for the oldest
            local newPosToMainOldest = PositionGetFreeSecondayOriented(mainOldestPos.onLeft)
            
            -- Do we have a free position for the oldest?
            if newPosToMainOldest then
                -- Yes, send the main oldest to the new free position
                PositionGoto(mainOldestPos.slot, newPosToMainOldest, false)
                PositionGoto(slot, mainOldestPos, false)
            else
                -- No, swap with curr speaker
                PositionSwap(slot, mainOldestPos.slot, false)
            end
        end

        MsgAdd(creatureData, textData, slot, duration)
        ModelAdd(creatureData, textData, slot, duration)     
    else
        -- Find a slot to use
        local findOnLeft = false
        if self.lastSpeak.slotGeneral then
            findOnLeft = not self.lastSpeak.slotGeneral.onLeft
        end
        slot = SlotFindOneToUse(findOnLeft)

        -- Expire current slot
        SlotExpireSlot(slot, false)

        -- Set Current Slot Creature Data
        slot.modelLight = hourLight
        slot.creatureData = creatureData

        -- New speak, it will occupy either left or right main positions.   
        mainOldestPos = PositionGetMainOldest()        

        -- Instantly send current slot to an outside position
        local outsidePos = Skits_Style_Departure.speakerPositions.rightOut
        if mainOldestPos.onLeft then
            outsidePos = Skits_Style_Departure.speakerPositions.leftOut
        end
        PositionGoto(slot, outsidePos, true)

        -- Message and Model updates after slot is pre positioned
        MsgAdd(creatureData, textData, slot, duration)
        ModelAdd(creatureData, textData, slot, duration)

        -- if theres a creature at the main oldest, deal with it
        if mainOldestPos.slot then
            -- Find a new position to existing creature on slot
            local newPosToExisting = PositionGetOneSeconday(mainOldestPos.onLeft)       
            PositionGoto(mainOldestPos.slot, newPosToExisting, false)
        end

        -- Move current into its mainOldestPos
        PositionGoto(slot, mainOldestPos, false)
    end

    -- Update messsage
    LayoutUpdateBackgrounds()

    -- Update Controls
    SlotSetCurrentSpeaker(slot, creatureData)
end

function Skits_Style_Departure:ResetLayout()
    self:ResetLayouts()
end


function Skits_Style_Departure:CloseSkit()
    -- Reset Slots
    for i = 1, numberOfSlots do
        local speakerSlot = self.speakerSlots[i]
        Skits_UI_Utils:ModelFrameSetVisible(speakerSlot.modelFrame, false)
        SlotClearData(speakerSlot)
    end

    -- Reset Slot Positions
    for i = 1, numberOfSlots do
        self.speakerPositions.left[i].slot = nil
        self.speakerPositions.right[i].slot = nil
    end   
    self.speakerPositions.leftOut.slot = nil 
    self.speakerPositions.rightOut.slot = nil 

    -- Reset Text
    self.textLeftSpeakerText:SetText(" ")
    self.textLeftMessageText:SetText(" ")
    self.textRightSpeakerText:SetText(" ")
    self.textRightMessageText:SetText(" ")

    -- Reset Controls
    self.lastSpeak.slotGeneral = nil
    self.lastSpeak.slotLeft = nil
    self.lastSpeak.slotRight = nil

    if self.controls.skitExpireHandler then
        self.controls.skitExpireHandler:Cancel()
        self.controls.skitExpireHandler = nil
    end      

    self:HideSkit() 
end

function Skits_Style_Departure:HideSkit()
    HideSkit()
end

function Skits_Style_Departure:ShowSkit()
    ShowSkit()
end

function Skits_Style_Departure:ShouldDisplay()
    local options = Skits_Options.db
    return true
end

function Skits_Style_Departure:IsActive()
    local isActive = false
    if self.controls.skitExpire > GetTime() then
        isActive = true
    end
    return isActive
end

function Skits_Style_Departure:CancelSpeaker(creatureData)
    local slot = SlotFindSpeaker(creatureData.name)

    if slot then
        local mainSlotLeft = self.speakerPositions.left[1].slot
        local mainSlotRight = self.speakerPositions.right[1].slot

        if (mainSlotLeft and mainSlotLeft.idx == slot.idx) or (mainSlotRight and mainSlotRight.idx == slot.idx) then
            SlotExpireSlot(slot, true)

            -- No more speakers left
            if (not mainSlotLeft or not mainSlotLeft.creatureData) and (not mainSlotRight or not mainSlotRight.creatureData) then
                -- Close Skit
                if self.controls.skitExpireHandler then
                    self.controls.skitExpireHandler:Cancel()
                end
                self:CloseSkit()
            end            
        end
    end
end