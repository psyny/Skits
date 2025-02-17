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
Skits_Style_Notification.maxMessages = 3
Skits_Style_Notification.messageGap = 10
Skits_Style_Notification.speechDurationMax = 10

Skits_Style_Notification.messages = {}
Skits_Style_Notification.lastMsgTimestamp = GetTime()
Skits_Style_Notification.remainingDuration = 0

local needsLayoutReset = true

local isVisible = true

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

local function setSpeakVisibility(speakFrame)
    local options = Skits_Options.db

    if speakFrame then
        Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portrait, isVisible)
        Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portraitBg, isVisible)

        if isVisible then
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
        if isVisible and (options.style_notification_click_left ~= "PASS" or options.style_notification_click_right ~= "PASS") then
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
end

function Skits_Style_Notification:CreateSpeakFrame(creatureData, text, textColor, parameters)
    local speakFrame = {
        creatureData = creatureData,
        textData = textData,
        parameters = parameters,
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
    local ancorRef1 = "BOTTOMLEFT"
    local ancorRef2 = "BOTTOMLEFT"
    local xfactor = 1
    if parameters.onRight then
        ancorRef1 = "BOTTOMRIGHT"
        ancorRef2 = "BOTTOMRIGHT"
        xfactor = -1
    end

    -- Main Frame: Container of the frame
    speakFrame.main = CreateFrame("Frame", nil, parameters.parent)
    speakFrame.main:SetSize(parameters.portraitSize, parameters.portraitSize)
    speakFrame.main:SetPoint(ancorRef1, parameters.parent, ancorRef2, 0, 0)

    -- Portrait frame
    local portraitYoffset = 5
    speakFrame.portrait = CreateFrame("PlayerModel", nil, speakFrame.main)
    Skits_UI_Utils:ModelFrameSetTargetSize(speakFrame.portrait, parameters.portraitSize, parameters.portraitSize)
    Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portrait, isVisible) 
    speakFrame.portrait:SetPoint(ancorRef1, speakFrame.main, ancorRef2, 0, portraitYoffset)    

    -- Portrait bg frame
    local portraitBgOffsetY = math.max(parameters.portraitSize * 0.05, 3)
    speakFrame.portraitBg = CreateFrame("PlayerModel", nil, speakFrame.main)
    Skits_UI_Utils:ModelFrameSetTargetSize(speakFrame.portraitBg, parameters.portraitSize, parameters.portraitSize)
    Skits_UI_Utils:ModelFrameSetVisible(speakFrame.portraitBg, isVisible)
    speakFrame.portraitBg:SetPoint("BOTTOMLEFT", speakFrame.portrait, "BOTTOMLEFT", 0, portraitBgOffsetY)    

    -- Content Frame: Frame contents
    local textAreaWidth = parameters.textAreaWidth 
    local contentOffsetX = (parameters.portraitSize + 10 ) * xfactor
    speakFrame.content = CreateFrame("Frame", nil, speakFrame.main)
    speakFrame.content:SetSize(textAreaWidth, parameters.portraitSize)
    speakFrame.content:SetPoint(ancorRef1, speakFrame.main, ancorRef2, contentOffsetX, portraitYoffset)

    -- Text: Ele
    speakFrame.textEle = speakFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    speakFrame.textEle:SetPoint(ancorRef1, speakFrame.content, ancorRef2, 0, 0)
    speakFrame.textEle:SetFont(parameters.font, parameters.fontSize)
    speakFrame.textEle:SetSize(textAreaWidth, 500)
    speakFrame.textEle:SetJustifyV("BOTTOM")
    if parameters.onRight then
        speakFrame.textEle:SetJustifyH("RIGHT")
    else
        speakFrame.textEle:SetJustifyH("LEFT")
    end    
    speakFrame.textEle:SetWordWrap(true)

    -- CONTENTS, SIZES, and POSITIONS (2) -------------------------------------------------------------------------------------------
    speakFrame.textEle:SetText(text)
    speakFrame.textEle:SetTextColor(textColor.r, textColor.g, textColor.b)
    
    local textHeight = speakFrame.textEle:GetStringHeight()
    local textWidth = math.min(parameters.textAreaWidth, speakFrame.textEle:GetStringWidth())
    local textAreaHeight = textHeight + (portraitYoffset * 2)
    textAreaWidth = textWidth

    -- Bg:
    local fadedFrameParameters = {
        parent = speakFrame.main,
        alpha = 0.6,
        contentHeight = textAreaHeight,
        contentWidth = textAreaWidth,
        leftSize = 100,
        rightSize = 100,
        topSize = 2,
        bottomSize = 2,
    }   
    speakFrame.bg = Skits_UI_Utils:CreateFadedFrame(fadedFrameParameters) 
    speakFrame.bg.main:SetPoint(ancorRef1, speakFrame.main, ancorRef2, contentOffsetX, 0) 

    -- Organize Levels -------------------------------------------------------------------------------------------
    speakFrame.content:SetFrameLevel(100)
    speakFrame.portraitBg:SetFrameLevel(50)
    speakFrame.portrait:SetFrameLevel(51)
    speakFrame.bg.main:SetFrameLevel(1)
    speakFrame.bg.bg:SetFrameLevel(1)
    

    -- MODELS -------------------------------------------------------------------------------------------
    -- Model: display options

    local light = nil
    local lightBg = Skits_Style_Utils.lightPresets.pitchblack
    local portraitZoom = 0.9
    local rotation = nil
    local scale = nil
    local animations = {0}
    local pauseAfter = 0
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden    

    -- Portrait Frame: Load Model
    local portraitDisplayOptions = Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, light, pauseAfter, fallbackId, fallbackLight) 
    local portraitLoadOptions = {
        modelFrame = speakFrame.portrait,
        callback = nil,
    }
    speakFrame.portraitLoaderData = Skits_UI_Utils:LoadModel(creatureData, portraitDisplayOptions, portraitLoadOptions)
    speakFrame.portrait:Show()

    -- Portrait Bg Frame: Load Model
    -- TODO: It would make more sense if we try to load this model as part of the portrait callback...
    local portraitBgDisplayOptions = Skits_UI_Utils:BuildDisplayOptions(portraitZoom, rotation, scale, animations, lightBg, pauseAfter, fallbackId, fallbackLight) 
    local portraitBgLoadOptions = {
        modelFrame = speakFrame.portraitBg,
        callback = nil,
    }
    speakFrame.portraitBgLoaderData = Skits_UI_Utils:LoadModel(creatureData, portraitBgDisplayOptions, portraitBgLoadOptions)
    speakFrame.portraitBg:Show()

    -- Finals    
    speakFrame.height = math.max(parameters.portraitSize + portraitYoffset, textAreaHeight)

    return speakFrame
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
    msgData.speakFrame.main:SetScript("OnUpdate", nil)
    
    if msgData.expireHandler then
        msgData.expireHandler:Cancel() 
        msgData.expireHandler = nil
    end

    Skits_UI_Utils:RemoveFrame(msgData.speakFrame.main) 
