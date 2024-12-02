-- Skits_Style.lua

Skits_Style = {}
Skits_Style.userStyles = {}

function Skits_Style:Initialize()
    local options = Skits_Options.db

    Skits_Style.userStyles = {}

    -- TODO: Check styles defined in options
    -- TEMP: Debug
    table.insert(Skits_Style.userStyles, Skits_Style_Tales)
    --table.insert(Skits_Style.userStyles, Skits_Style_Warcraft)
end

function Skits_Style:NewSpeak(creatureData, textData)
    for _, style in ipairs(Skits_Style.userStyles) do
        style:NewSpeak(creatureData, textData)
    end
end

