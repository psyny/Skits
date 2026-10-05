-- Skits_ZoneGroup_Defs.lua

-- Human editable zone group definitions.
-- Format:
--     ["Group Name"] = { <uiMapID>, {<fromUiMapID>, <toUiMapID>}, ... }
-- A single number is one uiMapID. A pair is an inclusive range of uiMapIDs.
--
-- Resolution rules (see Skits_ZoneGroup.lua):
--     - An explicit uiMapID beats a range.
--     - A narrower range beats a wider one.
--     - A uiMapID with no group falls back to its parent map (see /skitsMapChain), so defining
--       a continent covers every zone, city, micro map and dungeon under it.
--
-- Use /skitsMapChain in game to find and verify uiMapIDs.

Skits_ZoneGroup_Defs = {
    -- Classic / Cataclysm: Kalimdor (12) and Eastern Kingdoms (13) mix eras, so they are not grouped yet.

    ["BurningCrusade"] = {
        101,            -- Outland
    },

    ["WrathOfTheLichKing"] = {
        113,            -- Northrend
    },

    ["MistsOfPandaria"] = {
        424,            -- Pandaria
    },

    ["WarlordsOfDraenor"] = {
        572,            -- Draenor
    },

    ["Legion"] = {
        619,            -- Broken Isles
        905,            -- Argus
    },

    ["BattleForAzeroth"] = {
        875,            -- Zandalar
        876,            -- Kul Tiras
        1355,           -- Nazjatar
        1462,           -- Mechagon
    },

    ["Shadowlands"] = {
        1550,           -- Shadowlands
        1543,           -- The Maw
        1670,           -- Oribos
        1970,           -- Zereth Mortis
    },

    ["Dragonflight"] = {
        1978,           -- Dragon Isles
        {2022, 2025},   -- The Waking Shores, Ohn'ahran Plains, The Azure Span, Thaldraszus
        2112,           -- Valdrakken
        2133,           -- Zaralek Cavern
        2151,           -- The Forbidden Reach
        2200,           -- Emerald Dream
    },

    ["TheWarWithin"] = {
        2274,           -- Khaz Algar
        2248,           -- Isle of Dorn
        {2213, 2215},   -- City of Threads, The Ringing Deeps, Hallowfall
        2255,           -- Azj-Kahet
        2339,           -- Dornogal
        2346,           -- Undermine
        2371,           -- K'aresh
    },

    ["Midnight"] = {
        2393,           -- Silvermoon City (Midnight)
    },
}