end

function Skits_Style_Notification:RemoveOldestMessages(maxMessages)
    -- Trim old messages
    local diff = #self.messages - maxMessages
    if diff > 0 then
        for i = 1, diff do
            local oldMsg = self.messages[1]
            if oldMsg then
                self:msgExpire(oldMsg)
                table.remove(self.messages, 1)
            end
        end
    end
end

function Skits_Style_Notification:msgAdd(msgData)
    -- Move other messages up
    for _, otherMsgData in ipairs(self.messages) do
        self:msgMoveUp(otherMsgData, msgData.speakFrame.height + self.messageGap)
    end

    -- Set current message expire timer
    if msgData.expireHandler then
        msgData.expireHandler:Cancel() 
    end  
    local tMsgData = msgData  
    msgData.expireHandler = C_Timer.NewTimer(msgData.duration, function()        
        self:msgExpire(tMsgData)
    end)

    -- Show current message
    msgData.speakFrame.main:Show()
    setSpeakVisibility(msgData.speakFrame)

    -- Add it to the frame
    table.insert(self.messages, msgData)

    -- Trim old messages
    self:RemoveOldestMessages(self.maxMessages)
end

function Skits_Style_Notification:msgCreate(creatureData, textData, duration)
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
        duration = duration,
        text = textData.text,
        expireHandler = nil,
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

    self:msgAdd(msgData)
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

    -- Hide all messages
    for _, msgData in ipairs(Skits_Style_Notification.messages) do
        local speakFrame = msgData.speakFrame
        setSpeakVisibility(speakFrame)
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

    -- Show all messages
    for _, msgData in ipairs(Skits_Style_Notification.messages) do
        local speakFrame = msgData.speakFrame
        setSpeakVisibility(speakFrame)
    end    

    return
end

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Notification:NewSpeak(creatureData, textData)
    if needsLayoutReset then
        self:ResetLayouts()
        needsLayoutReset = false
    end

    local options = Skits_Options.db

    -- Calculate position
    local datasetchanged, _ = defineDatasetDb()
    if datasetchanged then
        self:ResetLayouts()
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
    self:msgCreate(creatureData, textData, adjustedDuration)

    ShowSkit(false)
end

function Skits_Style_Notification:ResetLayout()
    self:ResetLayouts()
end

function Skits_Style_Notification:CloseSkit()
    self:RemoveOldestMessages(0)
    self:HideSkit() 
end

function Skits_Style_Notification:HideSkit()
    HideSkit(true)
end

function Skits_Style_Notification:ShowSkit()
    ShowSkit(true)
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