-- Skits_Options.lua
Skits_Options = {}

---------------------------------------------------------
-- Our db upvalue and db defaults

Skits_Options.db = nil
Skits_Options.options = nil
Skits_Options.defaults = nil

---------------------------------------------------------
-- Our options default values

Skits_Options.defaults = {
	profile = {
        enabled                             = true,
        block_talking_head                  = true,           
        combat_easy_in                      = false,
        combat_easy_out                     = true,
        combat_exit_delay                   = 3,
        move_exit_exploration_for           = 0,

        -- Duration
        speech_duration_min                 = 5,        
        speech_duration_max                 = 30,
        speech_speed                        = 15, 

        -- NPC Events
        event_msg_monster_yell       = true,
        event_msg_monster_whisper    = true,
        event_msg_monster_say        = true,
        event_msg_monster_party      = true,

        -- Player Events
        event_msg_say                     = false,
        event_msg_yell                    = false,
        event_msg_whisper                 = false,
        event_msg_party                   = false,
        event_msg_party_leader            = false,
        event_msg_raid                    = false,
        event_msg_raid_leader             = false,
        event_msg_instance_chat           = false,
        event_msg_instance_chat_leader    = false,
        event_msg_channel                 = false,
        event_msg_guild                   = false,
        event_msg_officer                 = false,

        -- Style General
        style_general_styleonsituation_immersive         = "tales",
        style_general_styleonsituation_explore           = "departure",
        style_general_styleonsituation_combat            = "notification",
        style_general_styleonsituation_instance_solo     = "undefined",
        style_general_styleonsituation_instance_group    = "undefined",
        style_general_speaker_marker_size                = 20,    

        -- Style Warcraft
        style_warcraft_strata                                  = "TOOLTIP",
        style_warcraft_click_left                              = "NEXT",
        style_warcraft_click_right                             = "BLOCK",        
        style_warcraft_speech_font_size                        = 12,
        style_warcraft_speech_font_name                        = "Friz Quadrata TT",        
        style_warcraft_speech_position_bottom_distance         = 200,
        style_warcraft_speech_screen_max                       = 4,        
        style_warcraft_speech_screen_combat_max                = 2,        
        style_warcraft_speech_screen_group_instance_max        = 0,
        style_warcraft_speech_screen_solo_instance_max         = 2,
        style_warcraft_speech_frame_size                       = 450,  
        style_warcraft_speaker_face_enabled                    = true,
        style_warcraft_speaker_face_size                       = 100,    
        style_warcraft_speaker_face_animated                   = true,
        style_warcraft_speaker_name_enabled                    = true,  

        -- Style Tales
        style_tales_strata                           = "TOOLTIP",
        style_tales_click_left                       = "NEXT",
        style_tales_click_right                      = "GOTOCOMBAT",           
        style_tales_speech_font_size                 = 12,
        style_tales_speech_font_name                 = "Friz Quadrata TT",        
        style_tales_model_size                       = 500, 
        style_tales_model_poser                      = true,   
        style_tales_speaker_name_enabled             = true,        
        style_tales_previous_speaker_lingertime      = 30,  
        style_tales_always_fullscreen                = true,     

        -- Style Notification
        style_notification_strata                   = "TOOLTIP",
        style_notification_click_left               = "NEXT",
        style_notification_click_right              = "BLOCK",          
        style_notification_instanceoptions          = {
            solo    = {
                inherited                = false,
                speech_font_size         = 12,
                speech_font_name         = "Friz Quadrata TT",        
                portrait_size            = 50, 
                onRight                  = false,
                max_messages             = 3,        
                textarea_size            = 300,
                dist_side                = 30,
                top_side                 = 300,
            },
            small    = {
                inherited                = false,
                speech_font_size         = 12,
                speech_font_name         = "Friz Quadrata TT",        
                portrait_size            = 50, 
                onRight                  = false,
                max_messages             = 2,        
                textarea_size            = 300,
                dist_side                = 300,
                top_side                 = 300,
            },
            medium    = {
                inherited                = true,
                speech_font_size         = 12,
                speech_font_name         = "Friz Quadrata TT",        
                portrait_size            = 50, 
                onRight                  = false,
                max_messages             = 2,        
                textarea_size            = 300,
                dist_side                = 300,
                top_side                 = 300,
            },   
            large    = {
                inherited                = true,
                speech_font_size         = 12,
                speech_font_name         = "Friz Quadrata TT",        
                portrait_size            = 50, 
                onRight                  = false,
                max_messages             = 2,        
                textarea_size            = 300,
                dist_side                = 300,
                top_side                 = 300,
            },                     
        },

        -- Style Departure
        style_departure_strata                           = "TOOLTIP",
        style_departure_click_left                       = "NEXT",
        style_departure_click_right                      = "GOTOCOMBAT",          
        style_departure_speech_font_size                 = 12,
        style_departure_speech_font_name                 = "Friz Quadrata TT",        
        style_departure_model_size                       = 500, 
        style_departure_model_poser                      = true,       
        style_departure_previous_speaker_lingertime      = 30,       

        -- Quests
        event_npc_interact                               = false,  
        quest_frame_model_enabled                        = false,
        quest_frame_model_size                           = 120,
        quest_frame_model_offsetx                        = -5,
        quest_frame_model_offsety                        = -50,
        quest_frame_model_animated                       = false,
        quest_frame_model_poser                          = false,
        quest_frame_model_bg                             = "Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal",
        quest_frame_model_border                         = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
	},  
}

