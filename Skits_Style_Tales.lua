-- Skits_Style_Tales.lua

Skits_Style_Tales = {}
Skits_Style_Tales.name = Skits_Style_Utils.enum_styles.TALES

local numberOfSlots = 8
local slotLingerTimeSec = 30
local screenCenterGap = 0.25
local modelDist = 150
local textAreaHeight = 70

local needsLayoutReset = true

local isVisible = true

-- MainFrames
Skits_Style_Tales.mainFrame = CreateFrame("Frame", "SkitsStyleTales", UIParent)

-- Model Bg Frames
Skits_Style_Tales.modelFullBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.modelFullBgFrameTexture = Skits_Style_Tales.modelFullBgFrame:CreateTexture(nil, "BACKGROUND")

Skits_Style_Tales.modelLeftBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.modelLeftBgFrameTexture = Skits_Style_Tales.modelLeftBgFrame:CreateTexture(nil, "BACKGROUND")
Skits_Style_Tales.modelLeftBgBorderFrame = CreateFrame("Frame", nil, Skits_Style_Tales.modelLeftBgFrame)
Skits_Style_Tales.modelLeftBgBorderFrameTexture = Skits_Style_Tales.modelLeftBgBorderFrame:CreateTexture(nil, "BACKGROUND")

Skits_Style_Tales.modelRightBgFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.modelRightBgFrameTexture = Skits_Style_Tales.modelLeftBgFrame:CreateTexture(nil, "BACKGROUND")
Skits_Style_Tales.modelRightBgBorderFrame = CreateFrame("Frame", nil, Skits_Style_Tales.modelRightBgFrame)
Skits_Style_Tales.modelRightBgBorderFrameTexture = Skits_Style_Tales.modelRightBgBorderFrame:CreateTexture(nil, "BACKGROUND")

-- Full Text Frame
local fadedFrameParameters = nil
Skits_Style_Tales.textFullFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.textFullFrameBg = CreateFrame("Frame", nil, Skits_Style_Tales.textFullFrame)
Skits_Style_Tales.textFullFrameBgTexture = Skits_Style_Tales.textFullFrameBg:CreateTexture(nil, "BACKGROUND")

fadedFrameParameters = {
    parent = Skits_Style_Tales.textFullFrame,
    alpha = 1.0,
    contentHeight = textAreaHeight,
    contentWidth = GetScreenWidth(),
    leftSize = 2,
    rightSize = 2,
    topSize = 20,
    bottomSize = 2,
}  
Skits_Style_Tales.textFullFrameBgBorder = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 

-- Left Text Frames
Skits_Style_Tales.textLeftFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.textLeftSpeakerText = Skits_Style_Tales.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textLeftMessageText = Skits_Style_Tales.textLeftFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textLeftFrameBg = CreateFrame("Frame", nil, Skits_Style_Tales.textLeftFrame)
Skits_Style_Tales.textLeftFrameBgTexture = Skits_Style_Tales.textLeftFrameBg:CreateTexture(nil, "BACKGROUND")
fadedFrameParameters = {
    parent = Skits_Style_Tales.textLeftFrame,
    alpha = 1.0,
    contentHeight = textAreaHeight,
    contentWidth = GetScreenWidth() * 0.5,
    leftSize = 2,
    rightSize = GetScreenWidth() * 0.25,
    topSize = 20,
    bottomSize = 2,
}  
Skits_Style_Tales.textLeftFrameBgBorder = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 

