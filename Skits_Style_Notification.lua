-- Skits_Style_Notification.lua

Skits_Style_Notification = {}
Skits_Style_Notification.name = Skits_Style_Utils.enum_styles.NOTIFICATION

Skits_Style_Notification.mainFrame = CreateFrame("Frame", "SkitsStyleNotification", UIParent)

Skits_Style_Notification.font = ""
Skits_Style_Notification.fontSize = ""
Skits_Style_Notification.isOnRight = false
Skits_Style_Notification.portraitSize = 50
Skits_Style_Notification.textAreaWidth = 300
Skits_Style_Notification.sideDist = 50
Skits_Style_Notification.topDist = 50
Skits_Style_Notification.messageGap = 10
Skits_Style_Notification.speechDurationMax = 10

Skits_Style_Notification.maxMessages = 3
Skits_Style_Notification.messages = {}
Skits_Style_Notification.nextMsgIdx = 1
Skits_Style_Notification.lastMsgTimestamp = GetTime()
Skits_Style_Notification.remainingDuration = 0

local isVisible = false
local needsLayoutReset = true

local datasetname = "solo"

-- AUX FUNCTIONS --------------------------------------------------------------------------------------------------------------
local function defineDatasetDb()
    local inInstance, instanceType, playerCount, maxPlayers = Skits_Style:GetInstanceInformation()

    local newdatasetname = "solo"
    if inInstance then
        if instanceType == "party" then
            newdatasetname = "small"
        else
            if maxPlayers <= 10 then
                newdatasetname = "small"
            elseif maxPlayers <= 20 then
                newdatasetname = "medium"
            else    
                newdatasetname = "large"
            end
        end
    end

    if newdatasetname == datasetname then
        return false, datasetname
    else
        datasetname = newdatasetname
        return true, datasetname
    end
end

local function setSpeakVisibility(speakFrame, toVisible)
    local options = Skits_Options.db

    if speakFrame then
        Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portrait, toVisible)
        Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portraitBg, toVisible)

        if toVisible then
            speakFrame.content:Show()
            speakFrame.bg.bg:Show()
            if speakFrame.portraitLoaderData then
                Skits_UI_Utils:LoadReAppeared(speakFrame.portraitLoaderData)
            end
            if speakFrame.portraitBgLoaderData then
                Skits_UI_Utils:LoadReAppeared(speakFrame.portraitBgLoaderData)     
            end              
        else
            speakFrame.content:Hide()
            speakFrame.bg.bg:Hide()
        end

        -- Click Behavior
        if toVisible and (options.style_notification_click_left ~= "PASS" or options.style_notification_click_right ~= "PASS") then
            speakFrame.content:EnableMouse(true)

            local function OnClick(Skits_Style_Notification, button)
                if button == "LeftButton" then
                    Skits_Style:MouseClickAction(options.style_notification_click_left, Skits_Style_Notification.name)
                elseif button == "RightButton" then
                    Skits_Style:MouseClickAction(options.style_notification_click_right, Skits_Style_Notification.name)
                end
            end
    
            speakFrame.content:SetScript("OnMouseDown", OnClick)   
        else
            speakFrame.content:EnableMouse(false)
        end        
    end
end

local instanceStyleFallback = {
    large = "medium",
    medium = "small",
    small = "solo",
    solo = "solo",
}

