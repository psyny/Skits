-- Skits_QuestFrame.lua

Skits_QuestFrame = {}
Skits_QuestFrame.speakerLastInteracting = nil
Skits_QuestFrame.speakerInteractRepeats = {}
Skits_QuestFrame.speakerInteractRepeatsQueue = Skits_Deque:New()

local textColors = {
    yellow = "FFFFD100",
}

local function getHighlightedText(text, color)
    if color == nil then
        color = textColors.yellow
    end
    return "|c" .. color .. text .. "|r"
end

-- -----------------------------------------------------------------
-- VARIATIONS
-- -----------------------------------------------------------------

local acceptVariations = {
    "Ok.",
    "Let's do it.",
    "I'm on it.",
    "Consider it done.",
    "I'll handle this.",
    "Yes, I'll help.",
    "I'm in.",
    "You can count on me.",
    "I'll take care of it.",
    "I'm ready for this.",
    "Let's make it happen.",
    "Got it.",
    "This one's mine.",
    "I'll take the job.",
    "Challenge accepted.",
    "I'm up for it.",
    "I'll do what needs to be done.",
    "Leave it to me.",
    "You have my word."
}

local declineVariations = {
    "No, thank you.",
    "I can't do this.",
    "This isn't for me.",
    "Sorry, I'll pass.",
    "Not today.",
    "I'm not interested.",
    "I have to decline.",
    "I can't help with this.",
    "I'll sit this one out.",
    "Nope.",
    "I'll leave this to someone else.",
    "This isn't my fight.",
    "Not my thing.",
    "I'm going to pass on this.",
    "Sorry, I can't.",
    "This isn't my problem.",
    "I won't be able to do this.",
    "I'm out.",
    "Not happening."
}

local goodbyeVariations = {
    "Goodbye.",
    "Farewell.",
    "See you around.",
    "Take care.",
    "Catch you later.",
    "Bye now.",
    "Until next time.",
    "Stay safe.",
    "Later.",
    "So long.",
    "See you soon.",
    "I'll be on my way.",
    "I've got to go.",
    "Be well.",
    "Until we meet again.",
    "I'll see you later."
}

local reGreetingVariations = {
    "Hello again!",
    "Welcome back!",
    "Nice to see you again!",
    "You're back.",
    "Ah, we meet again.",
    "Back so soon?",
    "Good to see you again!",
    "Look who's back!",
    "Welcome back!",
    "How’s it going?",
}

local npcQuestUpdateVariations = {
    "Any updates on ",
    "How is it going with ",
    "Do you have any news about ",
    "Have you made progress on ",
    "What’s the status of ",
    "How goes your task with ",
    "Is there any progress on ",
    "Can you update me on ",
    "How are things with ",
    "Tell me, what’s happening with ",
}

local objectiveVariations = {
    "It seems I have to ",
    "So, I should ",
    "Guess I need to ",
    "Looks like I have to ",
    "I suppose I must ",
    "Oh, I need to ",
    "Alright, I have to ",
    "Seems like my job is to ",
    "Well, time to ",
    "Alright then, I should ",
}

local newQuestVariations = {
    {"About the ", " assignment."}, 
    {"Tell me more about the ", " mission."},
    {"I'm here regarding the ", " quest."}, -- Neutral/formal
    {"Let's discuss the ", " task."}, -- Neutral
    {"So, about ", "..."}, -- Neutral/casual
    {"Hey, what is this ", " subject?"}, -- Casual
    {"You got any info on ", " quest?"}, -- Casual
    {"Tell me more about ", "."}, -- Curious
    {"What do you know about ", "?"},
}

local playerQuestUpdateVariations = {
    {"Let's talk about ", "."},
    {"Got news on ", "."},
    {"Quick update on ", "."},
    {"Need to discuss ", "."},
    {"Here about ", "."},
    {"Reporting on ", "."},
    {"Update for ", "."},
    {"Checking in on ", "."},
    {"Let's go over ", "."},
    {"Progress on ", "."}
}