-- Right Text Frames
Skits_Style_Tales.textRightFrame = CreateFrame("Frame", nil, Skits_Style_Tales.mainFrame)
Skits_Style_Tales.textRightSpeakerText = Skits_Style_Tales.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textRightMessageText = Skits_Style_Tales.textRightFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Skits_Style_Tales.textRightFrameBg = CreateFrame("Frame", nil, Skits_Style_Tales.textRightFrame)
Skits_Style_Tales.textRightFrameBgTexture = Skits_Style_Tales.textRightFrameBg:CreateTexture(nil, "BACKGROUND")
fadedFrameParameters = {
    parent = Skits_Style_Tales.textRightFrame,
    alpha = 1.0,
    contentHeight = textAreaHeight,
    contentWidth = GetScreenWidth() * 0.5,
    leftSize = GetScreenWidth() * 0.25,
    rightSize = 2,
    topSize = 20,
    bottomSize = 2,
}  
Skits_Style_Tales.textRightFrameBgBorder = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 

-- Create Speaker Slots
Skits_Style_Tales.speakerSlots = {}
local tempOnLeft = true
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
        position = nil,
        positionUpdate = {ox = 0, oy = 0, tx = 0, ty = 0, cd = 0, td = 0, h = nil},
    }
    tempOnLeft = not tempOnLeft

    local modelFrame = CreateFrame("PlayerModel", nil, Skits_Style_Tales.mainFrame)
    speakerSlot.modelFrame = modelFrame
    speakerSlot.modelFrame.slot = speakerSlot
    Skits_UI_Utils:ModelFrameSetVisible(speakerSlot.modelFrame, isVisible)
    table.insert(Skits_Style_Tales.speakerSlots, speakerSlot)
end