function Skits_Style_Notification:ResetLayouts()    
    if isVisible == false then
        needsLayoutReset = true
        return
    end
    if needsLayoutReset == false then
        return
    end
    needsLayoutReset = false

    print("Skits_Style_Notification layout reset")

    local options = Skits_Options.db

    -- Options db
    local instanceStyleName = datasetname
    local instanceOptions = options.style_notification_instanceoptions[instanceStyleName]

    local inherited = instanceOptions.inherited
    while inherited == true and instanceStyleName ~= "solo" do
        instanceStyleName = instanceStyleFallback[instanceStyleName]
        if not instanceStyleName then
            break
        end

        instanceOptions = options.style_notification_instanceoptions[instanceStyleName]
        inherited = instanceOptions.inherited
    end

    -- Options Update
    self.font = LibStub("LibSharedMedia-3.0"):Fetch("font", instanceOptions.style_notification_speech_font_name)    
    self.fontSize = instanceOptions.speech_font_size
    self.isOnRight = instanceOptions.onRight
    self.portraitSize = instanceOptions.portrait_size
    self.textAreaWidth = instanceOptions.textarea_size
    self.maxMessages = instanceOptions.max_messages
    self.sideDist = instanceOptions.dist_side
    self.topDist = instanceOptions.top_side
    self.messageGap = 10

    local xfactor = 1
    if self.isOnRight then
        xfactor = -1
    end

    local frameWidth = GetScreenWidth() * 0.5
    local frameHeight = self.topDist
    local topDist = 0
    local sideDist = self.sideDist * xfactor

    -- Main Frame
    self.mainFrame:SetSize(frameWidth, frameHeight) 

    if self.isOnRight then
        self.mainFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", sideDist, topDist)
    else
        self.mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", sideDist, topDist)
    end
    
    self.mainFrame:SetFrameStrata(options.style_notification_strata)
    self.mainFrame:EnableMouse(false) -- Allow clicks to pass through
    self.mainFrame:EnableMouseWheel(false) -- Ignore mouse wheel events

    -- Create Message Slots
    for _, msg in ipairs(self.messages) do
        self:msgExpire(msg)
    end

    self.messages = {}
    self.lastMsgTimestamp = GetTime()
    self.remainingDuration = 0    
    self.nextMsgIdx = 1

    for i = 1, self.maxMessages do
        local msgData = self:msgCreate()
        table.insert(self.messages, msgData)
    end
end

function Skits_Style_Notification:CreateSpeakFrame(creatureData, text, textColor, parameters)
    local internalPositionData = {}

    local speakFrame = {
        creatureData = creatureData,
        textData = textData,
        parameters = parameters,
        internalPositionData = internalPositionData,
        main = nil,
        content = nil,
        bg = nil,             
        portrait = nil,
        portraitLoaderData = nil,
        portraitBg = nil,
        portraitBgLoaderData = nil,
        textEle = nil,
        height = 0,
    }

    -- FRAMES AND POSITIONS (1) -------------------------------------------------------------------------------------------
    internalPositionData.ancorRef1 = "BOTTOMLEFT"
    internalPositionData.ancorRef2 = "BOTTOMLEFT"
    internalPositionData.xfactor = 1
    if parameters.onRight then
        internalPositionData.ancorRef1 = "BOTTOMRIGHT"
        internalPositionData.ancorRef2 = "BOTTOMRIGHT"
        internalPositionData.xfactor = -1
    end
    internalPositionData.totalHeight = parameters.portraitSize

    -- Main Frame: Container of the frame
    speakFrame.main = CreateFrame("Frame", nil, parameters.parent)
    speakFrame.main:SetSize(parameters.portraitSize, parameters.portraitSize)
    speakFrame.main:SetPoint(internalPositionData.ancorRef1, parameters.parent, internalPositionData.ancorRef2, 0, 0)

    -- Portrait frame container
    internalPositionData.portraitYoffset = 5    
    speakFrame.portraitContainer = CreateFrame("Frame", nil, speakFrame.main)
    speakFrame.portraitContainer:SetPoint(internalPositionData.ancorRef1, speakFrame.main, internalPositionData.ancorRef2, 0, internalPositionData.portraitYoffset)   
    speakFrame.portraitContainer:SetSize(parameters.portraitSize, parameters.portraitSize)  

    -- Portrait frame
    speakFrame.portrait = CreateFrame("PlayerModel", nil, speakFrame.portraitContainer)
    Skits_UI_Utils:ModelFrameSetTargetSize(speakFrame.portrait, parameters.portraitSize, parameters.portraitSize)
    Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portrait, isVisible) 
    speakFrame.portrait:SetPoint(internalPositionData.ancorRef1, speakFrame.portraitContainer, internalPositionData.ancorRef2, 0, 0)    

    -- Portrait bg frame container
    internalPositionData.portraitBgOffsetY = internalPositionData.portraitYoffset + math.max(parameters.portraitSize * 0.05, 3)
    speakFrame.portraitBgContainer = CreateFrame("Frame", nil, speakFrame.main)
    speakFrame.portraitBgContainer:SetPoint(internalPositionData.ancorRef1, speakFrame.main, internalPositionData.ancorRef2, 0, internalPositionData.portraitBgOffsetY)   
    speakFrame.portraitBgContainer:SetSize(parameters.portraitSize, parameters.portraitSize) 

    -- Portrait bg frame
    speakFrame.portraitBg = CreateFrame("PlayerModel", nil, speakFrame.portraitBgContainer)
    Skits_UI_Utils:ModelFrameSetTargetSize(speakFrame.portraitBg, parameters.portraitSize, parameters.portraitSize)
    Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portraitBg, isVisible)
    speakFrame.portraitBg:SetPoint(internalPositionData.ancorRef1, speakFrame.portraitBgContainer, internalPositionData.ancorRef2, 0, 0)     

    -- Content Frame: Frame contents
    internalPositionData.textAreaWidth = parameters.textAreaWidth 
    internalPositionData.contentOffsetX = (parameters.portraitSize + 10 ) * internalPositionData.xfactor
    speakFrame.content = CreateFrame("Frame", nil, speakFrame.main)
    speakFrame.content:SetSize(internalPositionData.textAreaWidth, parameters.portraitSize)
    speakFrame.content:SetPoint(internalPositionData.ancorRef1, speakFrame.main, internalPositionData.ancorRef2, internalPositionData.contentOffsetX, internalPositionData.portraitYoffset)

    -- Text: Ele
    speakFrame.textEle = speakFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    speakFrame.textEle:SetPoint(internalPositionData.ancorRef1, speakFrame.content, internalPositionData.ancorRef2, 0, 0)
    speakFrame.textEle:SetFont(parameters.font, parameters.fontSize)
    speakFrame.textEle:SetSize(internalPositionData.textAreaWidth, 500)
    speakFrame.textEle:SetJustifyV("BOTTOM")
    if parameters.onRight then
        speakFrame.textEle:SetJustifyH("RIGHT")
    else
        speakFrame.textEle:SetJustifyH("LEFT")
    end    
    speakFrame.textEle:SetWordWrap(true)

    -- CONTENTS, SIZES, and POSITIONS (2) -------------------------------------------------------------------------------------------
    self:SetSpeakFrameData(speakFrame, creatureData, text, textColor) 

    return speakFrame
