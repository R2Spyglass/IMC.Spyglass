# Spyglass

<a href="https://discord.com/invite/whKMsPN3nu" target="_blank">
  <img src="https://discordapp.com/api/guilds/897214251414994994/widget.png?style=shield" alt="Spyglass Discord Server"/>
</a>

A server-side mod that handles sanctioning players from a curated reports list on the Northstar Discord server.

Spyglass has been designed to be very customisable, up to a point where it can be made invisible to players on your server, keeping a strictly Vanilla experience if you prefer it, or publicly identify mischievous players that join your server.

The database is regularly updated and shared across servers, meaning the sanctions are as well, provided the servers do not change their individual sanction thresholds.

With Spyglass and your help, we can make the community scene of Titanfall 2 a safe & wholesome one.

## Installation

### Easy Mode 

Simply go to our [releases](https://github.com/Erlite/IMC.Spyglass/releases), grab the latest one and extract it in your server's mods folder.
You should delete any previous version you had installed before.

### Experienced Server Owner

The best way to use Spyglass is by cloning this git repository, and pulling it from time to time to keep an up to date database.
The database is read on map change, so that would allow you to keep it in sync.

You may use the `stable` branch if you wish to only get database updates or stable versions.
Do not modify Spyglass in any way, shape or form to keep this working smoothly. All configuration is done with convars.

## Infractions

An infraction is a singular report that has been validated by the maintainers, contributors and Northstar community Discord. 

Reports are validated when they meet the following guidelines:

- The report is for an offence that is deemed sanction-able by the community & Spyglass.
- There is sufficient evidence that could not have been fabricated or otherwise taken out of context.
- If cheats are involved, the reported user cannot be a staff member of the server the report was made on.
- There is enough evidence that the reported player was not a Spoofed account (i.e. player impersonating another).

Currently, Spyglass supports the current types of infractions:

- Spoof: this infraction is merely to notify the player they were  spoofed.
- Spamming: spamming text or voice chat with malicious intent.
- Toxicity: insults/targeted harassment of one or more players. Generally attempting to ruin the game through harmful communication.
- Discrimination: harassment based on a player's gender, sexuality, race, religion etc.
- Cheating: usage of external programs that provide unfair advantage to the player (aimbot, wallhack, speedhack etc.) or detriment to the player experience (making the server or players lag & crash, etc.)

This list is not final, and new infraction types can be added if the need arises. 
Using the default settings, a singular `Cheating` infraction will land you an automatic ban, and a singular `Discrimination` infraction will give you a permanent mute.

Infractions are cumulative, and may lead to greater sanctions (multiple spamming offences will eventually lead to a permanent mute).

## Commands

By default, commands are admin only, and are prefixed by "!".

*Example: !infractions ErliteDev*

```ini
[find]
Example = "!find ErliteDev, !find 1005829030626"
Description = "Attempts to find a user with the given name, or UID. Partial matches work."

[infractions]
Example = "!infractions ErliteDev, !infractions 1005829030626"
Description = "Searches for a player's infractions and displays them in chat."
```

## Configuration Variables 

Spyglass is only configured through convars, meaning you can add them to your server's configuration files.
You shouldn't in any way, shape or form modify the mod itself if possible, to make it very easy for you to update the player infractions database as often as possible.

```ini
[spyglass_admin_uids]
Description = "The UIDs of your server's admins, separated by a comma."
Type = "String"
DefaultValue = ""

[spyglass_admin_immunity]
Description = "Whether or not server admins are immune to Spyglass sanctions."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_maintainers_are_admins]
Description = "Whether or not Spyglass' maintainers have the same rights as admins."
Note = "Rights are only for querying the database and Spyglass immunity, and do not provide admin power. We will only use it for debugging purposes."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_welcome_message_enabled]
Description = "Whether or not to welcome players when they join (tells them the server is running Spyglass for protection)."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_welcome_message]
Description = "The message to display to players when they join."
Type = "String"
DefaultValue = "Spyglass: I am currently monitoring this server, and global sanctions are in effect."

[spyglass_sanction_notification_mode]
Description = "Used to choose who receives a notification when a player with a sanction joins the server."
Values = "0: None, 1: Player Only, 2: Player and Admins, 3: Admins Only, 4: Everyone"
Type = "Integer"
DefaultValue = "4"

[spyglass_spamming_weight]
Description = "The amount of weight a 'Spamming' infraction has on a sanction calculation score."
Type = "Float"
DefaultValue = "0.2"

[spyglass_toxicity_weight]
Description = "The amount of weight a 'Toxicity' infraction has on a sanction calculation score."
Type = "Float"
DefaultValue = "0.3"

[spyglass_discrimination_weight]
Description = "The amount of weight a 'Discrimination' infraction has on a sanction calculation score."
Type = "Float"
DefaultValue = "0.6"

[spyglass_cheating_weight]
Description = "The amount of weight a 'Cheating' infraction has on a sanction calculation score."
Type = "Float"
DefaultValue = "2.0"

[spyglass_ban_score_threshold]
Description = "The amount of infraction points a player needs to reach before being automatically banned."
Type = "Float"
DefaultValue = "2.0"

[spyglass_mute_score_threshold]
Description = "The amount of infraction points a player needs to reach before being automatically muted."
Type = "Float"
DefaultValue = "0.5"

[spyglass_warn_score_threshold]
Description = "The amount of infraction points a player needs to reach before being automatically muted."
Requires = "spyglass_sanctions_notifications 1"
Type = "Float"
DefaultValue = "0.1"

[spyglass_use_banlist_for_bans]
Description = "Whether or not we should add the player to the banlist.txt if they reach the Ban threshold. If not, they will just be kicked while joining."
Type = "Boolean"
DefaultValue = "0 (false)"

[spyglass_mute_sanction_type]
Description = "How to handle a muted player that tries to send a message in chat."
Values = "0: Prevent message from appearing, 1: Prevent and notify player, 2: Only allow the player to see their own message."
Type = "Integer"
DefaultValue = "1"

[spyglass_command_prefix]
Description = "The prefix to use for Spyglass' chat commands."
Type = "String"
DefaultValue = "!"

[spyglass_commands_admin_only]
Description = "Whether or not Spyglass' commands can only be used by admins."
Type = "Boolean"
DefaultValue = "1 (true)"
```