-- Speaker Positions
Skits_Style_Tales.speakerPositions = {
    left = {},
    right = {},
    leftOut = {x = 0, y = 0, slot = nil, idx = 0, onLeft = true},
    rightOut = {x = 0, y = 0, slot = nil, idx = 0, onLeft = false},
}
for i = 1, numberOfSlots do
    table.insert(Skits_Style_Tales.speakerPositions.left, {x = 0, y = 0, slot = nil, idx = i, onLeft = true})
    table.insert(Skits_Style_Tales.speakerPositions.right, {x = 0, y = 0, slot = nil, idx = i, onLeft = false})
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
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", options.style_tales_speech_font_name)    
    local fontSize = options.style_tales_speech_font_size

    local optionsModelSize = options.style_tales_model_size
    local modelBgSize = (optionsModelSize * 0.5) + 50
    local modelFrameSize = optionsModelSize
    modelDist = GetScreenWidth() / (numberOfSlots)

    -- MainFrame
    self.mainFrame:SetSize(GetScreenWidth(), GetScreenHeight()) -- Full screen
    self.mainFrame:SetPoint("CENTER")
    self.mainFrame:SetFrameStrata(options.style_tales_strata)
    self.mainFrame:EnableMouse(false) -- Allow clicks to pass through
    self.mainFrame:EnableMouseWheel(false) -- Ignore mouse wheel events

    -- Model Background Frame Adjustments --------------------------------------------------

    -- Full 
    self.modelFullBgFrame:SetSize(GetScreenWidth(), modelBgSize)
    self.modelFullBgFrame:SetPoint("BOTTOMLEFT", 0, textAreaHeight)
    self.modelFullBgFrame:SetFrameLevel(50)

    self.modelFullBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgLinear.tga")
    self.modelFullBgFrameTexture:SetAllPoints(self.modelFullBgFrame)
    self.modelFullBgFrameTexture:SetHorizTile(true)
    self.modelFullBgFrameTexture:SetVertTile(false)

    -- Left
    self.modelLeftBgFrame:SetSize(GetScreenWidth() * 0.5, modelBgSize)
    self.modelLeftBgFrame:SetPoint("BOTTOMLEFT", 0, textAreaHeight)
    self.modelLeftBgFrame:SetFrameLevel(50)

    self.modelLeftBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgLinear.tga")
    self.modelLeftBgFrameTexture:SetAllPoints(self.modelLeftBgFrame)
    self.modelLeftBgFrameTexture:SetHorizTile(true)
    self.modelLeftBgFrameTexture:SetVertTile(false)

    self.modelLeftBgBorderFrame:SetSize(GetScreenWidth() * 0.2, modelBgSize)
    self.modelLeftBgBorderFrame:SetPoint("BOTTOMLEFT", self.modelLeftBgFrame, "BOTTOMRIGHT", 0, 0)
    self.modelLeftBgBorderFrame:SetFrameLevel(50)

    self.modelLeftBgBorderFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgLinearFade.tga")
    self.modelLeftBgBorderFrameTexture:SetAllPoints(self.modelLeftBgBorderFrame)
    self.modelLeftBgBorderFrameTexture:SetHorizTile(false)
    self.modelLeftBgBorderFrameTexture:SetVertTile(false)

    -- Right
    self.modelRightBgFrame:SetSize(GetScreenWidth() * 0.5, modelBgSize)
    self.modelRightBgFrame:SetPoint("BOTTOMRIGHT", 0, textAreaHeight)
    self.modelRightBgFrame:SetFrameLevel(50)

    self.modelRightBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgLinear.tga")
    self.modelRightBgFrameTexture:SetAllPoints(self.modelRightBgFrame)
    self.modelRightBgFrameTexture:SetHorizTile(true)
    self.modelRightBgFrameTexture:SetVertTile(false)

    self.modelRightBgBorderFrame:SetSize(GetScreenWidth() * 0.2, modelBgSize)
    self.modelRightBgBorderFrame:SetPoint("BOTTOMRIGHT", self.modelRightBgFrame, "BOTTOMLEFT", 0, 0)
    self.modelRightBgBorderFrame:SetFrameLevel(50)

    self.modelRightBgBorderFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/ModelBgLinearFade.tga")
    self.modelRightBgBorderFrameTexture:SetAllPoints(self.modelRightBgBorderFrame)
    self.modelRightBgBorderFrameTexture:SetHorizTile(false)
    self.modelRightBgBorderFrameTexture:SetVertTile(false)    

    -- Text Frame Adjustments --------------------------------------------------
    local textWidth = (GetScreenWidth() * 0.5) - 40
    local fadedFrameParameters = nil
    local speakerNameHeight = 0

    -- Full Frame
    self.textFullFrame:SetSize(GetScreenWidth(), textAreaHeight)
    self.textFullFrame:SetPoint("BOTTOMLEFT", 0, 0)
    self.textFullFrameBg:SetSize(GetScreenWidth(), textAreaHeight)
    self.textFullFrameBg:SetPoint("BOTTOMLEFT", 0, 0)
    self.textFullFrameBgTexture:SetAllPoints(self.textFullFrameBg)
    self.textFullFrameBgTexture:SetColorTexture(0, 0, 0, 1) -- r,g,b,a        
    fadedFrameParameters = {
        parent = Skits_Style_Tales.textFullFrame,
        alpha = 1.0,
        contentHeight = textAreaHeight,
        contentWidth = GetScreenWidth(),
        leftSize = 2,
        rightSize = 2,
        topSize = 10,
        bottomSize = 2,
    }  
    Skits_UI_Utils:ResizeFadedFrame(self.textFullFrameBgBorder, fadedFrameParameters)
    self.textFullFrameBgBorder.main:SetPoint("BOTTOMLEFT", Skits_Style_Tales.textFullFrame, "BOTTOMLEFT", 0, 0)

    -- Left Frame
    self.textLeftFrame:SetSize(GetScreenWidth() * 0.5, textAreaHeight)
    self.textLeftFrame:SetPoint("BOTTOMLEFT", 0, 0)
    self.textLeftFrameBg:SetSize(GetScreenWidth() * 0.5, textAreaHeight)
    self.textLeftFrameBg:SetPoint("BOTTOMLEFT", 0, 0)
    self.textLeftFrameBgTexture:SetAllPoints(self.textLeftFrameBg)
    self.textLeftFrameBgTexture:SetColorTexture(0, 0, 0, 1) -- r,g,b,a       
    fadedFrameParameters = {
        parent = Skits_Style_Tales.textLeftFrame,
        alpha = 1.0,
        contentHeight = textAreaHeight,
        contentWidth = GetScreenWidth() * 0.5,
        leftSize = 2,
        rightSize = GetScreenWidth() * 0.25,
        topSize = 10,
        bottomSize = 2,
    }  
    Skits_UI_Utils:ResizeFadedFrame(self.textLeftFrameBgBorder, fadedFrameParameters)
    self.textLeftFrameBgBorder.main:SetPoint("BOTTOMLEFT", Skits_Style_Tales.textLeftFrame, "BOTTOMLEFT", 0, 0)   
    
    self.textLeftSpeakerText:SetPoint("CENTER", self.textLeftFrame, "TOP", 0, 0)
    self.textLeftSpeakerText:SetFont(font, fontSize)
    self.textLeftSpeakerText:SetJustifyH("CENTER")
    self.textLeftSpeakerText:SetJustifyV("MIDDLE")        
    self.textLeftSpeakerText:SetWordWrap(true)
    self.textLeftSpeakerText:SetText(" ")
    speakerNameHeight = self.textLeftSpeakerText:GetStringHeight() + 5

    self.textLeftMessageText:SetPoint("BOTTOM", self.textLeftFrame, "BOTTOM", 0, 0)
    self.textLeftMessageText:SetSize(textWidth, textAreaHeight)
    self.textLeftMessageText:SetFont(font, fontSize)
    self.textLeftMessageText:SetJustifyH("CENTER")
    self.textLeftMessageText:SetJustifyV("MIDDLE")
    self.textLeftMessageText:SetWordWrap(true)    

    -- Right Frame
    self.textRightFrame:SetSize(GetScreenWidth() * 0.5, textAreaHeight)
    self.textRightFrame:SetPoint("BOTTOMRIGHT", 0, 0)
    self.textRightFrameBg:SetSize(GetScreenWidth() * 0.5, textAreaHeight)
    self.textRightFrameBg:SetPoint("BOTTOMRIGHT", 0, 0)
    self.textRightFrameBgTexture:SetAllPoints(self.textRightFrameBg)
    self.textRightFrameBgTexture:SetColorTexture(0, 0, 0, 1) -- r,g,b,a   
    fadedFrameParameters = {
        parent = Skits_Style_Tales.textRightFrame,
        alpha = 1.0,
        contentHeight = textAreaHeight,
        contentWidth = GetScreenWidth() * 0.5,
        leftSize = GetScreenWidth() * 0.25,
        rightSize = 2,
        topSize = 10,
        bottomSize = 2,
    }  
    Skits_UI_Utils:ResizeFadedFrame(self.textRightFrameBgBorder, fadedFrameParameters)
    self.textRightFrameBgBorder.main:SetPoint("BOTTOMRIGHT", Skits_Style_Tales.textRightFrame, "BOTTOMRIGHT", 0, 0)   
    
    self.textRightSpeakerText:SetPoint("CENTER", self.textRightFrame, "TOP", 0, 0)
    self.textRightSpeakerText:SetFont(font, fontSize)
    self.textRightSpeakerText:SetJustifyH("CENTER")
    self.textRightSpeakerText:SetJustifyV("MIDDLE")    
    self.textRightSpeakerText:SetWordWrap(true)
    self.textRightSpeakerText:SetText(" ")
    speakerNameHeight = self.textRightSpeakerText:GetStringHeight() + 5

    self.textRightMessageText:SetPoint("BOTTOM", self.textRightFrame, "BOTTOM", 0, 0)
    self.textRightMessageText:SetSize(textWidth, textAreaHeight)
    self.textRightMessageText:SetFont(font, fontSize)
    self.textRightMessageText:SetJustifyH("CENTER")
    self.textRightMessageText:SetJustifyV("MIDDLE")
    self.textRightMessageText:SetWordWrap(true)    

    -- Text Frame Levels
    self.textFullFrame:SetFrameLevel(100)
    self.textFullFrameBg:SetFrameLevel(90)
    self.textFullFrameBgBorder.main:SetFrameLevel(95)
    self.textFullFrameBgBorder.bg:SetFrameLevel(95)
    self.textLeftFrame:SetFrameLevel(100)
    self.textLeftFrameBg:SetFrameLevel(90)
    self.textLeftFrameBgBorder.main:SetFrameLevel(95)
    self.textLeftFrameBgBorder.bg:SetFrameLevel(95)
    self.textRightFrame:SetFrameLevel(100)
    self.textRightFrameBg:SetFrameLevel(90)
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
    local slotPosY = textAreaHeight + 30 - (modelFrameSize * 0.40)
    local slotPosCenterDist = GetScreenWidth() / 4
    local slotPosCenterDistMult = 0
    local slotPosX = 0
    for i = 1, numberOfSlots do
        -- Calculate Position
        if i % 2 == 0 then
            slotPosCenterDistMult = slotPosCenterDistMult + 1
            slotPosX = slotPosCenterDist - (slotPosCenterDistMult * modelDist)
        else
            slotPosX = slotPosCenterDist + (slotPosCenterDistMult * modelDist)
        end

        -- Register it
        self.speakerPositions.left[i].x = -slotPosX
        self.speakerPositions.left[i].y = slotPosY

        self.speakerPositions.right[i].x = slotPosX
        self.speakerPositions.right[i].y = slotPosY
    end
    self.speakerPositions.leftOut.x = -(GetScreenWidth() * 0.6)
    self.speakerPositions.leftOut.y = slotPosY

    self.speakerPositions.rightOut.x = GetScreenWidth() * 0.6
    self.speakerPositions.rightOut.y = slotPosY