end

function Skits_Style_Notification:SetSpeakFrameData(speakFrame, creatureData, text, textColor) 
    local parameters = speakFrame.parameters
    local internalPositionData = speakFrame.internalPositionData

    -- CONTENTS, SIZES, and POSITIONS (2) -------------------------------------------------------------------------------------------
    speakFrame.textEle:SetText(text)
    speakFrame.textEle:SetTextColor(textColor.r, textColor.g, textColor.b)
    
    local textHeight = speakFrame.textEle:GetStringHeight()
    local textWidth = math.min(parameters.textAreaWidth, speakFrame.textEle:GetStringWidth())
    internalPositionData.textAreaHeight = textHeight + (internalPositionData.portraitYoffset * 2)
    internalPositionData.textAreaWidth = textWidth

    -- Bg:
    local fadedFrameParameters = {
        parent = speakFrame.main,
        alpha = 0.6,
        contentHeight = internalPositionData.textAreaHeight,
        contentWidth = internalPositionData.textAreaWidth,
        leftSize = 100,
        rightSize = 100,
        topSize = 2,
        bottomSize = 2,
    }   
    speakFrame.bg = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 
    speakFrame.bg.main:SetPoint(internalPositionData.ancorRef1, speakFrame.main, internalPositionData.ancorRef2, internalPositionData.contentOffsetX, 0) 

    -- Organize Levels -------------------------------------------------------------------------------------------
    speakFrame.content:SetFrameLevel(100)

    speakFrame.portraitContainer:SetFrameLevel(51)    
    speakFrame.portraitBgContainer:SetFrameLevel(50)

    speakFrame.bg.main:SetFrameLevel(2)
    speakFrame.bg.bg:SetFrameLevel(1)

    -- MODELS -------------------------------------------------------------------------------------------
    -- Model: display options

    local light = Skits_Style_Utils:GetHourLight()
    local lightBg = Skits_Style_Utils.lightPresets.pitchblack
    local portraitZoom = 0.9
    local rotation = nil
    local scale = nil
    local animations = {0}
    local posePoint = 0
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden    

    -- Portrait Frame: Load Model
    local portraitDisplayOptions = Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, light, posePoint, fallbackId, fallbackLight) 
    local portraitLoadOptions = {
        modelFrame = speakFrame.portrait,
        callback = nil,
    }

    if isVisible == true then 
        speakFrame.portraitLoaderData = Skits_UI_Utils:LoadModel(creatureData, portraitDisplayOptions, portraitLoadOptions)
    else
        -- todo: instead of just clearing the model, store model to reload on show
        speakFrame.portrait:ClearModel()
    end   

    -- Finals    
    internalPositionData.totalHeight = math.max(parameters.portraitSize + internalPositionData.portraitYoffset, internalPositionData.textAreaHeight)
    speakFrame.height = internalPositionData.totalHeight
