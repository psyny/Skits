-- Skits_Utils.lua
Skits_Utils = {}

function Skits_Utils:IsInCombat()
    return UnitAffectingCombat("player")
end

function Skits_Utils:IsInInstance()
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

    local inInstance = instanceType ~= "none"

    local playerCount = 1

    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
        playerCount = 1
        -- Check each group member to see if they are a player
        for i = 1, GetNumGroupMembers() do
            local unit = (IsInRaid() and "raid" .. i) or "party" .. i
            if UnitIsPlayer(unit) then
                playerCount = playerCount + 1
            end
        end
    end
    return inInstance, instanceType, playerCount, maxPlayers
end

function Skits_Utils:IsInInstanceSolo()
    local inInstance, instanceType, playerCount, maxPlayers = Skits_Utils:IsInInstance()

    return inInstance and playerCount <= 1
end

function Skits_Utils:IsInInstanceGroup()
    local inInstance, instanceType, playerCount, maxPlayers = Skits_Utils:IsInInstance()

    return inInstance and playerCount > 1
end

function Skits_Utils:AddEleToList(ele, list)
    for _, value in ipairs(list) do
        if value == ele then
            return
        end
    end

    table.insert(list, ele)
end

function Skits_Utils:AddListToList(sourceList, list, avoidDuplicated)
    -- Set, for faster checks
    local set = {}
    if avoidDuplicated == true then
        for _, ele in ipairs(list) do
            set[ele] = true
        end
    end

    -- Add if not already there
    for _, ele in ipairs(sourceList) do
        if avoidDuplicated == false or not set[ele] then
            table.insert(list, ele)
        end
    end
end

function Skits_Utils:MessageDuration(messageText)
    local options = Skits_Options.db

    -- Calculate display duration with minimum of 1 second
    local userCharactersPerSecondOption = Skits_Options.db.speech_speed
    local duration = math.max(#messageText / userCharactersPerSecondOption)

    -- Adjust to limits
    duration = duration + 2 -- Add some seconds to the talk, to consider player reaction to the skit and not only the text length.
    duration = math.max(duration, options.speech_duration_min)
    duration = math.min(duration, options.speech_duration_max)

    return duration
end

function Skits_Utils:Interpolation(targetMin, targetMax, refMin, refMax, refPoint)
    local refRatio = 0
    if refMax == refMin then
        refRatio = 0
    else
        refRatio = (refPoint - refMin) / (refMax - refMin)
    end

    if refRatio < 0 then
        refRatio = 0
    elseif refRatio > 1 then
        refRatio = 1
    end

    local targetPoint = targetMin + (refRatio * (targetMax - targetMin))
    return targetPoint
end

function Skits_Utils:PrintError(msg, debugOnly)
    if not debugOnly or (SkitsDB.debugMode and debugOnly) then
        print("Skits Addon Error: " .. msg) 
    end    
end

function Skits_Utils:PrintInfo(msg, debugOnly)
    if not debugOnly or (SkitsDB.debugMode and debugOnly) then
        print(msg) 
    end    
end

function Skits_Utils:TextIntoPhrases(text)
    local phrases = {}
    -- Use a pattern to match sentences ending with '.', '!', or '?' followed by optional whitespace
    for phrase in text:gmatch("[^%.!?]+[%.!?]?") do
        -- Trim any leading or trailing whitespace from the phrase
        phrase = phrase:match("^%s*(.-)%s*$")
        if phrase ~= "" then
            table.insert(phrases, phrase)
        end
    end
    return phrases
end

function Skits_Utils:FindUnitToken(unitName)
    -- Check the player
    local unittokenname = self:GetUnitTokenFullName("player")    
    if unittokenname == unitName then
        return "player"
    end

    -- Check the target
    local unittokenname = self:GetUnitTokenFullName("target")    
    if unittokenname == unitName then
        return "target"
    end    

    -- Check the party members
    if IsInRaid() then
        -- Look for 
        for i = 1, GetNumGroupMembers() do
            local unittoken = "raid" .. i
            local unittokenname = self:GetUnitTokenFullName(unittoken)
            if unittokenname == unitName then
                return unittoken
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            local unittoken = "party" .. i
            local unittokenname = self:GetUnitTokenFullName(unittoken)
            if unittokenname == unitName then
                return unittoken
            end
        end
    end

    -- Check the nameplates
    for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
        if nameplate.UnitFrame then
            local unittoken = nameplate.UnitFrame.unit
            local unittokenname = self:GetUnitTokenFullName(unittoken)
            if unittokenname == unitName then
                return unittoken
            end
        end
    end

    return nil
end

function Skits_Utils:GetUnitTokenFullName(unitToken)
    local creatureName, creatureServer = UnitName(unitToken)

    if not creatureName then
        return ""
    end 

    if not UnitIsPlayer(unitToken) then
        return creatureName
    end

    if not creatureServer then
        creatureServer = GetRealmName()
    end
    
    creatureName = creatureName .. "-" .. creatureServer
    return creatureName
end