end

-- SLOTS FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function SlotClearData(slot)
    if not slot then
        return
    end

    slot.modelFrame:SetDisplayInfo(0)
    slot.modelFrame:ClearModel()
    
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
end

local function SlotExpireMsg(slot, hideMessage)
    if hideMessage then
        local speakerTextEle = nil
        local messageTextEle = nil    
        if slot.position and slot.position.onLeft then
            speakerTextEle = Skits_Style_Tales.textLeftSpeakerText
            messageTextEle = Skits_Style_Tales.textLeftMessageText
        else
            speakerTextEle = Skits_Style_Tales.textRightSpeakerText
            messageTextEle = Skits_Style_Tales.textRightMessageText
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
end

local function SlotFindOldest()
    local oldestIdx = 1
    local oldestTimestamp = nil

    for i = 1, numberOfSlots do
        local slot = Skits_Style_Tales.speakerSlots[i]      
        if not oldestTimestamp or slot.speakTimestamp < oldestTimestamp then
            oldestIdx = i
            oldestTimestamp = slot.speakTimestamp
        end
    end

    return Skits_Style_Tales.speakerSlots[oldestIdx]
end

local function SlotFindOneToUse(onLeft)
    -- Use a Free Slot
    for i = 1, numberOfSlots do
        local slot = Skits_Style_Tales.speakerSlots[i]
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
    if not slot then
        return
    end

    local options = Skits_Options.db
    if options.style_tales_previous_speaker_lingertime <= 0 then
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
    slot.slotExpireHandler = C_Timer.NewTimer(options.style_tales_previous_speaker_lingertime, function()        
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
    local positionArray = Skits_Style_Tales.speakerPositions.right
    if onLeft then
        positionArray = Skits_Style_Tales.speakerPositions.left
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
    local positionArray = Skits_Style_Tales.speakerPositions.right
    if onLeft then
        positionArray = Skits_Style_Tales.speakerPositions.left
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
    local leftPos = Skits_Style_Tales.speakerPositions.left[1]
    local rightPos = Skits_Style_Tales.speakerPositions.right[1]

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

    slot.modelFrame:SetPoint("BOTTOM", Skits_Style_Tales.mainFrame, "BOTTOM", cx, cy) 
    
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

        slot.modelFrame:SetPoint("BOTTOM", Skits_Style_Tales.mainFrame, "BOTTOM", toPosition.x, toPosition.y)        
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
        if Skits_Style_Tales.lastSpeak.slotRight then
            lastTimestamp = Skits_Style_Tales.lastSpeak.slotRight.msgExpireTimestamp
            maxDuration = maxDuration + Skits_Style_Tales.lastSpeak.slotRight.msgExpireDuration
        end
    else
        if Skits_Style_Tales.lastSpeak.slotLeft then
            lastTimestamp = Skits_Style_Tales.lastSpeak.slotLeft.msgExpireTimestamp
            maxDuration = maxDuration + Skits_Style_Tales.lastSpeak.slotLeft.msgExpireDuration
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
    if slot.position.onLeft then
        speakerTextEle = Skits_Style_Tales.textLeftSpeakerText
        messageTextEle = Skits_Style_Tales.textLeftMessageText
    else
        speakerTextEle = Skits_Style_Tales.textRightSpeakerText
        messageTextEle = Skits_Style_Tales.textRightMessageText
    end

    speakerNameDisplayed = ""
    if options.style_tales_speaker_name_enabled then
        speakerNameDisplayed = creatureData.name
    end
    speakerTextEle:SetText(speakerNameDisplayed)
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
    local hourLight = slot.modelLight

    local portraitZoom = 0
    local rotation = rotation
    local scale = nil
    local animations = {0}
    local pauseAfter = 0
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden    
    if options.style_tales_model_poser then
        animations = Skits_UI_Utils:GetAnimationIdsFromText(textData.text, true)
        pauseAfter = 1 + (math.random() * 1)
    end    
    local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, hourLight, pauseAfter, fallbackId, fallbackLight) 

    -- Model Frame: Load Model
    local loadOptions = {
        modelFrame = slot.modelFrame,
        callback = nil,
    }
    
    local loaderData = Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)
    Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
    slot.loaderData = loaderData