local questTurnInVariations = {
    {"I'm done with ", " quest."},
    {"Finished ", " task."},
    {"All done with ", " mission."},
    {"Completed ", " objective."},
    {"Reporting completion of ", " assignment."},
    {"That’s it for ", " duty."},
    {"Job’s done for ", " request."},
    {"Wrapping up ", " operation."},
    {"Turning in ", " task."},
    {"Ready to hand in ", " quest."}
}

-- -----------------------------------------------------------------
-- INIT
-- -----------------------------------------------------------------


function Skits_QuestFrame:Initialize()
    Skits_QuestFrame.questGiverModelFrame = self:CreateQuestModelFrame()
end

-----------------------------------------------------------------------------

-- -----------------------------------------------------------------
-- HOOKS
-- -----------------------------------------------------------------

hooksecurefunc('SelectGossipOption', function(index, text, confirm)
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local optionText = Skits.gossip.options.byIndex[index]
    optionText = Skits.gossip.options.byOptionId[index]
    if not optionText then
        return
    end

    Skits_QuestFrame:PlayerQuestTalk(optionText, true)    
end)   

hooksecurefunc(C_GossipInfo, "SelectOption", function(optionID)
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local optionText = Skits.gossip.options.byOptionId[optionID]
    if not optionText then
        return
    end

    Skits_QuestFrame:PlayerQuestTalk(optionText, true)    
end)

hooksecurefunc(C_GossipInfo, "SelectOptionByIndex", function(index, optionText)
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local optionText = Skits.gossip.options.byIndex[index]
    if not optionText then
        return
    end

    Skits_QuestFrame:PlayerQuestTalk(optionText, true)    
end)

hooksecurefunc(C_GossipInfo, "SelectAvailableQuest", function(questID)
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local questData = Skits.gossip.quests.byId[questID]
    if not questData then
        return
    end

    Skits_QuestFrame:PlayerQuestSelected(questData.title, false, false) 
end)

hooksecurefunc(C_GossipInfo, "SelectActiveQuest", function(questID)
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local questData = Skits.gossip.quests.byId[questID]
    if not questData then
        return
    end

    local isCompleted = C_QuestLog.IsComplete(questID)

    Skits_QuestFrame:PlayerQuestSelected(questData.title, true, isCompleted) 
end)


