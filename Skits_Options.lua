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
		enabled                                 = true,
        block_talking_head                      = true,
        speech_position_bottom_distance         = 200,
        speech_screen_max                       = 4,        
        speech_screen_combat_max                = 2,        
        speech_screen_group_instance_max        = 0,
        speech_screen_solo_instance_max         = 2,
        speech_duration_min                     = 5,        
		speech_duration_max                     = 30,
        speech_speed                            = 15,
        speaker_name_enabled                    = true,          
        speech_font_size                        = 12,
        speech_font_name                        = "Friz Quadrata TT", 
        speech_frame_size                       = 350,  
        speaker_marker_size                     = 25,     
        speaker_face_enabled                    = true,
        speaker_face_size                       = 100,  
        
       -- NPC Events
       event_msg_monster_yell                 = true,
       event_msg_monster_whisper              = true,
       event_msg_monster_say                  = true,
       event_msg_monster_party                = true,

       -- Player Events
       event_msg_say                          = false,
       event_msg_yell                         = false,
       event_msg_whisper                      = false,
       event_msg_party                        = false,
       event_msg_party_leader                 = false,
       event_msg_raid                         = false,
       event_msg_raid_leader                  = false,
       event_msg_instance_chat                = false,
       event_msg_instance_chat_leader         = false,
       event_msg_channel                      = false,
       event_msg_guild                        = false,
       event_msg_officer                      = false,
	},
}

