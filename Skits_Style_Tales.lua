-- Skits_Style_Tales.lua

Skits_Style_Tales = {}
Skits_Style_Tales.name = Skits_Style_Utils.enum_styles.TALES

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
    speakerSlot.modelFrame:Show()
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
    Skits_Style_Tales.textBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/SkitsStyleTalesTextBg.tga")
    Skits_Style_Tales.textBgFrameTexture:SetAllPoints(Skits_Style_Tales.textBgFrame) -- Cover the entire frame
    Skits_Style_Tales.textBgFrameTexture:SetHorizTile(true) -- Enable horizontal tiling
    Skits_Style_Tales.textBgFrameTexture:SetVertTile(false) -- Disable vertical tiling

    -- Model Background Frame
    Skits_Style_Tales.modelBgFrame:SetSize(GetScreenWidth(), modelBgSize) -- Full width, height 200
    Skits_Style_Tales.modelBgFrame:SetPoint("BOTTOM", 0, textAreaHeight - 30) -- Positioned at the bottom of the screen
    Skits_Style_Tales.modelBgFrame:SetFrameLevel(50)

    -- Add the background texture to modelBgFrame
    Skits_Style_Tales.modelBgFrameTexture:SetTexture("Interface/AddOns/Skits/Textures/SkitsStyleTalesModelBg.tga")
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
   end    

    -- Slot Positions
    local slotPosY = textAreaHeight - (modelFrameSize * 0.40)
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
        Skits_Style_Tales.speakerPositions.left[i].x = -slotPosX
        Skits_Style_Tales.speakerPositions.left[i].y = slotPosY

        Skits_Style_Tales.speakerPositions.right[i].x = slotPosX
        Skits_Style_Tales.speakerPositions.right[i].y = slotPosY
    end
    Skits_Style_Tales.speakerPositions.leftOut.x = -(GetScreenWidth() * 0.6)
    Skits_Style_Tales.speakerPositions.leftOut.y = slotPosY

    Skits_Style_Tales.speakerPositions.rightOut.x = GetScreenWidth() * 0.6
    Skits_Style_Tales.speakerPositions.rightOut.y = slotPosY
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

local function SlotFindOneToUse()
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
        SlotExpireSlot(slot)
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
        SlotExpireSlot(tslot)
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
    slot.modelFrame:Show()
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
    if not Skits_Style_Tales.mainFrame:IsShown() then
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
    if not Skits_Style_Tales.mainFrame:IsShown() then
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
        SlotExpireSlot(position.slot)
    end

    -- Set given slot on new pos
    slot.position = position
    position.slot = slot

    -- Set to position
    PositionSetSlotToPosition(slot, position, instant)
end


local function PositionSwap(slot1, slot2, instant)
    -- Reasons to be instant (besides given parameter)
    if not Skits_Style_Tales.mainFrame:IsShown() then
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
        SlotExpireMsg(lslot)
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
    local scale = 1.0
    local animations = Skits_UI_Utils:GetAnimationIdsFromText(textData.text, true)
    local pauseAfter = 1 + (math.random() * 1)
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden    
    local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, hourLight, pauseAfter, fallbackId, fallbackLight) 

    -- Model Frame: Load Model
    local loadOptions = {
        modelFrame = slot.modelFrame,
        callback = nil,
    }
    
    local loaderData = Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)
    slot.modelFrame:Show()
    slot.loaderData = loaderData
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Tales:NewSpeak(creatureData, textData)
    if needsLayoutReset then
        self:ResetLayouts()
        needsLayoutReset = false
    end

    -- Duration
    local duration = Skits_Utils:MessageDuration(textData.text)

    -- Model Light for current hour
    local hourLight = Skits_Style_Utils:GetHourLight()

    -- Finding a Slot and Position it
    -- Is Speaker StILL Slotted?
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
        slot = SlotFindOneToUse()

        -- Expire current slot
        SlotExpireSlot(slot)

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

    -- Update Controls
    SlotSetCurrentSpeaker(slot, creatureData)
end

function Skits_Style_Tales:ResetLayout()
    self:ResetLayouts()
end


function Skits_Style_Tales:CloseSkit()
    -- Reset Slots
    for i = 1, numberOfSlots do
        local speakerSlot = self.speakerSlots[i]
        speakerSlot.modelFrame:Hide()
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
    self.textLeftSpeakerText:SetText("")
    self.textLeftMessageText:SetText("")
    self.textRightSpeakerText:SetText("")
    self.textRightMessageText:SetText("")

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
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    end
end

function Skits_Style_Tales:ShowSkit()
    if not self.mainFrame:IsShown() then
        self.mainFrame:Show()
    end
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