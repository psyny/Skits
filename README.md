# Skits
Skits: A World of Warcraft Addon for Immersive Conversation

Step into a more immersive World of Warcraft experience with Skits, an addon designed to bring a fresh, cinematic flair to in-game conversations. Inspired by skit-like dialogues in JRPGs, this addon transforms chat messages into an engaging sequence, adding depth and storytelling to every interaction.

**Key Features:**

- **Immersive Skit Format:** Chat messages are displayed as dynamic, skit-style dialogues, complete with character portraits and a smooth sequence of talking heads.
- **Storybook Log:** Revisit past conversations with a storybook-like interface. Use /skitslog to relive your favorite skits anytime!
- **Roleplayer-Friendly:** Works with player messages, making it perfect for roleplaying scenarios. Add an extra layer of immersion to your stories and interactions.
- **Customizable:** Tailor the experience to your liking. Decide which chat messages become skits, toggle talking heads or speaker portraits, and configure when skits appear—whether during combat, in dungeons, or other specific situations.

## Recommendations

Have the "Creature Display DB" addon installed. This will vastly improve the experience with this addon by increase the variety of unit models displayed.

## Important Commands

- **/SkitsLog:** Shows the conversation log.
- **/SkitsImmersive:** Toggles immersive mode on and off.
- **/SkitsToggle:** Toggle skits on and off.

## Debug Commands

- **/SkitsLocalDBStats:** shows the stats of the local database for NPC/Display ids.
- **/SkitsNPCData "npcname":** shows the current data for the given NPC name.
- **/SkitsTargetData:** show the current data for the current target.
- **/SkitsClearLocalDB:** erases the local database for NPC/Display ids. Not recommended to use without understands what this means.

## Limitations

### NPC Portraits

Getting the potratis for the speakers is no easy task and most of the time guess work.
Sometimes the addon will not be able to find the portrait or find the wrong one (mainly for NPCs with many different appearances).
This is something I will always be improving over time.

Having the "Creature Display DB" addon installed vastly improves the user experience, as the portrait can be retrieve from a database and not only from the player surrondings.

### Player Portraits

Same limitations as NPC Portraits, plus we can't have a database for player portraits.
So on Skits the player portrait can be shown as the current player model. But on the skits log (`/skitslog`) it will be an aproximation of that player (race/bodytype).

## Known Issues

- Limitations listed above.
- Portraits of NPCs in some areas sometimes displays a different model. This needs to be solved in a case by case basis.
- In rare ocasions, this addon causes a stuttering. It manifestas as a 1 to 3 seconds freeze when an NPC talks. As far as I know, this happens when having multipe skit styles selected to different situations in options. If this is happening to you, please report the skit styles you are using. The workaround is having only one skit style in use, it can be defined for different situations, but should be only one.

## Roadmap

No fixed roadmap yet, but I plan to keep improving this addon as much as I can.
If you wanna help me develop this addon let me know.
I will always be adding new Skit Styles as I find the time to do it.

## Options

Can be changed in the WoW options menu: Options -> Addons -> Skits

# Skits Addon Options Documentation

## Overview
This documentation lists all available configuration options for the Skits addon. Each option is categorized and described for clarity. 

---

## General Settings
- **Enable Skits**: Enable or disable Skits.
- **Block Talking Heads**: Block standard WoW talking heads from appearing.

---

## Combat Behavior
- **Combat Mode Easy In**: If enabled, will not instantly change Skits style to combat style when entering combat mode. Instead, the addon will wait for the next chat message to change Skits style.
- **Combat Mode Easy Out**: If enabled, will not instantly change Skits style to exploring style when exiting combat mode. Instead, the addon will wait for the next chat message to change Skits style.
- **Combat Over Delay**: How many seconds to wait before considering that combat is over to change Skits styles.

---

## Duration and Speed
- **Speech Duration: Minimum [sec]**: Adjust the minimum duration of a speech on screen before fading.
- **Speech Duration: Maximum [sec]**: Adjust the maximum duration of a speech on screen before fading.
- **Speech Duration: Fade Speed**: Adjust the speed at which speech text fades from the screen. Based on this factor and the number of letters in the speech.

---

## NPC Events
- **NPC Yell**: Toggle to display NPC yells on screen.
- **NPC Whisper**: Toggle to display NPC whispers on screen.
- **NPC Say**: Toggle to display NPC say messages on screen.
- **NPC Party**: Toggle to display NPC party messages on screen.

---

## Player Events
- **Player Say**: Toggle to display player say messages on screen.
- **Player Yell**: Toggle to display player yells on screen.
- **Player Whisper**: Toggle to display player whispers on screen.
- **Party Chat**: Toggle to display party chat messages on screen.
- **Party Leader Chat**: Toggle to display messages from the party leader on screen.
- **Raid Chat**: Toggle to display raid chat messages on screen.
- **Raid Leader Chat**: Toggle to display messages from the raid leader on screen.
- **Instance Chat**: Toggle to display instance chat messages on screen.
- **Instance Leader Chat**: Toggle to display messages from the instance leader on screen.
- **Channel Chat**: Toggle to display general channel messages on screen.
- **Guild Chat**: Toggle to display guild chat messages on screen.
- **Officer Chat**: Toggle to display officer chat messages on screen.

---

## Style Settings

### General Style Settings
- **Speaker Marker Size**: Size of the marker that appears over the speaker's unit in the game world.
- **Immersion Skit Style**: Skit style to display when in immersion mode.
- **Exploring Skit Style**: Skit style to display when exploring.
- **Combat Skit Style**: Skit style to display when in combat.
- **Solo Instance Skit Style**: Skit style to display when in a solo instance.
- **Group Instance Skit Style**: Skit style to display when in a group instance.

### Warcraft Style
- **Max Number of Speeches**: Max number of speeches on screen.
- **Max Number of Speeches: Combat**: Max number of speeches on screen while in combat. Limited by the general max number of speeches value.
- **Max Number of Speeches: Group Instances**: Max number of speeches on screen while in a group instance. Limited by the general max number of speeches value.
- **Max Number of Speeches: Solo Instances**: Max number of speeches on screen while in a solo instance. Limited by the general max number of speeches value.
- **Enable Speaker Portrait**: Toggle to display the speaker's portrait during conversations.
- **Speaker Portrait Size**: Set the size of the speaker's portrait during conversations.
- **Enable Speaker Name**: Toggle to display the speaker's name during conversations.
- **Bottom Distance**: Distance to the bottom of the screen.
- **Speech Frame Width**: Set the width of the text area for speech display.

### Tales Style
- **Character Size**: On-screen size of the speaking character.
- **Character Poser**: Show the speaking character posing during a skit.
- **Speaker Name Enabled**: Show speaker name on screen.
- **Previous Speaker Linger Time**: How long a previous speaker stays lingering in the background (in seconds).
- **Always Fullscreen**: Always show the skit fullscreen, ignoring the side of the speaking character on the screen.

### Notification Style
- **Portrait Size**: Set the size of the portrait displayed in notifications.
- **Message on Right**: Toggle to display notifications on the right side of the screen.
- **Max Messages**: Set the maximum number of notification messages displayed on screen.
- **Text Area Size**: Set the width of the text area for notification speech display.
- **Side Distance**: Set the distance from the side of the screen for notifications.
- **Top Distance**: Set the distance from the top of the screen for notifications.
