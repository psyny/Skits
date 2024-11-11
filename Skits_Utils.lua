-- Skits_Utils.lua
Skits_Utils = {}

function Skits_Utils:IsInCombat()
    return UnitAffectingCombat("player")
end

function Skits_Utils:IsInInstance()
    local inInstance, instanceType = IsInInstance()
    local playerCount = 1

    if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
        playerCount = 0
        -- Check each group member to see if they are a player
        for i = 1, GetNumGroupMembers() do
            local unit = (IsInRaid() and "raid" .. i) or "party" .. i
            if UnitIsPlayer(unit) then
                playerCount = playerCount + 1
            end
        end
    end
    return inInstance, instanceType, playerCount
end

function Skits_Utils:IsInInstanceSolo()
    local inInstance, instanceType, playerCount = Skits_Utils:IsInInstance()

    return inInstance and playerCount <= 1
end

function Skits_Utils:IsInInstanceGroup()
    local inInstance, instanceType, playerCount = Skits_Utils:IsInInstance()

    return inInstance and playerCount > 1
end