end

-- MSG add --------------------------------------------------------------------------------------------------------------
local function msgPositionUpdate(self, delta)
    local up = self.msgData.positionData

    up.cd = up.cd + delta

    local ending = false
    if up.cd >= up.td then
        up.cd = up.td
        ending = true
    end

    local cx = up.x
    local cy = Skits_Utils:Interpolation(up.oy, up.ty, 0, up.td, up.cd)

    self.msgData.speakFrame.main:SetPoint(up.anchor, Skits_Style_Notification.mainFrame, up.anchor, cx, cy) 
    
    if ending then
        self:SetScript("OnUpdate", nil)
    end
end

function Skits_Style_Notification:msgMoveToBase(msgData)
    local up = msgData.positionData
    up.ty = 0
    up.oy = 0
    msgData.speakFrame.main:SetPoint(up.anchor, self.mainFrame, up.anchor, up.x, up.ty)
end

function Skits_Style_Notification:msgMoveUp(msgData, ammount)
    local instant = false

    -- Reasons to be instant (besides given parameter)
    if not isVisible then
        instant = true
    end

    local up = msgData.positionData
    if instant then
        up.x = up.x
        up.ty = up.ty + ammount
        up.oy = up.ty
        up.cd = 0
        up.td = 0

        msgData.speakFrame.main:SetPoint(up.anchor, self.mainFrame, up.anchor, up.x, up.ty) 
    else
        up.x = up.x
        up.oy = Skits_Utils:Interpolation(up.oy, up.ty, 0, up.td, up.cd)     
        up.ty = up.ty + ammount
        up.cd = 0
        up.td = 0.2

        msgData.speakFrame.main:SetScript("OnUpdate", msgPositionUpdate)
    end
end

function Skits_Style_Notification:msgExpire(msgData)
    -- Timers Updates
    if msgData.expireHandler then
        msgData.expireHandler:Cancel() 
        msgData.expireHandler = nil
    end
    msgData.expired = true

    -- Clear Model Data
    msgData.speakFrame.main:SetScript("OnUpdate", nil)    
    msgData.speakFrame.portrait:SetDisplayInfo(0)
    msgData.speakFrame.portrait:ClearModel()
    msgData.speakFrame.portraitBg:SetDisplayInfo(0)
    msgData.speakFrame.portraitBg:ClearModel()    

    if msgData.portraitLoaderData then
        Skits_UI_Utils:LoadModelStopTimer(msgData.portraitLoaderData)
        msgData.portraitLoaderData = nil
    end    
    if msgData.portraitBgLoaderData then
        Skits_UI_Utils:LoadModelStopTimer(msgData.portraitBgLoaderData)
        msgData.portraitBgLoaderData = nil
    end        
    
    setSpeakVisibility(msgData.speakFrame, false)
end

function Skits_Style_Notification:msgAdd(creatureData, textData, duration)
    -- Build next message data 
    local msgData = self.messages[self.nextMsgIdx]
    self:msgExpire(msgData)
    msgData.expired = false
    msgData.duration = duration    
    msgData.text = textData.text

    setSpeakVisibility(msgData.speakFrame, false)    

    self:SetSpeakFrameData(msgData.speakFrame, creatureData, textData.text, textData) 
    local newMsgHeight = msgData.speakFrame.internalPositionData.totalHeight

    -- Move other messages up
    for otherIdx, otherMsgData in ipairs(self.messages) do
        if otherMsgData.expired == false then
            if otherIdx ~= self.nextMsgIdx  then
                self:msgMoveUp(otherMsgData, newMsgHeight + self.messageGap)
            end
        end
    end

    -- Reposition new message
    self:msgMoveToBase(msgData)
    setSpeakVisibility(msgData.speakFrame, isVisible)

    -- Set current message expire timer
    if msgData.expireHandler then
        msgData.expireHandler:Cancel() 
    end  
    local tMsgData = msgData  
    msgData.expireHandler = C_Timer.NewTimer(msgData.duration, function()        
        self:msgExpire(tMsgData)
    end)    

    -- Update next msg idx
    self.nextMsgIdx = self.nextMsgIdx + 1
    if self.nextMsgIdx > self.maxMessages then
        self.nextMsgIdx = 1
    end
