-- Skits.lua

---------------------------------------------------------
-- Addon declaration

Skits = LibStub("AceAddon-3.0"):NewAddon("Skits", "AceConsole-3.0", "AceEvent-3.0")
local Skits = Skits
local addonOptions

local allowedTalkEvents = {}

-- Define 5 pastel colors with perceptual differences
Skits.colorPalette = {
    {0.9, 0.7, 0.7},  -- Light pink
    {0.7, 0.9, 0.7},  -- Light green
    {0.7, 0.7, 0.9},  -- Light blue
    {0.9, 0.8, 0.7},  -- Light peach
    {0.8, 0.7, 0.9},  -- Light purple
}

-- Color assignment map to track speaker-color relationships and order
Skits.speakerColorMap = {}  -- Maps speaker names to color indices
Skits.colorUsageOrder = {1, 2, 3, 4, 5}  -- Track the usage order of color indices
Skits.nextColor = 1
Skits.lastSpeaker = ""
Skits.lastSpeakerColor = 0
Skits.speakerColorMapQueue = Skits_Deque:New()
Skits.speakerColorMapQueueLimit = 30
Skits.holdSpeakUntil = GetTime()
Skits.speakerLastInteracting = nil
Skits.speakerInteractRepeats = {}
Skits.speakerInteractRepeatsQueue = Skits_Deque:New()

-- Memory table for last 1000 speaks
Skits.msgMemoryLimit = 1000
Skits.msgMemoryQueue = nil

-- TempDisable
Skits.skitsActive = true

-- Soft Groups
local avoidSoftGroupTokenAdd = {
    ["mou"] = true,
    ["tar"] = true,
    ["nam"] = true,
    ["npc"] = true,
}

-- Gossip Memory
Skits.gossip = {
    options = {
        count = 0,
        byIndex = {},
        byOptionId = {},
    },
    quests = {
        byId = {},
    }    
}

---------------------------------------------------------
-- Addon events

function Skits:OnInitialize()
    -- Debug
    if not SkitsDB.debugMode then
        SkitsDB.debugMode = false
    end
    
	-- Set up our database
    local options = Skits_Options.options
    local defaults = Skits_Options.defaults

	self.db = LibStub("AceDB-3.0"):New("SkitsDB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")   
	addonOptions = self.db.profile
    Skits_Options.db = addonOptions    

	-- Register options table and slash command
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Skits", options)
	self:RegisterChatCommand("handynotes", function() LibStub("AceConfigDialog-3.0"):Open("Skits") end)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Skits", "Skits")

	-- Get the option table for profiles
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    -- Conversation Log
    self.msgMemoryLimit = 1000
    self.msgMemoryQueue = Skits_Deque:New()

    if SkitsDB.conversationLog and SkitsDB.conversationLog.messagesIdx then
        self.msgMemoryQueue:BuildDequeFromList(SkitsDB.conversationLog.messagesIdx)
    else 
        SkitsDB.conversationLog = {
            messages = {},
            messagesIdx = {},
            nextIdx = 1,
        }
    end

    -- Update
    self:GeneralParameterChanges()

    -- Start Subs
    Skits_ID_Store:Initialize()
end

function Skits:OnEnable()
	if not addonOptions.enabled then
		self:Disable()
		return
	end

    self:RegisterEvent("PLAYER_LOGOUT", "PrepareDatabaseForSave")
    self:RegisterEvent("PLAYER_LEAVING_WORLD", "PrepareDatabaseForSave")             

    self:GeneralParameterChanges()
    Skits_ID_Store:Initialize()
end

function Skits:OnDisable()
    self:GeneralParameterChanges()
end

function Skits:GeneralParameterChanges()
	addonOptions = self.db.profile
    Skits_Options.db = addonOptions  

    if addonOptions.block_talking_head == true then
        SetCVar("talkingHeadDisable", 1)
    else
        SetCVar("talkingHeadDisable", 0)
    end

    self:UpdateAllowedTalkEvents()
    Skits_Style:Initialize()
end


function Skits:OnProfileChanged(event, database, newProfileKey)
	addonOptions = database.profile
    Skits_Options.db = database.profile

    Skits:GeneralParameterChanges()
end

function Skits:OnPlayerLogout()
    -- Prepare ID store for saving
    Skits_ID_Store:Initialize()
end