---------------------------------------------------------
-- Lists

local function GetStyleOptions()
    return {
        ["hidden"] = "Hidden",
        ["undefined"] = "Undefined",
        ["warcraft"] = "Warcraft",
        ["tales"] = "Tales",
        ["notification"] = "Notification",
        ["departure"] = "Departure",
    }
end

local function GetStrataOptions()
    return {
        ["BACKGROUND"] = "Background",
        ["LOW"] = "Low",
        ["MEDIUM"] = "Medium",
        ["HIGH"] = "High",
        ["DIALOG"] = "Dialog",
        ["FULLSCREEN"] = "Fullscreen",
        ["FULLSCREEN_DIALOG"] = "Fullscreen Dialog",
        ["TOOLTIP"] = "Tooltip",
    }
end

local function GetClickOptions()
    return {
        ["PASS"] = "Pass Click to UI Below",
        ["BLOCK"] = "Block Clicks",
        ["CLOSE"] = "Close Skit",
        ["HIDE"] = "Hide Skit",
        ["NEXT"] = "Show Next Speech",
        ["GOTOCOMBAT"] = "Switch to Combat Style Skit",
    }
end

local function GetQuestModelBackgroundOptions()
    return {
        ["Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal"] = "Guild Achievement Parchment",
        ["Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal"] = "Achievement Parchment",
        ["Interface\\FrameGeneral\\UI-Background-Marble"] = "Marble Background",
        ["Interface\\DialogFrame\\UI-DialogBox-Background-Dark"] = "Dark Dialog Background",
        ["Interface\\TabardFrame\\TabardFrameBackground"] = "Tabard Background",
    }
end

local function GetQuestModelBorderOptions()
    return {
        ["Interface\\DialogFrame\\UI-DialogBox-Gold-Border"] = "Gold Dialog Border",
        ["Interface\\DialogFrame\\UI-DialogBox-Border"] = "Standard Dialog Border",
        ["Interface\\Tooltips\\UI-Tooltip-Border"] = "Tooltip Border",
        ["Interface\\FriendsFrame\\UI-Toast-Border"] = "Toast Border",
    }
end


---------------------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("Skits", false)
local LSM = LibStub("LibSharedMedia-3.0")
local optionWidth = 2.0

local function GetNotificationInstanceOptions()
    return {
        style_notification_inherited = {
            type = "toggle",
            name = L["Skits.options.style_notification_inherited.title"],
            desc = L["Skits.options.style_notification_inherited.desc"],
            arg = "inherited",
            order = 3,
            width = optionWidth,
        },        
        style_notification_speech_font_size = {
            type = "range",
            name = L["Skits.options.style_any_speech_font_size.title"],
            desc = L["Skits.options.style_any_speech_font_size.desc"],
            min = 4, max = 30, step = 1,
            arg = "speech_font_size",
            order = 4,
            width = optionWidth,
        },
        style_notification_speech_font_name = {
            type = "select",
            name = L["Skits.options.style_any_speech_font_name.title"],
            desc = L["Skits.options.style_any_speech_font_name.desc"],
            values = function()
                return LSM:HashTable("font")
            end,
            dialogControl = "LSM30_Font",
            arg = "speech_font_name",
            order = 5,
            width = optionWidth,
        },   
        style_notification_onRight = {
            type = "toggle",
            name = L["Skits.options.style_notification_onRight.title"],
            desc = L["Skits.options.style_notification_onRight.desc"],
            arg = "onRight",
            order = 6,
            width = optionWidth,
        },   
        style_notification_portrait_size = {
            type = "range",
            name = L["Skits.options.style_notification_portrait_size.title"],
            desc = L["Skits.options.style_notification_portrait_size.desc"],
            min = 5, max = 200, step = 5,
            arg = "portrait_size",
            order = 7,
            width = optionWidth,
        },    
        style_notification_max_messages = {
            type = "range",
            name = L["Skits.options.style_notification_max_messages.title"],
            desc = L["Skits.options.style_notification_max_messages.desc"],
            min = 1, max = 10, step = 1,
            arg = "max_messages",
            order = 8,
            width = optionWidth,
        },   
        style_notification_textarea_size = {
            type = "range",
            name = L["Skits.options.style_notification_textarea_size.title"],
            desc = L["Skits.options.style_notification_textarea_size.desc"],
            min = 50, max = 500, step = 50,
            arg = "textarea_size",
            order = 9,
            width = optionWidth,
        },          
        style_notification_dist_side = {
            type = "range",
            name = L["Skits.options.style_notification_dist_side.title"],
            desc = L["Skits.options.style_notification_dist_side.desc"],
            min = 0, max = 500, step = 5,
            arg = "dist_side",
            order = 10,
            width = optionWidth,
        },     
        style_notification_top_side = {
            type = "range",
            name = L["Skits.options.style_notification_top_side.title"],
            desc = L["Skits.options.style_notification_top_side.desc"],
            min = 0, max = 1000, step = 10,
            arg = "top_side",
            order = 11,
            width = optionWidth,
        },  
    }  