QuestFrameAcceptButton:HookScript("OnClick", function()    
    --print("Quest Accepted")    
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = acceptVariations[math.random(#acceptVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)    
end)

QuestFrameDeclineButton:HookScript("OnClick", function()
    --print("Quest Declined")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = declineVariations[math.random(#declineVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)    
end)

QuestFrameGoodbyeButton:HookScript("OnClick", function()
    --print("Goodbye clicked")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)            
end)

QuestFrameCloseButton:HookScript("OnClick", function()
    --print("Quest Frame closed via (X) button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)       
end)

GossipFrame.GreetingPanel.GoodbyeButton:HookScript("OnClick", function()
    --print("Gossip Frame closed via GoodBye button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)        
end)

GossipFrameCloseButton:HookScript("OnClick", function()
    --print("Gossip Frame closed via (X) button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    
        
    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    Skits_QuestFrame:PlayerQuestTalk(playerSay, true)      
end)


-- -----------------------------------------------------------------
-- PLAYER RELATED
-- -----------------------------------------------------------------

function Skits_QuestFrame:PlayerQuestTalk(text, clearQueue)
    local creatureData = Skits:GetPlayerCreatureData()

    text = text:gsub("<.-?>", "")
    text = text:gsub("%(Quest%)", "")
    text = text:gsub("Make this inn your home.", "Make this inn my home.")    

    self:HandleQuestFrame(creatureData, text, "", 1, clearQueue)
end

function Skits_QuestFrame:PlayerQuestSelected(questTitle, activeQuest, isCompleted) 
    local creatureData = Skits:GetPlayerCreatureData()

    local answerText = questTitle
    if activeQuest == true then
        if isCompleted == true then
            local idx = math.random(#questTurnInVariations)
            answerText = questTurnInVariations[idx][1] .. getHighlightedText(questTitle) .. questTurnInVariations[idx][2]
        else
            local idx = math.random(#playerQuestUpdateVariations)
            answerText = playerQuestUpdateVariations[idx][1] .. getHighlightedText(questTitle) .. playerQuestUpdateVariations[idx][2]
        end
    else
        local idx = math.random(#newQuestVariations)
        answerText = newQuestVariations[idx][1] .. getHighlightedText(questTitle) .. newQuestVariations[idx][2]
    end

    answerText = answerText:gsub("%(Quest%)", "")
    answerText = answerText:gsub("Make this inn your home.", "Make this inn my home.")    

    self:HandleQuestFrame(creatureData, answerText, "", 1, true)
end

-- -----------------------------------------------------------------
-- MAIN FUNC
-- -----------------------------------------------------------------

-- Quest Frames
function Skits_QuestFrame:HandleQuestFrame(creatureData, mainText, extraText, priority, clearQueue)
    -- Check if speak was seen recently
    local npcName = Skits_Utils:GetUnitTokenFullName("npc") or "<no npc>"
    local speakId = npcName .. creatureData.name .. #mainText .. mainText:sub(1, 30)

    if clearQueue == true then
        Skits_SpeakQueue:RemoveByName(npcName)
    end

    -- Repeat Status
    local alreadySaw = self.speakerInteractRepeats[speakId]
    if alreadySaw then
        if creatureData.isPlayer == false then
            if self.speakerLastInteracting ~= nil and self.speakerLastInteracting.name == creatureData.name then
                return
            else
                mainText = reGreetingVariations[math.random(#reGreetingVariations)]
                extraText = ""

                local activeQuests = C_GossipInfo.GetActiveQuests()
                if activeQuests and #activeQuests > 0 then
                    mainText = mainText .. " " .. npcQuestUpdateVariations[math.random(#npcQuestUpdateVariations)]
                    mainText = mainText .. getHighlightedText(activeQuests[math.random(#activeQuests)].title)
                end   
            end
        end
    else
        -- Register as seen
        self.speakerInteractRepeats[speakId] = 1
        self.speakerInteractRepeatsQueue:AddToHead(speakId)
    end

    if creatureData.isPlayer == false then
        self.speakerLastInteracting = creatureData
    end

    -- Full text
    local fullText = mainText
    if #extraText > 0 then
        fullText = fullText .. " " .. extraText
    end

    -- Trim speak ids
    local overlimit = self.speakerInteractRepeatsQueue.size - 1000
    if overlimit > 0 then
        removeds = self.speakerInteractRepeatsQueue:RemoveFirstX(overlimit)   
        for _, removedSpeakId in ipairs(removeds) do
            if removedSpeakId then
                self.speakerInteractRepeats[removedSpeakId] = nil
            end
        end        
    end    

    -- Queue Pause
    local timeToEndCurrentMessage = Skits.holdSpeakUntil - GetTime()
    if timeToEndCurrentMessage < 0 then
        timeToEndCurrentMessage = 0
    end
    local minPause = 0.2
    if creatureData.isPlayer == false then
        minPause = 0
    end
    local pauseDuration = math.max(timeToEndCurrentMessage, minPause)
    Skits_SpeakQueue:AddPause(pauseDuration)

    -- Queue Speak
    local frameTextSpeed = 1.5
    if creatureData.isPlayer == true then
        frameTextSpeed = 3.0
    end

    local phrases = Skits_Utils:TextIntoPhrases(fullText)
    local currSpeakText = ""
    for _, phrase in ipairs(phrases) do
        -- Concatenating will blow size?
        -- If yes, send the current text as
        if #currSpeakText + #phrase > 200 then
            local textPart = currSpeakText
            textPart = textPart .. " <...>"

            local textData = {
                text = textPart,
                speed = frameTextSpeed,
                duration = math.max((Skits_Utils:MessageDuration(currSpeakText) / frameTextSpeed) - 0.1, 1),
            }

            Skits_SpeakQueue:AddSpeaker(creatureData, textData, textData.duration - 0.05, priority)
           
            currSpeakText = ""
        end

        -- Concatenate
        currSpeakText = currSpeakText .. phrase .. " "
    end

    -- Final text
    if #currSpeakText > 1 then
        local textData = {
            text = currSpeakText,
            speed = frameTextSpeed,
            duration = math.max((Skits_Utils:MessageDuration(currSpeakText) / frameTextSpeed) - 0.1, 1),
        }

        Skits_SpeakQueue:AddSpeaker(creatureData, textData, textData.duration - 0.05, priority)
    end
end

-- -----------------------------------------------------------------
-- EVENT HANDLERS
-- -----------------------------------------------------------------

function Skits_QuestFrame:GetQuestGiverCreatureData()
    local giverName = ""

    -- Check if Quest Frame is open
    if QuestFrameNpcNameText and QuestFrameNpcNameText:GetText() then
        giverName = QuestFrameNpcNameText:GetText()
    end

    -- Check if Gossip Frame is open
    local gossipNPCname = UnitName("npc")
    if giverName == "" and gossipNPCname ~= nil then
        giverName = gossipNPCname
    end    

    -- Get Creature Data
    local creatureData = nil

    local playerName = Skits_Utils:GetUnitTokenFullName("player")
    local creatureServer = GetRealmName()
    local fullGiverName = giverName .. "-" .. creatureServer

    if fullGiverName == playerName then
        creatureData = Skits:GetPlayerCreatureData()
    else
        creatureData = Skits:BuildCreatureDataOfToken("npc")
        if not creatureData then
            creatureData = Skits_ID_Store:GetCreatureDataByName(giverName, false)
        end            
    end

    return creatureData
end

function Skits_QuestFrame:HandleQuestGreeting(event)
    local questText = GetGreetingText()
    if not questText then
        questText = ""
    end      
    
    self:AttachFrameToQuestFrame("QuestFrame", questText)
    
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end

    self:HandleQuestFrame(creatureData, questText, "", 0, true)
end

function Skits_QuestFrame:HandleQuestDetail(event)
    local questText = GetQuestText()
    if not questText then
        questText = ""
    end      
    
    self:AttachFrameToQuestFrame("QuestFrame", questText)

    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end

    local questObjective = GetObjectiveText() or ""
    if #questObjective > 0 then
        local subZoneName = GetSubZoneText()

        -- Location name
        local prepositions = { "at ", "in ", "on " }
        
        if string.find(questObjective, subZoneName, 1, true) ~= nil then
            for _, preposition in ipairs(prepositions) do
                local searchText = preposition .. subZoneName
                local newText, replacements = questObjective:gsub(searchText, "here") -- Only replace the first match
        
                if replacements > 0 then
                    questObjective = newText -- Update the objective text
                    break -- Stop after the first successful replacement
                end
            end
        end

        questObjective = "<" .. objectiveVariations[math.random(#objectiveVariations)] .. questObjective .. ">"
    end

    -- NPC Talk (quest text)   
    self:HandleQuestFrame(creatureData, questText, "", 0, true)

    -- Player Talk (quest objective)
    if #questObjective > 0 then
        Skits_QuestFrame:PlayerQuestTalk(questObjective, false) 
    end
end

function Skits_QuestFrame:HandleQuestProgress(event)
    local questText = GetProgressText()
    if not questText then
        questText = ""
    end        
    self:AttachFrameToQuestFrame("QuestFrame", questText)

    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end
   
    self:HandleQuestFrame(creatureData, questText, "", 0, true)
end

function Skits_QuestFrame:HandleQuestComplete(event)
    local questText = GetRewardText()
    if not questText then
        questText = ""
    end        
    self:AttachFrameToQuestFrame("QuestFrame", questText)

    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end

    self:HandleQuestFrame(creatureData, questText, "", 0, true)
end

function Skits_QuestFrame:HandleGossipShow(event)
    -- Gossip Text
    local gossipText = C_GossipInfo.GetText()
    if not gossipText then
        gossipText = ""
    end       
    self:AttachFrameToQuestFrame("GossipFrame", gossipText)

    Skits.gossip.options.count = 0
    Skits.gossip.options.byIndex = {}
    Skits.gossip.options.byOptionId = {}

    local options = Skits_Options.db
    if not options.event_npc_interact then
        return
    end

    -- Gossip Options
    local goptions = C_GossipInfo.GetOptions()
    if goptions then
        for i, goption in ipairs(goptions) do
            if goption.gossipOptionID then
                Skits.gossip.options.byOptionId[goption.gossipOptionID] = goption.name
                Skits.gossip.options.byIndex[goption.orderIndex or (i-1)] = goption.name
                Skits.gossip.options.count = Skits.gossip.options.count + 1
            end
        end
    end   
     
    -- Quest Options
    local availableQuests = C_GossipInfo.GetAvailableQuests()
    if availableQuests and #availableQuests > 0 then
        for i, quest in ipairs(availableQuests) do
            Skits.gossip.quests.byId[quest.questID] = {
                id = quest.questID,
                title = quest.title,
            }
        end
    end    

    -- Get active quests
    local activeQuests = C_GossipInfo.GetActiveQuests()
    if activeQuests and #activeQuests > 0 then
        for i, quest in ipairs(activeQuests) do
            Skits.gossip.quests.byId[quest.questID] = {
                id = quest.questID,
                title = quest.title,
            }        
        end
    end    

    -- Creature Data
    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end 

    self:HandleQuestFrame(creatureData, gossipText, "", 0, true)
end

function Skits_QuestFrame:HandleQuestClosed(event)
    self:DetachFrameFromQuestFrame()

    if self.speakerLastInteracting then
        local creatureData = self.speakerLastInteracting

        Skits_SpeakQueue:RemoveByName(creatureData.name)
    end 
end

-- -----------------------------------------------------------------
-- Quest Speaker Model Frame
-- -----------------------------------------------------------------


function Skits_QuestFrame:CreateQuestModelFrame()    
    local options = Skits_Options.db
    if not options.quest_frame_model_enabled then
        return nil
    end

    local modelSize = options.quest_frame_model_size
    local parentFrame = UIParent

    local frameSizeX = modelSize*0.75
    local frameSizeY = modelSize

    local questModelFrame = {
        main = nil,
        border = nil,
        background = nil,
        model = nil,
        modelLoader = nil,
        modelSize = modelSize,
    }
    local boderSize = 4    

    -- Base Frame
    questModelFrame.main = CreateFrame("Frame", nil, parentFrame)
    questModelFrame.main:SetSize(frameSizeX, frameSizeY)
    questModelFrame.main:SetPoint("BOTTOMLEFT", parentFrame, "TOPLEFT", 50, -50)

    -- Create the border frame to follow the model frame 
    questModelFrame.border = CreateFrame("Frame", nil, questModelFrame.main, "BackdropTemplate")
    questModelFrame.border:SetSize(frameSizeX + (boderSize*2), frameSizeY + (boderSize*2))        
    questModelFrame.border:SetPoint("TOPLEFT", questModelFrame.main, "TOPLEFT", -boderSize, boderSize)
    questModelFrame.border:SetBackdrop({
        bgFile = nil,
        edgeFile = options.quest_frame_model_border,
        edgeSize = 12,
    })

    -- Background Frame
    questModelFrame.background = CreateFrame("Frame", nil, questModelFrame.main, "BackdropTemplate")
    questModelFrame.background:SetSize(frameSizeX + (boderSize*0.8), frameSizeY + (boderSize*0.8))        
    questModelFrame.background:SetPoint("TOPLEFT", questModelFrame.main, "TOPLEFT", -(boderSize*0.4), (boderSize*0.4))
    questModelFrame.background:SetBackdrop({
        bgFile = options.quest_frame_model_bg,
        tile = false, tileSize = 32, edgeSize = 0,
    })

    -- Create the model frame
    questModelFrame.model = CreateFrame("PlayerModel", nil, questModelFrame.main, "BackdropTemplate")
    questModelFrame.model:SetPoint("TOPLEFT", questModelFrame.main, "TOPLEFT", 0, 0)
    questModelFrame.model:SetSize(frameSizeX, frameSizeY)    
    questModelFrame.model:Show()
    Skits_UI_Utils:ModelFrameSetTargetSize(questModelFrame.model, frameSizeX, frameSizeY)
    Skits_UI_Utils:ModelFrameSetVisible(questModelFrame.model, false)

    -- Levels
    questModelFrame.border:SetFrameLevel(100)
    questModelFrame.model:SetFrameLevel(50)
    questModelFrame.background:SetFrameLevel(10)

    questModelFrame.main:Hide()
    return questModelFrame
end


function Skits_QuestFrame:AttachFrameToQuestFrame(framename, questText)
    -- todo: move to local function
    local options = Skits_Options.db

    if not options.quest_frame_model_enabled then
        return
    end
    
    -- Get creature data for the quest giver
    local creatureData = self:GetQuestGiverCreatureData()
    if not creatureData then
        return
    end
    
    -- Get the target frame to attach to
    local targetFrame = nil
    if framename == "QuestFrame" then
        targetFrame = QuestFrame
    elseif framename == "GossipFrame" then
        targetFrame = GossipFrame
    end
    
    if not targetFrame then
        return
    end

    -- Position the model frame relative to the quest frame
    local yOffset = tonumber(options.quest_frame_model_offsety) or -50
    local xOffset = tonumber(options.quest_frame_model_offsetx) or -5

    self.questGiverModelFrame.main:SetPoint("BOTTOMLEFT", targetFrame, "TOPLEFT", xOffset, yOffset)
    self.questGiverModelFrame.main:Show()
    self.questGiverModelFrame.main:SetFrameStrata("HIGH")
    
    -- Build display options for the model
    local light = Skits_Style_Utils:GetHourLight()
    local fallbackId = Skits_Style_Utils.fallbackId
    local fallbackLight = Skits_Style_Utils.lightPresets.hidden
    local pauseAfter = 0
    local animations = {60}
    if options.quest_frame_model_animated then
        if options.quest_frame_model_poser then
            if questText then
                animations = Skits_UI_Utils:GetAnimationIdsFromText(questText, true)        
            end
            pauseAfter = (math.random() * 2)
        else
            pauseAfter = 60
            animations = {60}
        end
    end     
    local displayOptions = Skits_UI_Utils:BuildDisplayOptions(0.9, 0, 1, animations, light, pauseAfter, fallbackId, fallbackLight)
    
    -- Build load options
    local loadOptions = Skits_UI_Utils:BuildLoadOptions(self.questGiverModelFrame.model, nil)
    
    -- Load the model
    self.questGiverModelFrame.modelLoader = Skits_UI_Utils:LoadModel(creatureData, displayOptions, loadOptions)  
    Skits_UI_Utils:ModelFrameSetVisible(self.questGiverModelFrame.model, true)
end

function Skits_QuestFrame:DetachFrameFromQuestFrame()
    local options = Skits_Options.db
    if not options.quest_frame_model_enabled then
        return
    end

    -- Stop and cleanup the current model loader
    if self.questGiverModelFrame and self.questGiverModelFrame.modelLoader then
        Skits_UI_Utils:LoadModelStopTimer(self.questGiverModelFrame.modelLoader)
        self.questGiverModelFrame.modelLoader = nil
    end
    
    -- Clear the model from the frame
    if self.questGiverModelFrame then
        self.questGiverModelFrame.model:ClearModel()
        self.questGiverModelFrame.model.pauseOn = nil
    end
    
    -- Hide the model frame and border
    if self.questGiverModelFrame then
        Skits_UI_Utils:ModelFrameSetVisible(self.questGiverModelFrame.model, false)
    end
    
    if self.questGiverModelFrame then
        self.questGiverModelFrame.main:Hide()
    end
end