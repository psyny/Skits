# Skits
World of Warcraft Addon for conversation Skits

An immersion addon for people that like Skits like conversations.

Chat messages will be displayed in a skit like format. Like a sequence of talking heads.

The addon as an option to see the past skits in a sstorybook like format (`/skitslog`).

It even works for player messages, adding value to roleplaying scenarios.

I made this addon as customizable as I can. The user can choose which type of chat messages to turn into skits, to disable talking heads, to show the speaker portraits, and the situations that the skits can happen (combat, dungeons, etc).

## Recomendations

Have the CreatureDisplayDB addon installed. This will vastly improve the experience with this addon.

## Limitations

### NPC Portraits

Getting the potratis for the speakers is no easy task and most of the time guess work.
Sometimes the addon will not be able to find the portrait or find the wrong one (mainly for NPCs with many different appearances).
This is something I will always be improving over time.

Having the CreatureDisplayDB addon installed vastly improves the user experience, as the portrait can be retrieve from a database and not only from the player surrondings.

### Player Portraits

Same limitations as NPC Portraits, plus we can't have a database for player portraits.
So on Skits the player portrait can be shown as the current player model. But on the skits log (`/skitslog`) it will be an aproximation of that player (race/bodytype).

## Known Issues

- Limitations listed above.
- Portraits of NPCs in some areas sometimes displays a different model. This needs to be solved in a case by case basis.

## Roadmap

No fixed roadmap yet, but I plan to keep improving this addon as much as I can.
I have plans to improve the skits art, adding more style options.
If you wanna help me develop this addon let me know.

## Options

Can be changed in the WoW options menu: Options -> Addons -> Skits

### Enable Skits
Enable or disable Skits.

### Block Talking Heads
Block standard WoW talking heads from appearing.

### Events

#### NPC Yell
Toggle to display NPC yells on screen.

#### NPC Whisper
Toggle to display NPC whispers on screen.

#### NPC Say
Toggle to display NPC say messages on screen.

#### NPC Party
Toggle to display NPC party messages on screen.

### Player Events

#### Player Say
Toggle to display player say messages on screen.

#### Player Yell
Toggle to display player yells on screen.

#### Player Whisper
Toggle to display player whispers on screen.

#### Party Chat
Toggle to display party chat messages on screen.

#### Party Leader Chat
Toggle to display messages from the party leader on screen.

#### Raid Chat
Toggle to display raid chat messages on screen.

#### Raid Leader Chat
Toggle to display messages from the raid leader on screen.

#### Instance Chat
Toggle to display instance chat messages on screen.

#### Instance Leader Chat
Toggle to display messages from the instance leader on screen.

#### Channel Chat
Toggle to display general channel messages on screen.

#### Guild Chat
Toggle to display guild chat messages on screen.

#### Officer Chat
Toggle to display officer chat messages on screen.

### Quantity Settings

#### Max Number of Speeches
Max number of speeches on screen.

#### Max Number of Speeches: Combat
Max number of speeches on screen while in combat. Limited by the general Max number of Speeches value.

#### Max Number of Speeches: Group Instances
Max number of speeches on screen while in an instance with other players. Limited by the general Max number of Speeches value.

#### Max Number of Speeches: Solo Instances
Max number of speeches on screen while in an instance without other players. Limited by the general Max number of Speeches value.

### Duration Settings

#### Speech Duration: Minimum [sec]
Adjust the minimum duration of a speech on screen before fading.

#### Speech Duration: Maximum [sec]
Adjust the maximum duration of a speech on screen before fading.

#### Speech Duration: Fade Speed
Adjust the speed at which speech text fades from the screen. Based on this factor and the number of letters in the speech.

### Text Settings

#### Enable Speaker Name
Toggle to display the speaker's name during conversations.

#### Speech Font Size
Set the font size for speech text.

#### Speech Font
Select the font used for speech text.

#### Speech Frame Width
Set the width of the text area for speech display.

#### Bottom Distance
Distance to the bottom of the screen.

#### Speaker Marker Size
Size of the marker that appears over the speaker's unit in the game world.

### Portrait Settings

#### Enable Speaker Portrait
Toggle to display the speaker's portrait during conversations.

#### Speaker Portrait Size
Set the size of the speaker's portrait during conversations.