end

function Skits_Style_Notification:msgCreate()
    -- Dummy Text and creature data
    local textData = {
        text = "",   
        speed = 1.0,
        duration = 0,
        r = 1,
        g = 1,
        b = 1,        
    }    
    local creatureData = {
        name = "dummy",
        displayId = Skits_Style_Utils.fallbackId.m,
    }

    -- Create Speak Frame    
    local parameters = {
        parent = self.mainFrame,
        onRight = self.isOnRight,
        portraitSize = self.portraitSize,
        textAreaWidth = self.textAreaWidth,
        font = self.font,
        fontSize = self.fontSize,
    }
    local speakFrame = self:CreateSpeakFrame(creatureData, textData.text, textData, parameters)

    -- Message create
    local anchor = "BOTTOMLEFT"
    if parameters.onRight then
        anchor = "BOTTOMRIGHT"
    end 

    local msgData = {
        speakFrame = speakFrame,
        duration = 0,
        text = textData.text,
        expireHandler = nil,
        expired = true,
        positionData = {
            x = 0,
            oy = 0,
            ty = 0,            
            cd = 0,   
            td = 0,
            anchor = anchor,
        },
    }
    speakFrame.main.msgData = msgData

    -- Hide Message
    setSpeakVisibility(msgData.speakFrame, false)

    return msgData
end

-- Skit General Visibility Control --------------------------------------------------------
local function HideSkit()
    if isVisible == false then
        return    
    end
    isVisible = false

    -- Hide all messages
    for _, msgData in ipairs(Skits_Style_Notification.messages) do
        local speakFrame = msgData.speakFrame
        local toVisible = false
        if msgData.expired == false then
            toVisible = isVisible
        end
        setSpeakVisibility(speakFrame, toVisible)
    end    

    print("Notification Hide")

    return
end

local function ShowSkit()
    if isVisible == true then
        return    
    end
    isVisible = true

    Skits_Style_Notification:ResetLayouts()    

    -- Show all messages
    for _, msgData in ipairs(Skits_Style_Notification.messages) do
        local speakFrame = msgData.speakFrame
        local toVisible = false
        if msgData.expired == false then
            toVisible = isVisible
        end
        setSpeakVisibility(speakFrame, toVisible)
    end    

    print("Notification Show")

    return
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Notification:NewSpeak(creatureData, textData)
    self:ResetLayouts()

    local options = Skits_Options.db

    -- Calculate position
    local datasetchanged, _ = defineDatasetDb()
    if datasetchanged then
        needsLayoutReset = true
    end

    -- Duration
    local duration = textData.duration

    -- Calculate adjusted duration
    local currentTime = GetTime()
    local remainingDur = 0
    
    if self.lastMsgTimestamp ~= nil then
        remainingDur = math.max(0, self.remainingDuration - (currentTime - self.lastMsgTimestamp))

    end
    local adjustedDuration = math.min(options.speech_duration_max * 2, remainingDur + duration)

    -- Update duration tracking
    self.lastMsgTimestamp = currentTime
    self.remainingDuration = adjustedDuration

    -- Create Message
    self:msgAdd(creatureData, textData, adjustedDuration)
end

function Skits_Style_Notification:ResetLayout()
    self:ResetLayouts()
end

function Skits_Style_Notification:CloseSkit()
    for _, msgData in ipairs(self.messages) do
        self:msgExpire(msgData)
    end
    self:HideSkit() 
end

function Skits_Style_Notification:HideSkit()
    HideSkit()
end

function Skits_Style_Notification:ShowSkit()
    ShowSkit()
end

function Skits_Style_Notification:ShouldDisplay()
    local options = Skits_Options.db
    return true
end

function Skits_Style_Notification:IsActive()
    return true
end

function Skits_Style_Notification:CancelSpeaker(creatureData)
    return
end