end

-- Our options table
Skits_Options.options = {
	type = "group",
	name = L["Skits.options.Skits.title"],
	desc = L["Skits.options.Skits.desc"],
    childGroups = "tab",
	args = {
        tab_general = {
            type = "group",
            name = "General",
            order = 1,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,   
            disabled = false,         
            args = {
                enabled = {
                    type = "toggle",
                    name = L["Skits.options.enabled.title"],
                    desc = L["Skits.options.enabled.desc"],
                    arg = "enabled",
                    order = 1,
                    width = optionWidth,
                },
                block_talking_head = {
                    type = "toggle",
                    name = L["Skits.options.block_talking_head.title"],
                    desc = L["Skits.options.block_talking_head.desc"],
                    arg = "block_talking_head",
                    order = 2,
                    width = optionWidth,
                },   
                combat_easy_in = {
                    type = "toggle",
                    name = L["Skits.options.combat_easy_in.title"],
                    desc = L["Skits.options.combat_easy_in.desc"],
                    arg = "combat_easy_in",
                    order = 3,
                    width = optionWidth,
                },      
                combat_easy_out = {
                    type = "toggle",
                    name = L["Skits.options.combat_easy_out.title"],
                    desc = L["Skits.options.combat_easy_out.desc"],
                    arg = "combat_easy_out",
                    order = 4,
                    width = optionWidth,
                },   
                combat_exit_delay = {
                    type = "range",
                    name = L["Skits.options.combat_exit_delay.title"],
                    desc = L["Skits.options.combat_exit_delay.desc"],
                    min = 0, max = 60, step = 1,
                    arg = "combat_exit_delay",
                    order = 5,
                    width = optionWidth,  
                },    
                move_exit_exploration_for = {
                    type = "range",
                    name = L["Skits.options.move_exit_exploration_for.title"],
                    desc = L["Skits.options.move_exit_exploration_for.desc"],
                    min = 0, max = 60, step = 1,
                    arg = "move_exit_exploration_for",
                    order = 6,
                    width = optionWidth,  
                },                                                                     
            },
        },
        tab_quests = {
            type = "group",
            name = "Quests",
            order = 2,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,   
            disabled = false,         
            args = {
                event_npc_interact = {
                    type = "toggle",
                    name = L["Skits.options.event_npc_interact.title"],
                    desc = L["Skits.options.event_npc_interact.desc"],
                    arg = "event_npc_interact",
                    order = 1,
                    width = optionWidth,
                },
                quest_frame_model_enabled = {
                    type = "toggle",
                    name = L["Skits.options.quest_frame_model_enabled.title"],
                    desc = L["Skits.options.quest_frame_model_enabled.desc"],
                    arg = "quest_frame_model_enabled",
                    order = 2,
                    width = optionWidth,
                },
                quest_frame_model_size = {
                    type = "range",
                    name = L["Skits.options.quest_frame_model_size.title"],
                    desc = L["Skits.options.quest_frame_model_size.desc"],
                    min = 20, max = 200, step = 5,
                    arg = "quest_frame_model_size",
                    order = 3,
                    width = optionWidth,
                },
                quest_frame_model_offsetx = {
                    type = "input",
                    name = L["Skits.options.quest_frame_model_offsetx.title"],
                    desc = L["Skits.options.quest_frame_model_offsetx.desc"],
                    min = -2000, max = 2000, step = 5,                    
                    arg = "quest_frame_model_offsetx",
                    order = 4,
                    width = optionWidth,
                },
                quest_frame_model_offsety = {
                    type = "input",
                    name = L["Skits.options.quest_frame_model_offsety.title"],
                    desc = L["Skits.options.quest_frame_model_offsety.desc"],
                    min = -2000, max = 2000, step = 5,                    
                    arg = "quest_frame_model_offsety",
                    order = 5,
                    width = optionWidth,
                },
                quest_frame_model_animated = {
                    type = "toggle",
                    name = L["Skits.options.quest_frame_model_animated.title"],
                    desc = L["Skits.options.quest_frame_model_animated.desc"],
                    arg = "quest_frame_model_animated",
                    order = 6,
                    width = optionWidth,
                },
                quest_frame_model_poser = {
                    type = "toggle",
                    name = L["Skits.options.quest_frame_model_poser.title"],
                    desc = L["Skits.options.quest_frame_model_poser.desc"],
                    arg = "quest_frame_model_poser",
                    order = 7,
                    width = optionWidth,
                },
                quest_frame_model_bg = {
                    type = "select",
                    name = L["Skits.options.quest_frame_model_bg.title"],
                    desc = L["Skits.options.quest_frame_model_bg.desc"],
                    values = function()
                        return GetQuestModelBackgroundOptions()
                    end,
                    arg = "quest_frame_model_bg",
                    order = 8,
                    width = optionWidth,
                },
                quest_frame_model_border = {
                    type = "select",
                    name = L["Skits.options.quest_frame_model_border.title"],
                    desc = L["Skits.options.quest_frame_model_border.desc"],
                    values = function()
                        return GetQuestModelBorderOptions()
                    end,
                    arg = "quest_frame_model_border",
                    order = 9,
                    width = optionWidth,
                },
            },
        },
        tab_speech_events = {
            type = "group",
            name = "Events",
            order = 3,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,
            disabled = false,
            args = {
                -- NPC Events
                event_msg_monster_yell = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_monster_yell.title"],
                    desc = L["Skits.options.event_msg_monster_yell.desc"],
                    arg = "event_msg_monster_yell",
                    order = 1,
                    width = optionWidth,
                },
                event_msg_monster_whisper = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_monster_whisper.title"],
                    desc = L["Skits.options.event_msg_monster_whisper.desc"],
                    arg = "event_msg_monster_whisper",
                    order = 2,
                    width = optionWidth,
                },
                event_msg_monster_say = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_monster_say.title"],
                    desc = L["Skits.options.event_msg_monster_say.desc"],
                    arg = "event_msg_monster_say",
                    order = 3,
                    width = optionWidth,
                },
                event_msg_monster_party = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_monster_party.title"],
                    desc = L["Skits.options.event_msg_monster_party.desc"],
                    arg = "event_msg_monster_party",
                    order = 4,
                    width = optionWidth,
                },              
            
                -- Player Events
                event_msg_say = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_say.title"],
                    desc = L["Skits.options.event_msg_say.desc"],
                    arg = "event_msg_say",
                    order = 6,
                    width = optionWidth,
                },
                event_msg_yell = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_yell.title"],
                    desc = L["Skits.options.event_msg_yell.desc"],
                    arg = "event_msg_yell",
                    order = 7,
                    width = optionWidth,
                },
                event_msg_whisper = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_whisper.title"],
                    desc = L["Skits.options.event_msg_whisper.desc"],
                    arg = "event_msg_whisper",
                    order = 8,
                    width = optionWidth,
                },
                event_msg_party = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_party.title"],
                    desc = L["Skits.options.event_msg_party.desc"],
                    arg = "event_msg_party",
                    order = 9,
                    width = optionWidth,
                },
                event_msg_party_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_party_leader.title"],
                    desc = L["Skits.options.event_msg_party_leader.desc"],
                    arg = "event_msg_party_leader",
                    order = 10,
                    width = optionWidth,
                },
                event_msg_raid = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_raid.title"],
                    desc = L["Skits.options.event_msg_raid.desc"],
                    arg = "event_msg_raid",
                    order = 11,
                    width = optionWidth,
                },
                event_msg_raid_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_raid_leader.title"],
                    desc = L["Skits.options.event_msg_raid_leader.desc"],
                    arg = "event_msg_raid_leader",
                    order = 12,
                    width = optionWidth,
                },
                event_msg_instance_chat = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_instance_chat.title"],
                    desc = L["Skits.options.event_msg_instance_chat.desc"],
                    arg = "event_msg_instance_chat",
                    order = 13,
                    width = optionWidth,
                },
                event_msg_instance_chat_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_instance_chat_leader.title"],
                    desc = L["Skits.options.event_msg_instance_chat_leader.desc"],
                    arg = "event_msg_instance_chat_leader",
                    order = 14,
                    width = optionWidth,
                },
                event_msg_channel = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_channel.title"],
                    desc = L["Skits.options.event_msg_channel.desc"],
                    arg = "event_msg_channel",
                    order = 15,
                    width = optionWidth,
                },
                event_msg_guild = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_guild.title"],
                    desc = L["Skits.options.event_msg_guild.desc"],
                    arg = "event_msg_guild",
                    order = 16,
                    width = optionWidth,
                },
                event_msg_officer = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_officer.title"],
                    desc = L["Skits.options.event_msg_officer.desc"],
                    arg = "event_msg_officer",
                    order = 17,
                    width = optionWidth,
                },
            }
        },   
        tab_style = {
            type = "group",
            name = "Style", 
            childGroups = "tab",           
            order = 4,
            args = {
                tab_style_general = {
                    type = "group",
                    name = "General",
                    order = 1,
                    get = function(info) return Skits_Options.db[info.arg] end,
                    set = function(info, v)
                        local arg = info.arg
                        Skits_Options.db[arg] = v
                        Skits:GeneralParameterChanges()
                    end,
                    disabled = false,
                    args = {
                        style_general_styleonsituation_immersive = {
                            type = "select",
                            name = L["Skits.options.style_general_styleonsituation_immersive.title"],
                            desc = L["Skits.options.style_general_styleonsituation_immersive.desc"],
                            values = function()
                                return GetStyleOptions()
                            end,
                            arg = "style_general_styleonsituation_immersive",
                            order = 1,
                            width = optionWidth,
                        },                           
                        style_general_styleonsituation_explore = {
                            type = "select",
                            name = L["Skits.options.style_general_styleonsituation_explore.title"],
                            desc = L["Skits.options.style_general_styleonsituation_explore.desc"],
                            values = function()
                                return GetStyleOptions()
                            end,
                            arg = "style_general_styleonsituation_explore",
                            order = 2,
                            width = optionWidth,
                        },                         
                        style_general_styleonsituation_combat = {
                            type = "select",
                            name = L["Skits.options.style_general_styleonsituation_combat.title"],
                            desc = L["Skits.options.style_general_styleonsituation_combat.desc"],
                            values = function()
                                return GetStyleOptions()
                            end,
                            arg = "style_general_styleonsituation_combat",
                            order = 3,
                            width = optionWidth,
                        }, 
                        style_general_styleonsituation_instance_solo = {
                            type = "select",
                            name = L["Skits.options.style_general_styleonsituation_instance_solo.title"],
                            desc = L["Skits.options.style_general_styleonsituation_instance_solo.desc"],
                            values = function()
                                return GetStyleOptions()
                            end,
                            arg = "style_general_styleonsituation_instance_solo",
                            order = 4,
                            width = optionWidth,
                        },     
                        style_general_styleonsituation_instance_group = {
                            type = "select",
                            name = L["Skits.options.style_general_styleonsituation_instance_group.title"],
                            desc = L["Skits.options.style_general_styleonsituation_instance_group.desc"],
                            values = function()
                                return GetStyleOptions()
                            end,
                            arg = "style_general_styleonsituation_instance_group",
                            order = 5,
                            width = optionWidth,
                        }, 
                        style_general_speaker_marker_size = {
                            type = "range",
                            name = L["Skits.options.style_general_speaker_marker_size.title"],
                            desc = L["Skits.options.style_general_speaker_marker_size.desc"],
                            min = 0, max = 50, step = 5,
                            arg = "style_general_speaker_marker_size",
                            order = 6,
                            width = optionWidth,  
                        },                                              
                    },
                },
                tab_style_warcraft = {
                    type = "group",
                    name = "Warcraft",
                    order = 2,
                    get = function(info) return Skits_Options.db[info.arg] end,
                    set = function(info, v)
                        local arg = info.arg
                        Skits_Options.db[arg] = v
                        Skits:GeneralParameterChanges()
                    end,
                    disabled = false,
                    args = {
                        style_warcraft_strata = {
                            type = "select",
                            name = L["Skits.options.style_any_strata.title"],
                            desc = L["Skits.options.style_any_strata.desc"],
                            values = function()
                                return GetStrataOptions()
                            end,
                            arg = "style_warcraft_strata",
                            order = 1,
                            width = optionWidth,
                        },  
                        style_warcraft_click_left = {
                            type = "select",
                            name = L["Skits.options.style_any_click_left.title"],
                            desc = L["Skits.options.style_any_click_left.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_warcraft_click_left",
                            order = 2,
                            width = optionWidth,
                        },  
                        style_warcraft_click_right = {
                            type = "select",
                            name = L["Skits.options.style_any_click_right.title"],
                            desc = L["Skits.options.style_any_click_right.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_warcraft_click_right",
                            order = 3,
                            width = optionWidth,
                        },                                                                          
                        style_warcraft_speech_font_size = {
                            type = "range",
                            name = L["Skits.options.style_any_speech_font_size.title"],
                            desc = L["Skits.options.style_any_speech_font_size.desc"],
                            min = 4, max = 30, step = 1,
                            arg = "style_warcraft_speech_font_size",
                            order = 4,
                            width = optionWidth,
                        },
                        style_warcraft_speech_font_name = {
                            type = "select",
                            name = L["Skits.options.style_any_speech_font_name.title"],
                            desc = L["Skits.options.style_any_speech_font_name.desc"],
                            values = function()
                                return LSM:HashTable("font")
                            end,
                            dialogControl = "LSM30_Font",
                            arg = "style_warcraft_speech_font_name",
                            order = 5,
                            width = optionWidth,
                        },   
                        style_warcraft_speaker_name_enabled = {
                            type = "toggle",
                            name = L["Skits.options.style_warcraft_speaker_name_enabled.title"],
                            desc = L["Skits.options.style_warcraft_speaker_name_enabled.desc"],
                            arg = "style_warcraft_speaker_name_enabled",
                            order = 6,
                            width = optionWidth,
                        },   
                        style_warcraft_speaker_face_enabled = {
                            type = "toggle",
                            name = L["Skits.options.style_warcraft_speaker_face_enabled.title"],
                            desc = L["Skits.options.style_warcraft_speaker_face_enabled.desc"],
                            arg = "style_warcraft_speaker_face_enabled",
                            order = 7,
                            width = optionWidth,
                        },
                        style_warcraft_speaker_face_size = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speaker_face_size.title"],
                            desc = L["Skits.options.style_warcraft_speaker_face_size.desc"],
                            min = 20, max = 200, step = 10,
                            arg = "style_warcraft_speaker_face_size",
                            order = 8,
                            width = optionWidth,
                        },    
                        style_warcraft_speaker_face_animated = {
                            type = "toggle",
                            name = L["Skits.options.style_warcraft_speaker_face_animated.title"],
                            desc = L["Skits.options.style_warcraft_speaker_face_animated.desc"],
                            arg = "style_warcraft_speaker_face_animated",
                            order = 9,
                            width = optionWidth,
                        },                                                                                           
                        style_warcraft_speech_screen_max = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_screen_max.title"],
                            desc = L["Skits.options.style_warcraft_speech_screen_max.desc"],
                            min = 0, max = 8, step = 1,
                            arg = "style_warcraft_speech_screen_max",
                            order = 10,
                            width = optionWidth,
                        },
                        style_warcraft_speech_screen_combat_max = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_screen_combat_max.title"],
                            desc = L["Skits.options.style_warcraft_speech_screen_combat_max.desc"],
                            min = 0, max = 8, step = 1,
                            arg = "style_warcraft_speech_screen_combat_max",
                            order = 11,
                            width = optionWidth,
                        },
                        style_warcraft_speech_screen_group_instance_max = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_screen_group_instance_max.title"],
                            desc = L["Skits.options.style_warcraft_speech_screen_group_instance_max.desc"],
                            min = 0, max = 8, step = 1,
                            arg = "style_warcraft_speech_screen_group_instance_max",
                            order = 12,
                            width = optionWidth,
                        },
                        style_warcraft_speech_screen_solo_instance_max = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_screen_solo_instance_max.title"],
                            desc = L["Skits.options.style_warcraft_speech_screen_solo_instance_max.desc"],
                            min = 0, max = 8, step = 1,
                            arg = "style_warcraft_speech_screen_solo_instance_max",
                            order = 13,
                            width = optionWidth,
                        },                   
                        style_warcraft_speech_position_bottom_distance = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_position_bottom_distance.title"],
                            desc = L["Skits.options.style_warcraft_speech_position_bottom_distance.desc"],
                            min = 0, max = 1000, step = 50,
                            arg = "style_warcraft_speech_position_bottom_distance",
                            order = 14,
                            width = optionWidth,
                        },      
                        style_warcraft_speech_frame_size = {
                            type = "range",
                            name = L["Skits.options.style_warcraft_speech_frame_size.title"],
                            desc = L["Skits.options.style_warcraft_speech_frame_size.desc"],
                            min = 150, max = 1000, step = 50,
                            arg = "style_warcraft_speech_frame_size",
                            order = 15,
                            width = optionWidth,
                        },                                                                                           
                    },
                },      
                tab_style_tales = {
                    type = "group",
                    name = "Tales",
                    order = 3,
                    get = function(info) return Skits_Options.db[info.arg] end,
                    set = function(info, v)
                        local arg = info.arg
                        Skits_Options.db[arg] = v
                        Skits:GeneralParameterChanges()
                    end,
                    disabled = false,
                    args = {
                        style_tales_strata = {
                            type = "select",
                            name = L["Skits.options.style_any_strata.title"],
                            desc = L["Skits.options.style_any_strata.desc"],
                            values = function()
                                return GetStrataOptions()
                            end,
                            arg = "style_tales_strata",
                            order = 1,
                            width = optionWidth,
                        },  
                        style_tales_click_left = {
                            type = "select",
                            name = L["Skits.options.style_any_click_left.title"],
                            desc = L["Skits.options.style_any_click_left.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_tales_click_left",
                            order = 2,
                            width = optionWidth,
                        },  
                        style_tales_click_right = {
                            type = "select",
                            name = L["Skits.options.style_any_click_right.title"],
                            desc = L["Skits.options.style_any_click_right.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_tales_click_right",
                            order = 3,
                            width = optionWidth,
                        },                          
                        style_tales_always_fullscreen = {
                            type = "toggle",
                            name = L["Skits.options.style_tales_always_fullscreen.title"],
                            desc = L["Skits.options.style_tales_always_fullscreen.desc"],
                            arg = "style_tales_always_fullscreen",
                            order = 4,
                            width = optionWidth,
                        },                                                   
                        style_tales_speech_font_size = {
                            type = "range",
                            name = L["Skits.options.style_any_speech_font_size.title"],
                            desc = L["Skits.options.style_any_speech_font_size.desc"],
                            min = 4, max = 30, step = 1,
                            arg = "style_tales_speech_font_size",
                            order = 5,
                            width = optionWidth,
                        },
                        style_tales_speech_font_name = {
                            type = "select",
                            name = L["Skits.options.style_any_speech_font_name.title"],
                            desc = L["Skits.options.style_any_speech_font_name.desc"],
                            values = function()
                                return LSM:HashTable("font")
                            end,
                            dialogControl = "LSM30_Font",
                            arg = "style_tales_speech_font_name",
                            order = 6,
                            width = optionWidth,
                        },                       
                        style_tales_speaker_name_enabled = {
                            type = "toggle",
                            name = L["Skits.options.style_tales_speaker_name_enabled.title"],
                            desc = L["Skits.options.style_tales_speaker_name_enabled.desc"],
                            arg = "style_tales_speaker_name_enabled",
                            order = 7,
                            width = optionWidth,
                        },   
                        style_tales_model_size = {
                            type = "range",
                            name = L["Skits.options.style_tales_model_size.title"],
                            desc = L["Skits.options.style_tales_model_size.desc"],
                            min = 50, max = 800, step = 50,
                            arg = "style_tales_model_size",
                            order = 8,
                            width = optionWidth,
                        },   
                        style_tales_model_poser = {
                            type = "toggle",
                            name = L["Skits.options.style_tales_model_poser.title"],
                            desc = L["Skits.options.style_tales_model_poser.desc"],
                            arg = "style_tales_model_poser",
                            order = 9,
                            width = optionWidth,
                        },                              
                        style_tales_previous_speaker_lingertime = {
                            type = "range",
                            name = L["Skits.options.style_tales_previous_speaker_lingertime.title"],
                            desc = L["Skits.options.style_tales_previous_speaker_lingertime.desc"],
                            min = 0, max = 60, step = 1,
                            arg = "style_tales_previous_speaker_lingertime",
                            order = 10,
                            width = optionWidth,
                        },                                                                                                                                   
                    },
                },       
                tab_style_notification = {
                    type = "group",
                    name = "Notification",
                    childGroups = "tab",
                    order = 4,
                    disabled = false,
                    args = {
                        tab_style_notification_general = {
                            type = "group",
                            name = "General",
                            order = 1,
                            get = function(info) return Skits_Options.db[info.arg] end,
                            set = function(info, v)
                                local arg = info.arg
                                Skits_Options.db[arg] = v
                                Skits:GeneralParameterChanges()
                            end,
                            disabled = false,
                            args = {
                                style_notification_strata = {
                                    type = "select",
                                    name = L["Skits.options.style_any_strata.title"],
                                    desc = L["Skits.options.style_any_strata.desc"],
                                    values = function()
                                        return GetStrataOptions()
                                    end,
                                    arg = "style_notification_strata",
                                    order = 1,
                                    width = optionWidth,
                                },   
                                style_notification_click_left = {
                                    type = "select",
                                    name = L["Skits.options.style_any_click_left.title"],
                                    desc = L["Skits.options.style_any_click_left.desc"],
                                    values = function()
                                        return GetClickOptions()
                                    end,
                                    arg = "style_notification_click_left",
                                    order = 2,
                                    width = optionWidth,
                                },  
                                style_notification_click_right = {
                                    type = "select",
                                    name = L["Skits.options.style_any_click_right.title"],
                                    desc = L["Skits.options.style_any_click_right.desc"],
                                    values = function()
                                        return GetClickOptions()
                                    end,
                                    arg = "style_notification_click_right",
                                    order = 3,
                                    width = optionWidth,
                                },    
                            },
                        },
                        style_notification_instance_options = {
                            type = "group",
                            name = "By Instance Size",
                            childGroups = "tab",           
                            order = 2,
                            args = {
                                style_notification_instance_option_solo = {
                                    type = "group",
                                    name = "Solo",
                                    desc = "= 1 player",
                                    order = 1,
                                    get = function(info) 
                                        return Skits_Options.db["style_notification_instanceoptions"]["solo"][info.arg] 
                                    end,
                                    set = function(info, v)
                                        local arg = info.arg
                                        Skits_Options.db["style_notification_instanceoptions"]["solo"][arg]  = v
                                        Skits:GeneralParameterChanges()
                                    end,
                                    disabled = false,
                                    args = GetNotificationInstanceOptions(),
                                },
                                style_notification_instance_option_small = {
                                    type = "group",
                                    name = "Small",
                                    desc = "2~10 players",
                                    order = 2,
                                    get = function(info) 
                                        return Skits_Options.db["style_notification_instanceoptions"]["small"][info.arg] 
                                    end,
                                    set = function(info, v)
                                        local arg = info.arg
                                        Skits_Options.db["style_notification_instanceoptions"]["small"][arg]  = v
                                        Skits:GeneralParameterChanges()
                                    end,
                                    disabled = false,
                                    args = GetNotificationInstanceOptions(),
                                },      
                                style_notification_instance_option_medium = {
                                    type = "group",
                                    name = "Medium",
                                    desc = "11~20 players",
                                    order = 3,
                                    get = function(info) 
                                        return Skits_Options.db["style_notification_instanceoptions"]["medium"][info.arg] 
                                    end,
                                    set = function(info, v)
                                        local arg = info.arg
                                        Skits_Options.db["style_notification_instanceoptions"]["medium"][arg]  = v
                                        Skits:GeneralParameterChanges()
                                    end,
                                    disabled = false,
                                    args = GetNotificationInstanceOptions(),
                                },    
                                style_notification_instance_option_large = {
                                    type = "group",
                                    name = "Large",
                                    desc = "21~50 players",
                                    order = 4,
                                    get = function(info) 
                                        return Skits_Options.db["style_notification_instanceoptions"]["large"][info.arg] 
                                    end,
                                    set = function(info, v)
                                        local arg = info.arg
                                        Skits_Options.db["style_notification_instanceoptions"]["large"][arg]  = v
                                        Skits:GeneralParameterChanges()
                                    end,
                                    disabled = false,
                                    args = GetNotificationInstanceOptions(),
                                },                                                                                               
                            },
                        },                                                                                                                                                                                                                    
                    },
                },   
                tab_style_departure = {
                    type = "group",
                    name = "Departure",
                    order = 5,
                    get = function(info) return Skits_Options.db[info.arg] end,
                    set = function(info, v)
                        local arg = info.arg
                        Skits_Options.db[arg] = v
                        Skits:GeneralParameterChanges()
                    end,
                    disabled = false,
                    args = {
                        style_departure_strata = {
                            type = "select",
                            name = L["Skits.options.style_any_strata.title"],
                            desc = L["Skits.options.style_any_strata.desc"],
                            values = function()
                                return GetStrataOptions()
                            end,
                            arg = "style_departure_strata",
                            order = 1,
                            width = optionWidth,
                        },   
                        style_departure_click_left = {
                            type = "select",
                            name = L["Skits.options.style_any_click_left.title"],
                            desc = L["Skits.options.style_any_click_left.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_departure_click_left",
                            order = 2,
                            width = optionWidth,
                        },  
                        style_departure_click_right = {
                            type = "select",
                            name = L["Skits.options.style_any_click_right.title"],
                            desc = L["Skits.options.style_any_click_right.desc"],
                            values = function()
                                return GetClickOptions()
                            end,
                            arg = "style_departure_click_right",
                            order = 3,
                            width = optionWidth,
                        },                                               
                        style_departure_speech_font_size = {
                            type = "range",
                            name = L["Skits.options.style_any_speech_font_size.title"],
                            desc = L["Skits.options.style_any_speech_font_size.desc"],
                            min = 4, max = 30, step = 1,
                            arg = "style_departure_speech_font_size",
                            order = 4,
                            width = optionWidth,
                        },
                        style_departure_speech_font_name = {
                            type = "select",
                            name = L["Skits.options.style_any_speech_font_name.title"],
                            desc = L["Skits.options.style_any_speech_font_name.desc"],
                            values = function()
                                return LSM:HashTable("font")
                            end,
                            dialogControl = "LSM30_Font",
                            arg = "style_departure_speech_font_name",
                            order = 5,
                            width = optionWidth,
                        },                         
                        style_departure_model_size = {
                            type = "range",
                            name = L["Skits.options.style_departure_model_size.title"],
                            desc = L["Skits.options.style_departure_model_size.desc"],
                            min = 50, max = 800, step = 50,
                            arg = "style_departure_model_size",
                            order = 6,
                            width = optionWidth,
                        },   
                        style_departure_model_poser = {
                            type = "toggle",
                            name = L["Skits.options.style_departure_model_poser.title"],
                            desc = L["Skits.options.style_departure_model_poser.desc"],
                            arg = "style_departure_model_poser",
                            order = 7,
                            width = optionWidth,
                        },                              
                        style_departure_previous_speaker_lingertime = {
                            type = "range",
                            name = L["Skits.options.style_departure_previous_speaker_lingertime.title"],
                            desc = L["Skits.options.style_departure_previous_speaker_lingertime.desc"],
                            min = 0, max = 60, step = 1,
                            arg = "style_departure_previous_speaker_lingertime",
                            order = 8,
                            width = optionWidth,
                        },                                                                                                                                   
                    },
                },                                      
            },
        },                    
        tab_speech_duration = {
            type = "group",
            name = "Duration",
            order = 5,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,
            disabled = false,
            args = {
                speech_duration_min = {
                    type = "range",
                    name = L["Skits.options.speech_duration_min.title"],
                    desc = L["Skits.options.speech_duration_min.desc"],
                    min = 1, max = 60, step = 1,
                    arg = "speech_duration_min",
                    order = 1,
                    width = optionWidth,
                },      
                speech_duration_max = {
                    type = "range",
                    name = L["Skits.options.speech_duration_max.title"],
                    desc = L["Skits.options.speech_duration_max.desc"],
                    min = 1, max = 60, step = 1,
                    arg = "speech_duration_max",
                    order = 2,
                    width = optionWidth,
                },     
                speech_speed = {
                    type = "range",
                    name = L["Skits.options.speech_speed.title"],
                    desc = L["Skits.options.speech_speed.desc"],
                    min = 5, max = 30, step = 1,
                    arg = "speech_speed",
                    order = 3,
                    width = optionWidth,
                },   
            },
        },                             
    },
}