end

-- Layout update functions
local function LayoutUpdateBackgrounds()
    local options = Skits_Options.db

    -- Update Message Frames
    local mainSlotLeft = Skits_Style_Tales.speakerPositions.left[1].slot
    local mainSlotRight = Skits_Style_Tales.speakerPositions.right[1].slot

    if not isVisible then
        Skits_Style_Tales.textFullFrameBg:Hide()
        Skits_Style_Tales.textFullFrameBgBorder.main:Hide()
        Skits_Style_Tales.textFullFrameBgTexture:Hide()
        Skits_Style_Tales.textLeftFrame:Hide()
        Skits_Style_Tales.textLeftFrameBg:Hide()
        Skits_Style_Tales.textLeftFrameBgBorder.main:Hide()
        Skits_Style_Tales.textLeftFrameBgTexture:Hide()
        Skits_Style_Tales.textRightFrame:Hide()
        Skits_Style_Tales.textRightFrameBg:Hide()
        Skits_Style_Tales.textRightFrameBgBorder.main:Hide()   
        Skits_Style_Tales.textRightFrameBgTexture:Hide()
        
        Skits_Style_Tales.modelFullBgFrame:Hide()
        Skits_Style_Tales.modelFullBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgFrame:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrame:Hide()
        Skits_Style_Tales.modelLeftBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgFrame:Hide()
        Skits_Style_Tales.modelRightBgBorderFrame:Hide()
        Skits_Style_Tales.modelRightBgFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgBorderFrameTexture:Hide()

    elseif options.style_tales_always_fullscreen or (mainSlotLeft and mainSlotRight) then
        Skits_Style_Tales.textFullFrameBg:Show()
        Skits_Style_Tales.textFullFrameBgBorder.main:Show()
        Skits_Style_Tales.textFullFrameBgTexture:Show()
        Skits_Style_Tales.textLeftFrame:Show()
        Skits_Style_Tales.textLeftFrameBg:Hide()
        Skits_Style_Tales.textLeftFrameBgBorder.main:Hide()
        Skits_Style_Tales.textLeftFrameBgTexture:Hide()
        Skits_Style_Tales.textRightFrame:Show()
        Skits_Style_Tales.textRightFrameBg:Hide()
        Skits_Style_Tales.textRightFrameBgBorder.main:Hide()     
        Skits_Style_Tales.textRightFrameBgTexture:Hide()
        
        Skits_Style_Tales.modelFullBgFrame:Show()
        Skits_Style_Tales.modelFullBgFrameTexture:Show()
        Skits_Style_Tales.modelLeftBgFrame:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrame:Hide()
        Skits_Style_Tales.modelLeftBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgFrame:Hide()
        Skits_Style_Tales.modelRightBgBorderFrame:Hide()
        Skits_Style_Tales.modelRightBgFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgBorderFrameTexture:Hide()

    elseif mainSlotLeft then
        Skits_Style_Tales.textFullFrameBg:Hide()
        Skits_Style_Tales.textFullFrameBgBorder.main:Hide()
        Skits_Style_Tales.textFullFrameBgTexture:Hide()
        Skits_Style_Tales.textLeftFrame:Show()
        Skits_Style_Tales.textLeftFrameBg:Show()
        Skits_Style_Tales.textLeftFrameBgBorder.main:Show()
        Skits_Style_Tales.textLeftFrameBgTexture:Show()
        Skits_Style_Tales.textRightFrame:Hide()
        Skits_Style_Tales.textRightFrameBg:Hide()
        Skits_Style_Tales.textRightFrameBgBorder.main:Hide()   
        Skits_Style_Tales.textRightFrameBgTexture:Hide()
        
        Skits_Style_Tales.modelFullBgFrame:Hide()
        Skits_Style_Tales.modelFullBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgFrame:Show()
        Skits_Style_Tales.modelLeftBgBorderFrame:Show()
        Skits_Style_Tales.modelLeftBgFrameTexture:Show()
        Skits_Style_Tales.modelLeftBgBorderFrameTexture:Show()
        Skits_Style_Tales.modelRightBgFrame:Hide()
        Skits_Style_Tales.modelRightBgBorderFrame:Hide()
        Skits_Style_Tales.modelRightBgFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgBorderFrameTexture:Hide()

    elseif mainSlotRight then
        Skits_Style_Tales.textFullFrameBg:Hide()
        Skits_Style_Tales.textFullFrameBgBorder.main:Hide()
        Skits_Style_Tales.textFullFrameBgTexture:Hide()
        Skits_Style_Tales.textLeftFrame:Hide()
        Skits_Style_Tales.textLeftFrameBg:Hide()
        Skits_Style_Tales.textLeftFrameBgBorder.main:Hide()
        Skits_Style_Tales.textLeftFrameBgTexture:Hide()
        Skits_Style_Tales.textRightFrame:Show()
        Skits_Style_Tales.textRightFrameBg:Show()
        Skits_Style_Tales.textRightFrameBgBorder.main:Show()   
        Skits_Style_Tales.textRightFrameBgTexture:Show()
        
        Skits_Style_Tales.modelFullBgFrame:Hide()
        Skits_Style_Tales.modelFullBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgFrame:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrame:Hide()
        Skits_Style_Tales.modelLeftBgFrameTexture:Hide()
        Skits_Style_Tales.modelLeftBgBorderFrameTexture:Hide()
        Skits_Style_Tales.modelRightBgFrame:Show()
        Skits_Style_Tales.modelRightBgBorderFrame:Show()
        Skits_Style_Tales.modelRightBgFrameTexture:Show()
        Skits_Style_Tales.modelRightBgBorderFrameTexture:Show()           
    end

    -- Click Behavior
    if isVisible and (options.style_tales_click_left ~= "PASS" or options.style_tales_click_right ~= "PASS") then
        Skits_Style_Tales.textFullFrame:EnableMouse(true)
        Skits_Style_Tales.textLeftFrame:EnableMouse(true)
        Skits_Style_Tales.textRightFrame:EnableMouse(true)

        local function OnClick(Skits_Style_Tales, button)
            if button == "LeftButton" then
                Skits_Style:MouseClickAction(options.style_tales_click_left, Skits_Style_Tales.name)
            elseif button == "RightButton" then
                Skits_Style:MouseClickAction(options.style_tales_click_right, Skits_Style_Tales.name)
            end
        end
    
        Skits_Style_Tales.textFullFrame:SetScript("OnMouseDown", OnClick)    
        Skits_Style_Tales.textLeftFrame:SetScript("OnMouseDown", OnClick)        
        Skits_Style_Tales.textRightFrame:SetScript("OnMouseDown", OnClick)  
    else
        Skits_Style_Tales.textFullFrame:EnableMouse(false)
        Skits_Style_Tales.textLeftFrame:EnableMouse(false)
        Skits_Style_Tales.textRightFrame:EnableMouse(false)
    end
