-- Skits_Log_UI.lua
Skits_Log_UI = {}
Skits_Log_UI.frames = {}

-- Settings
local textAreaWidth = 300
local showSpeakerName = true   
local topBotPadding = 50
local gapBetweenSpeaks = 10

-- Control Vars
local isMostRecent = false
local msgEleTop = nil
local msgEleBottom = nil
local msgEleCurr = nil
local msgEleDir = -1

-- Main log frame to display NPC speak history
local frameWidth = 600
local frameHeight = 600
local logFrame = CreateFrame("Frame", "SkitsLogFrame", UIParent, "BackdropTemplate")
logFrame:SetSize(frameWidth, frameHeight)
logFrame:SetPoint("CENTER", UIParent, "CENTER")
logFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
logFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.90)
logFrame:SetFrameStrata("TOOLTIP")
logFrame:SetMovable(true)
logFrame:EnableMouse(true)
table.insert(UISpecialFrames, "SkitsLogFrame")
logFrame:Hide()

-- Close button for the log frame
local closeButton = CreateFrame("Button", nil, logFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", logFrame, "TOPRIGHT", -5, -5)

-- Navigation buttons
local prevButton = CreateFrame("Button", nil, logFrame, "UIPanelButtonTemplate")
prevButton:SetSize(80, 20)
prevButton:SetText("Previous")
prevButton:SetPoint("BOTTOMLEFT", logFrame, "BOTTOMLEFT", 10, 10)

local nextButton = CreateFrame("Button", nil, logFrame, "UIPanelButtonTemplate")
nextButton:SetSize(80, 20)
nextButton:SetText("Next")
nextButton:SetPoint("BOTTOMRIGHT", logFrame, "BOTTOMRIGHT", -10, 10)

-- Function to populate the log frame with entries from memory for the current page
function Skits_Log_UI:PopulateLogFrame()
    local options = Skits_Options.db
    local modelSize = options.style_warcraft_speaker_face_size
    local textAreaWidth = options.style_warcraft_speech_frame_size

    frameWidth = textAreaWidth + (modelSize*2) + 60
    logFrame:SetSize(frameWidth, frameHeight)

    local spaceFilled = 0 -- Space filled by content
    local lastFillIncrement = 0 -- Last fill increment

    -- Clear Speaker data
    local lastSpeaker = ''
    local lastSpeakerTextLabel = nil
    local lastSpeakerTextFrame = nil 
    local accumulatedLastFrameText = ""

	-- Clear existing content
    Skits_Log_UI:ClearLogFrame() 

    -- Specs
    local altSpeakerSide = true
    local font = LibStub("LibSharedMedia-3.0"):Fetch("font", options.style_warcraft_speech_font_name)
    local fontSize = options.style_warcraft_speech_font_size 

    -- Offseet based on dir
    spaceFilled = topBotPadding

    -- Loop through `SkitsDB.messages` for the entries on the current page
    for i = 1, 100 do -- 100 is the max msgs in a page, usually waaay less than this (4)
        if msgEleCurr == nil then
            break
        end

        local entry = SkitsDB.messages[msgEleCurr.value]
        if entry ~= nil then    
            if lastSpeaker ~= entry.creatureData.name then
                altSpeakerSide = not altSpeakerSide
            end 

            -- Update last drawn idx
            if msgEleDir > 0 then
                msgEleBottom = msgEleCurr
            else
                msgEleTop = msgEleCurr
            end

            local hasModel = false
            if entry.creatureData.isPlayer then
                if entry.creatureData.raceId then
                    hasModel = true
                end
            else
                if entry.creatureData.creatureId or entry.creatureData.creatureIds or entry.creatureData.displayIds then
                    hasModel = true
                end
            end

            -- Create speaker frame or attach to the last one?
            local createNewFrame = true
            if entry.creatureData.name == lastSpeaker then
                if lastSpeakerTextFrame then
                    if lastFillIncrement > options.style_warcraft_speaker_face_size + gapBetweenSpeaks + 5 then -- 5 only for rounding issues
                        createNewFrame = true
                    else 
                        createNewFrame = false
                    end
                end
            end

            if not createNewFrame then
                -- Attempt to increase last text size
                local oldText = accumulatedLastFrameText
                local newText = ""
                if msgEleDir > 0 then
                    newText = oldText .. "\n\n" .. entry.text
                else
                    newText = entry.text .. "\n\n" .. oldText
                end

                Skits_Style_Warcraft:UpdateText(newText, lastSpeakerTextFrame, lastSpeakerTextLabel, options.style_warcraft_speaker_face_enabled)

                -- Temp variables (possible definitive)
                local newHeight = lastSpeakerTextFrame:GetHeight()        
                local fillIncrement = (math.max(newHeight, modelSize) + gapBetweenSpeaks)
                local newSpaceFilled = spaceFilled + fillIncrement - lastFillIncrement

                -- Check if the text frame is still within log frame boundaries                
                if newSpaceFilled > frameHeight then
                    -- Revert changes and set to create new frame
                    createNewFrame = true
                    Skits_Style_Warcraft:UpdateText(oldText, lastSpeakerTextFrame, lastSpeakerTextLabel, options.style_warcraft_speaker_face_enabled)
                else
                    -- Keep changes
                    spaceFilled = newSpaceFilled
                    lastFillIncrement = fillIncrement
                    accumulatedLastFrameText = newText
                end
            end

            if createNewFrame then
                accumulatedLastFrameText = entry.text

                -- Create new speaker frame
                local textData = {
                    text = entry.text,
                    r = entry.color.r,
                    g = entry.color.g,
                    b = entry.color.b,
                }       
                local fallbackId = Skits_Style_Utils.fallbackId
                local fallbackLight = Skits_Style_Utils.lightPresets.hidden
                local displayOptions =  Skits_UI_Utils:BuildDisplayOptions(0.9, 0, 1, {60}, nil, 0, fallbackId, fallbackLight) 
                local textFrame, textLabel, speakerNameFrame, modelFrame, borderFrame = Skits_Style_Warcraft:CreateSpeakFrame(entry.creatureData, textData, displayOptions, modelSize, logFrame, altSpeakerSide, textAreaWidth, font, fontSize, showSpeakerName)
                if modelFrame then
                    modelFrame:SetPaused(true) 
                end        

                -- Postion and update offset
                local textHeight = textFrame:GetHeight()
                local fillIncrement = (math.max(textHeight, modelSize) + gapBetweenSpeaks)
                lastFillIncrement = fillIncrement
                local yOffset = 0
                if msgEleDir > 0 then
                    yOffset = frameHeight - (spaceFilled + fillIncrement)
                else
                    yOffset = spaceFilled
                end
                textFrame:SetPoint("BOTTOM", logFrame, "BOTTOM", 0, yOffset)

                -- Update Space Filled qty
                spaceFilled = spaceFilled + fillIncrement

                -- Record data
                table.insert(Skits_Log_UI.frames, textFrame)
                table.insert(Skits_Log_UI.frames, speakerNameFrame)
                table.insert(Skits_Log_UI.frames, modelFrame)
                table.insert(Skits_Log_UI.frames, borderFrame)

                -- Ajust speaker data
                lastSpeaker = entry.creatureData.name
                lastSpeakerTextFrame = textFrame
                lastSpeakerTextLabel = textLabel  
                
                -- Check limit for this page
                if spaceFilled + topBotPadding > frameHeight then
                    if msgEleDir > 0 then
                        msgEleBottom = msgEleBottom.next
                    else
                        msgEleTop = msgEleTop.prev
                    end

                    -- Hide last frame, its overflowing
                    textFrame:Hide()
                    speakerNameFrame:Hide()
                    modelFrame:Hide()
                    borderFrame:Hide()
                    break
                end                
            end

            -- Update current indexes
            if msgEleDir > 0 then
                msgEleCurr = msgEleCurr.prev
            else
                msgEleCurr = msgEleCurr.next
            end
            if not msgEleCurr then
                break
            end              
        end 
    end

    if not msgEleTop or not msgEleTop.next then
        prevButton:Hide()
    else
        prevButton:Show()
    end
    if not msgEleBottom or not msgEleBottom.prev then
        isMostRecent = true
        nextButton:Hide()
    else        
        nextButton:Show()
    end    
end

-- Clear frame
function Skits_Log_UI:ClearLogFrame() 
    for k in pairs(Skits_Log_UI.frames) do
        local frame = Skits_Log_UI.frames[k]
        if Skits_Log_UI.frames[k] ~= nil then
            Skits_UI_Utils:RemoveFrame(frame) 
            Skits_Log_UI.frames[k] = nil
        end
    end
end

-- Set most recent page
function Skits_Log_UI:SetMostRecentPage()
    isMostRecent = true
    
    msgEleCurr = Skits.msgMemoryQueue.head
    msgEleTop = msgEleCurr
    msgEleBottom = msgEleCurr    
    msgEleDir = -1
end

-- Trigger update
function Skits_Log_UI:RefreshPage()
    if isMostRecent and logFrame:IsShown() then
        Skits_Log_UI:SetMostRecentPage()
        Skits_Log_UI:PopulateLogFrame()
    end
end

-- Navigation button click handlers
prevButton:SetScript("OnClick", function()
    msgEleDir = -1
    isMostRecent = false

    local nextMsgEleBottom = msgEleTop.next
    if nextMsgEleBottom then
        msgEleBottom = nextMsgEleBottom
        msgEleTop = nextMsgEleBottom       
        msgEleCurr =  nextMsgEleBottom
        Skits_Log_UI:PopulateLogFrame()
    end
end)

nextButton:SetScript("OnClick", function()
    msgEleDir = 1

    local nextMsgEleTop = msgEleBottom.prev
    if nextMsgEleTop then
        msgEleBottom = nextMsgEleTop
        msgEleTop = nextMsgEleTop       
        msgEleCurr =  nextMsgEleTop 
        Skits_Log_UI:PopulateLogFrame()   
    end
end)

-- Command to toggle the log frame
SLASH_SkitsLog1 = "/Skitslog"
SlashCmdList["SkitsLog"] = function()
    if logFrame:IsShown() then
        logFrame:Hide()
    else
        isMostRecent = true
        logFrame:Show()
        Skits_Log_UI:RefreshPage()
    end
end
