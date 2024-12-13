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
Skits.speakerDurationEnd = GetTime()

-- Memory table for last 1000 speaks
Skits.msgMemoryLimit = 1000
Skits.msgMemoryQueue = nil

-- TempDisable
Skits.skitsActive = true

-- Queued Speaks
Skits.queuedSpeaks = {}
Skits.queuedSpeaksNextId = 1


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

-- Quest Frames
function Skits:ClearQueuedSpeaks()
    for _, handler in pairs(self.queuedSpeaks) do
        if handler then
            handler:Cancel()
        end
    end
    self.queuedSpeaks = {}
end

function Skits:HandleQuestFrame(creatureData, text)
    self:ClearQueuedSpeaks()

    local phrases = Skits_Utils:TextIntoPhrases(text)

    local timeToEndCurrentMessage = self.speakerDurationEnd - GetTime()
    if timeToEndCurrentMessage < 0 then
        timeToEndCurrentMessage = 0
    end

    local accDuration = math.max(timeToEndCurrentMessage, 1)
    for _, phrase in ipairs(phrases) do
        local id = self.queuedSpeaksNextId
        self.queuedSpeaksNextId = self.queuedSpeaksNextId + 1

        local handler = C_Timer.NewTimer(accDuration, function()        
            Skits:ChatEvent(creatureData, phrase)
            self.queuedSpeaks[id] = nil
        end)
        self.queuedSpeaks[id] = handler

        accDuration = accDuration + math.max(Skits_Utils:MessageDuration(phrase) - 0.1, 1)
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
    
    self:HandleQuestFrame(npcCreatureData, questText)
end

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
    
    self:HandleQuestFrame(npcCreatureData, questText)
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
    
    self:HandleQuestFrame(npcCreatureData, questText)
end

function Skits:HandleGossipShow()
    local options = Skits_Options.db
    if not options.event_npc_interact then
        return
    end

    local npcCreatureData = Skits:BuildCreatureDataOfToken("npc")
    if not npcCreatureData then
        return
    end

    local gossipText = C_GossipInfo.GetText()
    if not gossipText then
        return
    end    

    self:HandleQuestFrame(npcCreatureData, gossipText)
end

function Skits:HandleQuestClosed()
    self:ClearQueuedSpeaks()
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

    self:ClearQueuedSpeaks()
    self:ChatEvent(creatureData, msg)
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

    self:ClearQueuedSpeaks()
    self:ChatEvent(creatureData, msg)
end

function Skits:ChatEvent(creatureData, text)
    local options = Skits_Options.db
    local r, g, b = self:GetColorForSpeaker(creatureData.name)	
	
    -- Calculate display duration with minimum of 1 second
    local userCharactersPerSecondOption = Skits_Options.db.speech_speed
    local displayDuration = Skits_Utils:MessageDuration(text)
    self.speakerDurationEnd = GetTime() + displayDuration

	-- Store speak information in memory
	self:StoreInMemory(creatureData, text, {r=r, g=g, b=b})

    -- Display text and 3D model
    if self.skitsActive then
        Skits_UI:DisplaySkits(creatureData, text, r, g, b)
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