function Skits:PrepareDatabaseForSave()
    -- Runs when logout or reload

    -- Save Message Idxs
    if self.msgMemoryQueue then
        if not SkitsDB.conversationLog then
            SkitsDB.conversationLog = {
                messages = {},
                messagesIdx = {},
                nextIdx = 1,
            }
        end

        SkitsDB.conversationLog.messagesIdx = self.msgMemoryQueue:CreateListFromDeque()      
    end

    -- Save ID Store
    Skits_ID_Store:PrepareDataForSave()
end

---------------------------------------------------------
-- Addon Events Aux

function Skits:UpdateAllowedTalkEvents()
    local options = Skits_Options.db

    allowedTalkEvents = {}

    -- NPC Say Events
    if options.event_msg_monster_yell then
        allowedTalkEvents["CHAT_MSG_MONSTER_YELL"] = true
    end
    if options.event_msg_monster_whisper then
        allowedTalkEvents["CHAT_MSG_MONSTER_WHISPER"] = true
    end
    if options.event_msg_monster_say then
        allowedTalkEvents["CHAT_MSG_MONSTER_SAY"] = true
    end
    if options.event_msg_monster_party then
        allowedTalkEvents["CHAT_MSG_MONSTER_PARTY"] = true
    end

    -- Player Say Events
    if options.event_msg_say then
        allowedTalkEvents["CHAT_MSG_SAY"] = true
    end
    if options.event_msg_yell then
        allowedTalkEvents["CHAT_MSG_YELL"] = true
    end
    if options.event_msg_whisper then
        allowedTalkEvents["CHAT_MSG_WHISPER"] = true
    end
    if options.event_msg_party then
        allowedTalkEvents["CHAT_MSG_PARTY"] = true
    end
    if options.event_msg_party_leader then
        allowedTalkEvents["CHAT_MSG_PARTY_LEADER"] = true
    end
    if options.event_msg_raid then
        allowedTalkEvents["CHAT_MSG_RAID"] = true
    end
    if options.event_msg_raid_leader then
        allowedTalkEvents["CHAT_MSG_RAID_LEADER"] = true
    end
    if options.event_msg_instance_chat then
        allowedTalkEvents["CHAT_MSG_INSTANCE_CHAT"] = true
    end
    if options.event_msg_instance_chat_leader then
        allowedTalkEvents["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true
    end
    if options.event_msg_channel then
        allowedTalkEvents["CHAT_MSG_CHANNEL"] = true
    end
    if options.event_msg_guild then
        allowedTalkEvents["CHAT_MSG_GUILD"] = true
    end
    if options.event_msg_officer then
        allowedTalkEvents["CHAT_MSG_OFFICER"] = true
    end

    return
end


---------------------------------------------------------
-- Main 

local frame = CreateFrame("Frame")

-- Register events
-- Loaders
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")

-- NPC Say
frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
frame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
frame:RegisterEvent("CHAT_MSG_MONSTER_PARTY")


-- Player Say
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:RegisterEvent("CHAT_MSG_OFFICER")

-- Quest Frames 
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("GOSSIP_CLOSED")
frame:RegisterEvent("QUEST_FINISHED")

-- Update
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("TALKINGHEAD_REQUESTED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_STARTED_MOVING")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        Skits:HandleNameplateAdded(...)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        Skits:HandleNameplateRemoved(...)        
    elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        Skits:HandleBossAppearance(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        Skits:HandleTargetChange(...)     
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        Skits:HandleMouseoverChange(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        Skits:HandleRosterChange(...)     
    elseif event == "TALKINGHEAD_REQUESTED" then
        Skits:HandleTalkingHead(...)  
    elseif event == "QUEST_GREETING" then
        Skits:HandleQuestGreeting(...)             
    elseif event == "QUEST_DETAIL" then
        Skits:HandleQuestDetail(...)       
    elseif event == "GOSSIP_SHOW" then
        Skits:HandleGossipShow(...)     
    elseif event == "QUEST_COMPLETE" then
        Skits:HandleQuestComplete(...)           
    elseif event == "GOSSIP_CLOSED" then
        Skits:HandleQuestClosed(...)  
    elseif event == "QUEST_FINISHED" then
        Skits:HandleQuestClosed(...)                              
    elseif event == "PLAYER_STARTED_MOVING" then
        Skits:HandlePlayerMoving(...)    
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" then
        Skits:HandleLogout(event, ...)                        
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        Skits:HandleSituationChangeEvent(event, ...)            
    elseif event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_WHISPER" or event == "CHAT_MSG_MONSTER_PARTY" then
        Skits:HandleNpcChatEvent(event, ...)                 
    else      
        Skits:HandlePlayerChatEvent(event, ...)
    end
end)

-- Function to select color for the speaker dynamically
function Skits:GetColorForSpeaker(name)
    -- Check if the speaker already has an assigned color
    local speakerColorIdx = self.speakerColorMap[name]
    if speakerColorIdx then
        if Skits.lastSpeaker == name or speakerColorIdx ~= Skits.lastSpeakerColor then
            Skits.lastSpeakerColor = speakerColorIdx
            return unpack(self.colorPalette[speakerColorIdx])
        end        
    end

   
    -- Speaker is not assigned or has the same color idx as the last message: assign new color    
    speakerColorIdx = Skits.nextColor

    Skits.nextColor = Skits.nextColor + 1
    if Skits.nextColor > 5 then
        Skits.nextColor = 1
    end

    self.speakerColorMap[name] = speakerColorIdx
    Skits.lastSpeakerColor = speakerColorIdx

    -- Deque Control
    self.speakerColorMapQueue:AddToHead(name)

    -- Trim 
    local overlimit = self.speakerColorMapQueue.size - self.speakerColorMapQueueLimit
    if overlimit > 0 then
        removeds = self.speakerColorMapQueue:RemoveFirstX(overlimit)   
        for _, dataIdx in ipairs(removeds) do
            if dataIdx then
                self.speakerColorMap[dataIdx] = nil
            end
        end        
    end

    -- Return the RGB values of the assigned color
    return unpack(self.colorPalette[speakerColorIdx])
end

-- Store a speak in memory
function Skits:StoreInMemory(creatureData, text, color)
    local memoryIdx = SkitsDB.conversationLog.nextIdx
    SkitsDB.conversationLog.nextIdx = SkitsDB.conversationLog.nextIdx + 1

    local creatureName, creatureServer = UnitName("player")
    if not creatureServer then
        creatureServer = GetRealmName()
    end
    local playerName = creatureName .. "-" .. creatureServer

    local zoneName = GetZoneText()
    --local zoneID = C_Map.GetBestMapForUnit("player")     

    local msgEntry = {
        memoryIdx = memoryIdx,
        creatureData = creatureData,
        text = text,
        color = color,
        timestamp = time(),
        zoneName = zoneName,
        playerName = playerName,
    }

    SkitsDB.conversationLog.messages[memoryIdx] = msgEntry

    -- Deque Control
    self.msgMemoryQueue:AddToHead(memoryIdx)

    -- Trim 
    local overlimit = self.msgMemoryQueue.size - self.msgMemoryLimit
    if overlimit > 0 then
        removeds = self.msgMemoryQueue:RemoveFirstX(overlimit)   
        for _, dataIdx in ipairs(removeds) do
            if dataIdx then
                SkitsDB.conversationLog.messages[dataIdx] = nil
            end
        end        
    end
end

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

local questUpdateVariations = {
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

-- Quest Frames
function Skits:HandleQuestFrame(creatureData, mainText, extraText, priority)
    -- Check if speak was seen recently
    local npcName = Skits_Utils:GetUnitTokenFullName("npc")
    local speakId = npcName .. creatureData.name .. #mainText .. mainText:sub(1, 10)

    Skits_SpeakQueue:RemoveByName(npcName)

    -- Repeat Status xxx
    local alreadySaw = self.speakerInteractRepeats[speakId]
    if alreadySaw then
        if creatureData.isPlayer == false then
            if Skits.speakerLastInteracting ~= nil and Skits.speakerLastInteracting.name == creatureData.name then
                return
            else
                mainText = reGreetingVariations[math.random(#reGreetingVariations)]
                extraText = ""

                local activeQuests = C_GossipInfo.GetActiveQuests()
                if activeQuests and #activeQuests > 0 then
                    mainText = mainText .. " " .. questUpdateVariations[math.random(#questUpdateVariations)]
                    mainText = mainText .. activeQuests[math.random(#activeQuests)].title
                end   
            end
        end
    else
        -- Register as seen
        self.speakerInteractRepeats[speakId] = 1
        self.speakerInteractRepeatsQueue:AddToHead(speakId)
    end

    if creatureData.isPlayer == false then
        Skits.speakerLastInteracting = creatureData
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
    local timeToEndCurrentMessage = self.holdSpeakUntil - GetTime()
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

function Skits:HandleQuestGreeting()
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local npcCreatureData = Skits:BuildCreatureDataOfToken("npc")
    if not npcCreatureData then
        return
    end

    local questText = GetGreetingText()
    if not questText then
        return
    end       

    self:HandleQuestFrame(npcCreatureData, questText, "", 0)
end

local objectiveVariations = {
    "So, what I need is for you to ",
    "Your task is to ",
    "I need you to ",
    "The objective is simple: ",
    "Here's what you must do: ",
    "You have to ",
    "You must ",
    "Your mission is to ",
    "I'm counting on you to ",
}

function Skits:HandleQuestDetail()
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local npcCreatureData = Skits:BuildCreatureDataOfToken("npc")
    if not npcCreatureData then
        return
    end

    local questTitle = GetTitleText()

    local questText = GetQuestText()
    if not questText then
        return
    end       

    local questObjective = GetObjectiveText() or ""
    if #questObjective > 0 then
        local subZoneName = GetSubZoneText()
        local personName = npcCreatureData.name

        -- Replace the person name with I or me
        local subjectPatterns = {
            {"^"..personName.." ", "I "}, -- Name at the start of a sentence
            {" "..personName.." and", " I and"}, -- "John and" → "I and"
            {" "..personName.." is", " I am"}, -- "John is" → "I am"
            {" "..personName.." was", " I was"} -- "John was" → "I was"
        }
    
        -- Patterns for object (replace with "me")
        local objectPatterns = {
            {" "..personName.."%$", " me"}, -- Escape `$` (end of string marker)
            {" "..personName.."%.", " me."}, -- Escape `.` (matches any character)
            {" "..personName.."!", " me!"}, -- `!` does not need escaping in Lua patterns
            {" "..personName.."%?", " me?"}, -- Escape `?` (pattern quantifier)
            {" "..personName.." to", " me to"}, -- No special characters
            {" "..personName.." for", " me for"}, -- No special characters
            {" "..personName.." with", " me with"} -- No special characters
        }        
    
        -- First, replace subjects with "I"
        for _, pattern in ipairs(subjectPatterns) do
            questObjective = questObjective:gsub(pattern[1], pattern[2])
        end
    
        -- Then, replace objects with "me"
        for _, pattern in ipairs(objectPatterns) do
            questObjective = questObjective:gsub(pattern[1], pattern[2])
        end        


        -- Location name
        local prepositions = { "at ", "in ", "on " }
        
        if string.find(questObjective, subZoneName, 1, true) ~= nil then
            for _, preposition in ipairs(prepositions) do
                local searchText = preposition .. subZoneName
                local newText, replacements = questObjective:gsub(searchText, "here", 1) -- Only replace the first match
        
                if replacements > 0 then
                    questObjective = newText -- Update the objective text
                    break -- Stop after the first successful replacement
                end
            end
        end

        -- Avoid corner cases
        questObjective = questObjective:gsub("I here", "I")
        questObjective = questObjective:gsub("I wants", "I want")
        questObjective = questObjective:gsub("I has", "I have")
        questObjective = questObjective:gsub("I's", personName .. "'s")
        questObjective = questObjective:gsub("me's", personName .. "'s")
      
        -- Add Prefix
        if string.sub(questObjective, 1, 1) ~= "I" then
            questObjective = objectiveVariations[math.random(#objectiveVariations)] .. questObjective        
        end
    end
    
    self:HandleQuestFrame(npcCreatureData, questText, questObjective, 0)
end

function Skits:HandleQuestComplete()
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local npcCreatureData = Skits:BuildCreatureDataOfToken("npc")
    if not npcCreatureData then
        return
    end

    local questText = GetRewardText()
    if not questText then
        return
    end       

    self:HandleQuestFrame(npcCreatureData, questText, "", 0)
end

local function GetPlayerGossipInfo()
    -- Update if player is the current    
    local unittoken = "player"
    local playerName = Skits_Utils:GetUnitTokenFullName(unittoken)
    local tempCreatureData = {}
    if unittoken then
        Skits:SetCreatureDataOfToken(unittoken)
        tempCreatureData = Skits:BuildCreatureDataOfToken(unittoken)
    end

    -- Retrieve or set creature ID based on player name
    local creatureData, _ = Skits_ID_Store:GetCreatureDataByName(playerName, true)

    if not creatureData then
        creatureData = {}
    end

    if unittoken then
        creatureData.unitToken = unittoken
    end

    creatureData.isPlayer = true
    creatureData.name = playerName

    -- Merge with our temp creature data
    if tempCreatureData then
        for k, v in pairs(tempCreatureData) do
            if not creatureData[k] then
                creatureData[k] = v
            end
        end
    end

    return creatureData
end


local function PlayerGossipAnswer(answerText) 
    local creatureData = GetPlayerGossipInfo()

    answerText = answerText:gsub("<.-?>", "")
    Skits:HandleQuestFrame(creatureData, answerText, "", 1)
end


local questVariations = {
    {"I would like to talk about the ", " assignment."},  -- Formal
    {"I have some questions about the ", " mission."}, -- Slightly formal
    {"I'm here regarding the quest ", "."}, -- Neutral/formal
    {"Let's discuss the ", " task."}, -- Neutral
    {"So, about ", "..."}, -- Neutral/casual
    {"Hey, I heard something about ", "."}, -- Casual
    {"You got any info about the ", " quest?"}, -- Casual
    {"Tell me more about ", "."}, -- Curious
    {"What do you know about the topic ", "?"},
}


local function PlayerQuestSelected(questTitle) 
    local creatureData = GetPlayerGossipInfo()

    local idx = math.random(#questVariations)
    local answerText = questVariations[idx][1] .. questTitle .. questVariations[idx][2]
    Skits:HandleQuestFrame(creatureData, answerText, "", 1)
end


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

    PlayerGossipAnswer(optionText) 
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

    PlayerGossipAnswer(optionText) 
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

    PlayerGossipAnswer(optionText) 
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

    PlayerQuestSelected(questData.title) 
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

    PlayerQuestSelected(questData.title) 
end)


QuestFrameAcceptButton:HookScript("OnClick", function()    
    --print("Quest Accepted")    
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = acceptVariations[math.random(#acceptVariations)]  
    PlayerGossipAnswer(playerSay)  
end)

QuestFrameDeclineButton:HookScript("OnClick", function()
    --print("Quest Declined")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = declineVariations[math.random(#declineVariations)]  
    PlayerGossipAnswer(playerSay)      
end)

QuestFrameGoodbyeButton:HookScript("OnClick", function()
    --print("Goodbye clicked")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    PlayerGossipAnswer(playerSay)          
end)

QuestFrameCloseButton:HookScript("OnClick", function()
    --print("Quest Frame closed via (X) button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    PlayerGossipAnswer(playerSay)      
end)

GossipFrame.GreetingPanel.GoodbyeButton:HookScript("OnClick", function()
    --print("Gossip Frame closed via GoodBye button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    

    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    PlayerGossipAnswer(playerSay)      
end)

GossipFrameCloseButton:HookScript("OnClick", function()
    --print("Gossip Frame closed via (X) button")
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return 
    end    
        
    local playerSay = goodbyeVariations[math.random(#goodbyeVariations)]  
    PlayerGossipAnswer(playerSay)      
end)

function Skits:HandleGossipShow()
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
                Skits.gossip.options.byIndex[i-1] = goption.name
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
    local npcCreatureData = Skits:BuildCreatureDataOfToken("npc")
    if not npcCreatureData then
        return
    end

    -- Gossip Text
    local gossipText = C_GossipInfo.GetText()
    if not gossipText then
        return
    end    

    self:HandleQuestFrame(npcCreatureData, gossipText, "", 0)
end

function Skits:HandleQuestClosed()
    if self.speakerLastInteracting then
        local creatureData = self.speakerLastInteracting
        self.speakerLastInteracting = nil

        Skits_SpeakQueue:RemoveByName(creatureData.name)
    end 
end

-- Main handler for chat events
function Skits:HandleNpcChatEvent(event, msg, sender, languageName, channelName, target, flags, unknown, channelNumber, channelName2, unknown2, counter, guid)
    if not allowedTalkEvents[event] then
        return
    end

    -- Retrieve or set creature ID based on sender name
    local creatureData, _ = Skits_ID_Store:GetCreatureDataByName(sender, false)

    if not creatureData then
        creatureData = {}
    end

    creatureData.isPlayer = false
    creatureData.name = sender

    local textData = {
        text = msg,
        speed= 1.0,
    }

    self:ChatEvent(creatureData, textData, true)
end

function Skits:HandlePlayerChatEvent(event, msg, sender, languageName, channelName, target, flags, unknown, channelNumber, channelName2, unknown2, counter, guid)
    -- As of NOV 2024, there is no way to get a player display data for later display.
    if not allowedTalkEvents[event] then
        return
    end

    -- Update if player is the current
    local unittoken = Skits_Utils:FindUnitToken(sender)
    local tempCreatureData = {}
    if unittoken then
        self:SetCreatureDataOfToken(unittoken)
        tempCreatureData = self:BuildCreatureDataOfToken(unittoken)
    end

    -- Retrieve or set creature ID based on sender name
    local creatureData, _ = Skits_ID_Store:GetCreatureDataByName(sender, true)

    if not creatureData then
        creatureData = {}
    end

    if unittoken then
        creatureData.unitToken = unittoken
    end

    creatureData.isPlayer = true
    creatureData.name = sender

    -- Merge with our temp creature data
    if tempCreatureData then
        for k, v in pairs(tempCreatureData) do
            if not creatureData[k] then
                creatureData[k] = v
            end
        end
    end

    local textData = {
        text = msg,
        speed = 1.0,
    }

    self:ChatEvent(creatureData, textData, true)
end

function Skits:ChatEvent(creatureData, textData, priority)
    local options = Skits_Options.db
    local r, g, b = self:GetColorForSpeaker(creatureData.name)	
	
    -- Calculate display duration with minimum of 1 second
    local userCharactersPerSecondOption = Skits_Options.db.speech_speed
    local displayDuration = Skits_Utils:MessageDuration(textData.text) / (textData.speed or 1)

    if priority then
        self.holdSpeakUntil = GetTime() + displayDuration
    else
        self.holdSpeakUntil = GetTime()
    end

	-- Store speak information in memory
    self:StoreInMemory(creatureData, textData.text, {r=r, g=g, b=b})

    -- Display text and 3D model
    if self.skitsActive then
        Skits_UI:DisplaySkits(creatureData, textData, r, g, b)
    end

    -- Refresh log page
    Skits_Log_UI:RefreshPage()
    self.lastSpeaker = creatureData.name
end

function Skits:BuildCreatureDataOfToken(unittoken)
    local creatureData = nil

    -- Check if the target is an NPC
    if UnitExists(unittoken) then
        local creatureName, creatureServer = UnitName(unittoken)
        if not UnitIsPlayer(unittoken) then
            -- Avoid adding NPCs in soft group: usually, this functionb would get the npc id of the npc that other players see, not the actual npc fillowing the player.
            -- Eg: Thrall in shadowlands intro maw region will return 167287 when following the player, this will avoid it.
            local isInGroup = UnitCanCooperate("player", unittoken)
            if isInGroup then
                if avoidSoftGroupTokenAdd[string.sub(unittoken, 1, 3)] then
                    return nil
                end
            end
        
            -- Get GUID and creatureID
            local guid = UnitGUID(unittoken)
            if guid then
                local creatureId = tonumber(guid:match("[Creature|Vehicle|Pet|Vignette|Instance]%-.-%-.-%-.-%-.-%-(%d+)"))
                if creatureId then
                    creatureData = {
                        name = creatureName,
                        creatureId = creatureId,
                        isPlayer = false,
                    }
                end
            end
        else
            -- Is Player

            -- Get name
            if not creatureServer then
                creatureServer = GetRealmName()
            end
            local playerName = creatureName .. "-" .. creatureServer

            -- Get race and gender
            local raceName, raceFile, raceID = UnitRace(unittoken)
            local gender = UnitSex(unittoken)
            local genderID = (gender == 2) and 0 or 1

            -- Build Creature data
            creatureData = {
                name = playerName,
                creatureId = playerName,
                raceId = raceID,
                genderId = genderID,
                isPlayer = true,
            }         
        end
    end

    return creatureData
end

function Skits:SetCreatureDataOfToken(unittoken)
    local creatureData = Skits:BuildCreatureDataOfToken(unittoken)

    if not creatureData then
        return
    end

    Skits_ID_Store:SetCreatureData(creatureData, creatureData.isPlayer)
end


-- Handle nameplate addition to update creatureIdMap
function Skits:HandleNameplateAdded(unitToken)
    self:SetCreatureDataOfToken(unitToken)

    if Skits_UI then
        Skits_UI:SpeakerMarker_NameplateAdded(unitToken)
    end
end

function Skits:HandleNameplateRemoved(unitToken)
    if Skits_UI then
        Skits_UI:SpeakerMarker_NameplateRemoved(unitToken)
    end
end

-- Handle the appearance of the new boss
function Skits:HandleBossAppearance()
    -- Iterate over all potential boss frames (boss1, boss2, etc.)
    for i = 1, MAX_BOSS_FRAMES do
        -- Get the GUID of the boss unit (if available)
        local unitToken = "boss" .. i
        self:SetCreatureDataOfToken(unitToken)
    end
end

-- Handle the target change
function Skits:HandleTargetChange()
    self:SetCreatureDataOfToken("target")
end

-- Handle the mouseover change
function Skits:HandleMouseoverChange()
    self:SetCreatureDataOfToken("mouseover")
end

-- Handle the roster change (party or raid changes)
function Skits:HandleRosterChange()
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unittoken = "raid" .. i
            self:SetCreatureDataOfToken(unittoken)
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            local unittoken = "party" .. i
            self:SetCreatureDataOfToken(unittoken)
        end
    end
end

-- Handle talking head appearance
function Skits:HandleTalkingHead()
    self:HandleTalkingHeadAux()
    C_Timer.After(0.1, function() Skits:HandleTalkingHeadAux() end)  
end

function Skits:HandleTalkingHeadAux()
    if TalkingHeadFrame and TalkingHeadFrame:IsShown() then
        -- Save its contents
        local nameText = TalkingHeadFrame.NameFrame.Name:GetText()
        if nameText then
            -- Save Display Id
            local thModel = TalkingHeadFrame.MainFrame.Model
            local displayId = nil
            if thModel then
                displayId = thModel:GetDisplayInfo()
                if displayId then
                    local creatureData = {
                        name = nameText,
                        displayId = displayId,
                    }
                    Skits_ID_Store:SetCreatureData(creatureData, false)

                    if SkitsDB.debugMode then
                        print("[SAVING TALKING HEAD DATA]")
                        print("name: " .. creatureData.name)
                        print("display id: " .. creatureData.displayId)
                    end
                end
            end           
        end

        -- Block it
        if addonOptions.block_talking_head == true then
            TalkingHeadFrame:Hide()
        end
    end
end

-- Handle situation changes that could affect skit styles
function Skits:HandleSituationChangeEvent(event)
    if not Skits_Style then
        return
    end

    if event == "PLAYER_REGEN_DISABLED" then
        -- Entered Combat
        Skits_Style:SituationEnterCombat(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Exited Combat
        Skits_Style:SituationExitCombat(true)
    else
        -- Instance changes
        -- ZONE_CHANGED_NEW_AREA
        -- PLAYER_ENTERING_WORLD    
        Skits_Style:SituationAreaChanged(true)  
    end
end

local debugCombat = true
function Skits:HandlePlayerMoving()
    Skits_Style:SituationMoveExitExploration(true)

    if SkitsDB.debugMode and false then
        debugCombat = not debugCombat
        Skits_Style.inCombat = debugCombat
        Skits_Style:SituationAreaChanged(false)  
    end
end

function Skits:HandleLogout(event)
    --self:PrepareDatabaseForSave()
end

 -- CMD ---------------------------------------------------------------------------------------------------------

-- Quickly toggle skits
SLASH_SkitsToggle1 = "/SkitsToggle"
SlashCmdList["SkitsToggle"] = function()   
    Skits.skitsActive = not Skits.skitsActive
    if Skits.skitsActive then
        print("Skits are now enabled")
    else
        print("Skits are now disabled")
    end
end

-- Debug Toggle
SLASH_SkitsDebug1 = "/SkitsDebug"
SlashCmdList["SkitsDebug"] = function()   
    SkitsDB.debugMode = not SkitsDB.debugMode
    if SkitsDB.debugMode then
        print("Skits Debug is now enabled")
    else
        print("Skits Debug is now disabled")
    end
end