---------------------------------------------------------
-- Our options table
local L = LibStub("AceLocale-3.0"):GetLocale("Skits", false)
local LSM = LibStub("LibSharedMedia-3.0")
local optionWidth = 2.0

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
            args = {
                enabled = {
                    type = "toggle",
                    name = L["Skits.options.enabled.title"],
                    desc = L["Skits.options.enabled.desc"],
                    order = 1,
                    width = optionWidth,
                    get = function(info) return Skits_Options.db.enabled end,
                    set = function(info, v)
                        Skits_Options.db.enabled = v
                    end,
                    disabled = false,
                },
                block_talking_head = {
                    type = "toggle",
                    name = L["Skits.options.block_talking_head.title"],
                    desc = L["Skits.options.block_talking_head.desc"],
                    order = 2,
                    width = optionWidth,
                    get = function(info) return Skits_Options.db.block_talking_head end,
                    set = function(info, v)
                        Skits_Options.db.block_talking_head = v
                    end,
                    disabled = false,
                },                
            },
        },
        tab_speech_events = {
            type = "group",
            name = "Events",
            order = 2,
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
                    order = 5,
                    width = optionWidth,
                },
                event_msg_yell = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_yell.title"],
                    desc = L["Skits.options.event_msg_yell.desc"],
                    arg = "event_msg_yell",
                    order = 6,
                    width = optionWidth,
                },
                event_msg_whisper = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_whisper.title"],
                    desc = L["Skits.options.event_msg_whisper.desc"],
                    arg = "event_msg_whisper",
                    order = 7,
                    width = optionWidth,
                },
                event_msg_party = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_party.title"],
                    desc = L["Skits.options.event_msg_party.desc"],
                    arg = "event_msg_party",
                    order = 8,
                    width = optionWidth,
                },
                event_msg_party_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_party_leader.title"],
                    desc = L["Skits.options.event_msg_party_leader.desc"],
                    arg = "event_msg_party_leader",
                    order = 9,
                    width = optionWidth,
                },
                event_msg_raid = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_raid.title"],
                    desc = L["Skits.options.event_msg_raid.desc"],
                    arg = "event_msg_raid",
                    order = 10,
                    width = optionWidth,
                },
                event_msg_raid_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_raid_leader.title"],
                    desc = L["Skits.options.event_msg_raid_leader.desc"],
                    arg = "event_msg_raid_leader",
                    order = 11,
                    width = optionWidth,
                },
                event_msg_instance_chat = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_instance_chat.title"],
                    desc = L["Skits.options.event_msg_instance_chat.desc"],
                    arg = "event_msg_instance_chat",
                    order = 12,
                    width = optionWidth,
                },
                event_msg_instance_chat_leader = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_instance_chat_leader.title"],
                    desc = L["Skits.options.event_msg_instance_chat_leader.desc"],
                    arg = "event_msg_instance_chat_leader",
                    order = 13,
                    width = optionWidth,
                },
                event_msg_channel = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_channel.title"],
                    desc = L["Skits.options.event_msg_channel.desc"],
                    arg = "event_msg_channel",
                    order = 14,
                    width = optionWidth,
                },
                event_msg_guild = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_guild.title"],
                    desc = L["Skits.options.event_msg_guild.desc"],
                    arg = "event_msg_guild",
                    order = 15,
                    width = optionWidth,
                },
                event_msg_officer = {
                    type = "toggle",
                    name = L["Skits.options.event_msg_officer.title"],
                    desc = L["Skits.options.event_msg_officer.desc"],
                    arg = "event_msg_officer",
                    order = 16,
                    width = optionWidth,
                },
            }
        },          
        tab_speech_quantity = {
            type = "group",
            name = "Quantity",
            order = 3,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,
            disabled = false,
            args = {
                speech_screen_max = {
                    type = "range",
                    name = L["Skits.options.speech_screen_max.title"],
                    desc = L["Skits.options.speech_screen_max.desc"],
                    min = 0, max = 8, step = 1,
                    arg = "speech_screen_max",
                    order = 1,
                    width = optionWidth,
                },
                speech_screen_combat_max = {
                    type = "range",
                    name = L["Skits.options.speech_screen_combat_max.title"],
                    desc = L["Skits.options.speech_screen_combat_max.desc"],
                    min = 0, max = 8, step = 1,
                    arg = "speech_screen_combat_max",
                    order = 2,
                    width = optionWidth,
                },
                speech_screen_group_instance_max = {
                    type = "range",
                    name = L["Skits.options.speech_screen_group_instance_max.title"],
                    desc = L["Skits.options.speech_screen_group_instance_max.desc"],
                    min = 0, max = 8, step = 1,
                    arg = "speech_screen_group_instance_max",
                    order = 3,
                    width = optionWidth,
                },
                speech_screen_solo_instance_max = {
                    type = "range",
                    name = L["Skits.options.speech_screen_solo_instance_max.title"],
                    desc = L["Skits.options.speech_screen_solo_instance_max.desc"],
                    min = 0, max = 8, step = 1,
                    arg = "speech_screen_solo_instance_max",
                    order = 4,
                    width = optionWidth,
                },    
            },
        },    
        tab_speech_duration = {
            type = "group",
            name = "Duration",
            order = 4,
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
        tab_speech_text = {
            type = "group",
            name = "Text",
            order = 5,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,
            disabled = false,
            args = {          
                speaker_name_enabled = {
                    type = "toggle",
                    name = L["Skits.options.speaker_name_enabled.title"],
                    desc = L["Skits.options.speaker_name_enabled.desc"],
                    arg = "speaker_name_enabled",
                    order = 2,
                    width = optionWidth,
                },    
                speech_font_size = {
                    type = "range",
                    name = L["Skits.options.speech_font_size.title"],
                    desc = L["Skits.options.speech_font_size.desc"],
                    min = 4, max = 30, step = 1,
                    arg = "speech_font_size",
                    order = 3,
                    width = optionWidth,
                },
                speech_font_name = {
                    type = "select",
                    name = L["Skits.options.speech_font_name.title"],
                    desc = L["Skits.options.speech_font_name.desc"],
                    values = function()
                        return LSM:HashTable("font")
                    end,
                    dialogControl = "LSM30_Font",
                    arg = "speech_font_name",
                    order = 4,
                    width = optionWidth,
                },
                speech_frame_size = {
                    type = "range",
                    name = L["Skits.options.speech_frame_size.title"],
                    desc = L["Skits.options.speech_frame_size.desc"],
                    min = 150, max = 1000, step = 50,
                    arg = "speech_frame_size",
                    order = 5,
                    width = optionWidth,
                },  
                speech_position_bottom_distance = {
                    type = "range",
                    name = L["Skits.options.speech_position_bottom_distance.title"],
                    desc = L["Skits.options.speech_position_bottom_distance.desc"],
                    min = 0, max = 1000, step = 50,
                    arg = "speech_position_bottom_distance",
                    order = 6,
                    width = optionWidth,
                }, 
                speaker_marker_size = {
                    type = "range",
                    name = L["Skits.options.speaker_marker_size.title"],
                    desc = L["Skits.options.speaker_marker_size.desc"],
                    min = 0, max = 50, step = 5,
                    arg = "speaker_marker_size",
                    order = 7,
                    width = optionWidth,
                },                                        
            },
        },   
        tab_speech_portrait = {
            type = "group",
            name = "Portrait",
            order = 6,
            get = function(info) return Skits_Options.db[info.arg] end,
            set = function(info, v)
                local arg = info.arg
                Skits_Options.db[arg] = v
                Skits:GeneralParameterChanges()
            end,
            disabled = false,
            args = {
                speaker_face_enabled = {
                    type = "toggle",
                    name = L["Skits.options.speaker_face_enabled.title"],
                    desc = L["Skits.options.speaker_face_enabled.desc"],
                    arg = "speaker_face_enabled",
                    order = 1,
                    width = optionWidth,
                },
                speaker_face_size = {
                    type = "range",
                    name = L["Skits.options.speaker_face_size.title"],
                    desc = L["Skits.options.speaker_face_size.desc"],
                    min = 20, max = 200, step = 10,
                    arg = "speaker_face_size",
                    order = 2,
                    width = optionWidth,
                },   
            },
        },                         
    },
}