end

-- Skit General Visibility Control --------------------------------------------------------
local function HideSkit(forceHide)
    if isVisible == true then
        if forceHide == false then
            return
        end
    else
        return
    end
    isVisible = false

    -- Hide all frames
    LayoutUpdateBackgrounds()

    -- Hide model
    -- Why set to size 0 instead of hidding? WOW Api has a memory leak when changing model of hidden model frames.
    for i = 1, numberOfSlots do
        slot = Skits_Style_Tales.speakerSlots[i]
        Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)
    end 

    return
end

local function ShowSkit(forceShow)
    if isVisible == false then
        if forceShow == false then
            return
        end
    else
        return
    end
    isVisible = true

    local options = Skits_Options.db
    local optionsModelSize = options.style_tales_model_size
    local modelFrameSize = optionsModelSize

    -- Show all frames
    LayoutUpdateBackgrounds()

    -- Show model slots
    for i = 1, numberOfSlots do
        slot = Skits_Style_Tales.speakerSlots[i]
        if slot then
            Skits_UI_Utils:ModelFrameSetVisible(slot.modelFrame, isVisible)

            if slot.loaderData then                                
                Skits_UI_Utils:LoadReAppeared(slot.loaderData)
            end            
        end

    end   

    return
end


-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Tales:NewSpeak(creatureData, textData)
    if needsLayoutReset then
        self:ResetLayouts()
        needsLayoutReset = false
    end

    -- Duration
    local duration = textData.duration

    -- Model Light for current hour
    local hourLight = Skits_Style_Utils:GetHourLight()

    -- Finding a Slot and Position it
    -- Is Speaker Still Slotted?
    local slot = SlotFindSpeaker(creatureData.name)
    local mainOldestPos = nil
    if slot then
        slot.modelLight = hourLight

        local mainSlotLeft = Skits_Style_Tales.speakerPositions.left[1].slot
        local mainSlotRight = Skits_Style_Tales.speakerPositions.right[1].slot

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
        local outsidePos = Skits_Style_Tales.speakerPositions.rightOut
        if mainOldestPos.onLeft then
            outsidePos = Skits_Style_Tales.speakerPositions.leftOut
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

    ShowSkit(false)
end

function Skits_Style_Tales:ResetLayout()
    self:ResetLayouts()
end


function Skits_Style_Tales:CloseSkit()
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

function Skits_Style_Tales:HideSkit()
    HideSkit(true)
end

function Skits_Style_Tales:ShowSkit()
    ShowSkit(true)
end

function Skits_Style_Tales:ShouldDisplay()
    local options = Skits_Options.db
    return true
end

function Skits_Style_Tales:IsActive()
    local isActive = false
    if self.controls.skitExpire > GetTime() then
        isActive = true
    end
    return isActive
end

function Skits_Style_Tales:CancelSpeaker(creatureData)
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