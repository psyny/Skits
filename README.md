# Skits

Skits: A World of Warcraft Addon for Immersive Conversation

Inspired by the skit-like dialogues of JRPGs, Skits turns in-game chat into an on-screen conversation: the speaker's 3D model, their name and their line of dialogue, one after another. NPC lines work out of the box, and player chat can be turned on for roleplay.

## Features

- **Skit styles:** five ways to show a conversation (see [Skit Styles](#skit-styles)), from full-screen character scenes to small notifications in a corner.
- **Situation-aware:** pick a different style for exploring, combat, solo instances, group instances and immersive mode. Skits switches between them as your situation changes.
- **NPC and player chat:** NPC say, yell, whisper and party lines are shown by default. Player say, yell, whisper, party, raid, instance, channel, guild and officer chat can each be turned on.
- **Quest and gossip dialogue:** quest and gossip text can be logged, or played as a skit with the NPC talking and your character answering. An optional 3D model of the quest giver can be attached to the quest frame.
- **Conversation log:** `/skitslog` opens a storybook-style log of the last 1000 lines, with portraits, zone and date. It can show all your characters or only the current one.
- **Speaker marker:** a marker appears over the speaking unit in the game world.
- **Talking heads:** the standard WoW talking head can be blocked. Skits still reads the model from it, so the speaker gets the right portrait.
- **Profiles:** all options are stored in AceDB profiles, so different characters can use different setups.
- **Localization:** English and Brazilian Portuguese.

## Supported Clients

| TOC file | Client |
|---|---|
| `Skits.toc` | Retail (Interface 120000 / 120001) |
| `Skits_Camelot.toc` | WoW Forever (Interface 16000 / 16001) |

## Recommendations

Install the **Creature Display DB** addon. Skits works without it, but then it can only find models for NPCs you have seen around you (nameplates, target, mouseover, boss frames, talking heads). With it, Skits can look up models for NPCs you have never seen, and it picks the right model for the zone you are in (for example, Thrall in Shadowlands versus Thrall in Orgrimmar).

## Commands

| Command | Description |
|---|---|
| `/skitslog` | Open the conversation log. |
| `/skitsimmersive` | Toggle immersive mode (uses the Immersion skit style). |
| `/skitstoggle` | Turn skits on or off for this session. |
| `/skitslayout` | Reset the skit style layouts. |

Options: **Options → AddOns → Skits**.

### Debug Commands

| Command | Description |
|---|---|
| `/skitsdebug` | Toggle debug output. |
| `/skitsnpcdata <name>` | Print the model ids Skits knows for an NPC name, and where they came from. |
| `/skitstargetdata` | Same as above, for your current target. |
| `/skitsmapchain` | Print the current map chain (map → parent maps) and the keys used to store NPC model ids. |
| `/skitslocaldbstats` | Print how many entries the local NPC model database has. |
| `/skitsclearlocaldb` | Erase the local NPC model database. Skits will have to learn models again from what you see. Only use it if you know you need to. |

## Skit Styles

| Style | Description |
|---|---|
| **Departure** | Two speakers face each other from the left and right sides of the screen, each with a large posing model and a text box. Default for exploring. |
| **Tales** | Large posing character with the speech below. Previous speakers linger in the background. Can always be full screen. Default for immersive mode. |
| **Warcraft** | A stack of talking-head-like speech boxes with a small portrait. |
| **Notification** | Small portrait and text in a corner of the screen. Layout can be set per instance size (solo, small, medium, large). Default for combat. |
| **Hidden** | Shows nothing. Lines are still logged. |

### Which style is shown

Each situation has its own style setting. Skits checks them in this order and uses the first one that is not set to **Undefined**:

1. Immersive mode (`/skitsimmersive`)
2. Solo instance
3. Group instance
4. Combat
5. Exploring (always used if nothing above applies)

Solo and group instance are **Undefined** by default, so instances use the combat or exploring style.

### Mouse clicks

Each style has its own left and right click action on the text area:

- **Show Next Speech**: skip to the next queued line (default left click).
- **Switch to Combat Style Skit**: switch to the combat style for 30 seconds.
- **Close Skit** / **Hide Skit**
- **Block Clicks** / **Pass Click to UI Below**

## Options

All options are in **Options → AddOns → Skits**, and each one has a tooltip in game.

- **General:** enable Skits, block talking heads, and when to switch between the combat and exploring styles (easy in, easy out, combat over delay, and switching out of the exploring style while moving).
- **Quests:** how quest and gossip text is handled (Ignore, Log Only or Show as Skit), and the quest model frame (size, position, animation, poser, background and border).
- **Events:** which NPC and player chat types become skits.
- **Style:**
  - *General:* the style for each situation, and the speaker marker size.
  - *Per style:* frame strata, click actions, font and font size, plus that style's own settings (model size, poser, linger time, portrait, number of speeches on screen, position, frame background and border).
  - *Notification:* settings per instance size. A size can inherit the settings of the size below it.
- **Duration:** minimum and maximum time a line stays on screen, and how much the length of the text adds to it.
- **Profiles:** standard AceDB profile management.

## Limitations

### NPC Portraits

WoW chat events only give the speaker's name, not their model, so Skits has to work out which model to show. It learns models from NPCs around you and from Creature Display DB, and stores them per zone so the same name can have different models in different places. It can still show no model, or the wrong one, mostly for NPCs that have many appearances.

### Player Portraits

Live skits can show the real model of a player who is near you. Skits can't store player appearances, so the conversation log and players who are not nearby show an approximation based on race and body type.

## Known Issues

- The limitations listed above.
- Some NPCs show a different model in some areas. These have to be fixed one by one; reports with the NPC name and zone help.

## Development Notes

| File | Purpose |
|---|---|
| `Skits.lua` | Addon setup, event handling, chat → skit flow, conversation log storage, speaker colors. |
| `Skits_Options.lua` | Option defaults and the AceConfig options table. |
| `Skits_ID_Store.lua` | NPC/player model id storage and lookup (session cache, local DB, Creature Display DB). |
| `Skits_MapChain.lua` | uiMapID chains and the storage keys used by the ID store. |
| `Skits_QuestFrame.lua` | Quest and gossip dialogue, quest model frame. |
| `Skits_SpeakQueue.lua` | Queue of lines and pauses for quest dialogue. |
| `Skits_UI.lua`, `Skits_UI_Utils.lua` | Shared display code: model loading, speaker marker, faded frames. |
| `Skits_Log_UI.lua` | Conversation log window. |
| `Skits_Style.lua` | Picks and switches the active style based on the situation. |
| `Skits_Style_*.lua` | One file per skit style. |
| `Locales/` | Translations. |

## Roadmap

No fixed roadmap, but I keep improving the addon and adding new skit styles when I find the time. If you want to help develop it, let me know.
