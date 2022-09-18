
# Spyglass

 
A server-side mod that handles punishing players from a curated reports list on the Northstar Discord server.

Spyglass has been designed to be very customisable, up to a point where it can be made invisible to players on your server, keeping a strictly Vanilla experience if you prefer it, or publicly identify mischievous players that join your server.

The database is regularly updated and shared across servers, meaning the sanctions are as well, provided the servers do not change their individual sanction thresholds.

With Spyglass  and your help, we can make the community scene of Titanfall 2 a safe & wholesome one.

## Infractions

An infraction is a singular report that has been validated by the maintainers, contributors and Northstar community Discord. 

Reports are validated when they meet the following guidelines:

- The report is for an offence that is deemed sanction-able by the community & Spyglass.
- There is sufficient evidence that could not have been fabricated or otherwise taken out of context.
- If cheats are involved, the reported user cannot be a staff member of the server the report was made on.
- There is enough evidence that the reported player was not a Spoofed account (i.e. player impersonating another).

Currently, Spyglass supports the current types of infractions:

- Spoof: this infraction is merely to notify the player they were  spoofed.
- Spamming: Spamming text or voice chat with malicious intent.
- Toxicity: Insults/targeted harassment of one or more players. Generally attempting to ruin the game through harmless communication.
- Discrimination: Harassment based on a player's gender, sexuality, race, religion etc.
- Cheating: Usage of external programs that provide unfair advantage to the player (aimbot, wallhack, speedhack etc.)

This list is not final, and new infraction types can be added if the need arises. 
Using the default settings, a singular `Cheating` infraction will land you an automatic ban, and a singular `Discrimination` infraction will give you a permanent mute.

Infractions are cumulative, and may lead to greater sanctions (multiple spamming offences will eventually lead to a permanent mute).

## Configuration Variables 

Spyglass is only configured through convars, meaning you can add them to your server's configuration files.
You shouldn't in any way, shape or form modify the mod itself if possible, to make it very easy for you to update the player infractions database as often as possible.

```ini
[spyglass_chat_welcome]
Description = "Whether or not to welcome players when they join (tells them the server is running Spyglass for protection)."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_welcome_message]
Description = "The message to display to players when they join."
Type = "String"
DefaultValue = "This server is monitored by Spyglass. Global sanctions are in effect."

[spyglass_sanctions_notifications]
Description = "Whether or not to warn a player through chat when they have been punished for one or more infractions."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_global_sanctions_notifications]
Description = "Whether to notify the entire server of a player's sanctions."
Type = "Boolean"
Requires = "spyglass_sanctions_notifications 1"
DefaultValue = "1 (true)"

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

[spyglass_warn_score_threshold]
Description = "The amount of infraction points a player needs to reach before being automatically muted."
Requires = "spyglass_sanctions_notifications 1"
Type = "Float"
DefaultValue = "0.1"

[spyglass_use_banlist_for_bans]
Description = "Whether or not we should add the player to the banlist.txt if they reach the Ban threshold. If not, they will just be kicked while joining."
Type = "Boolean"
DefaultValue = "0 (false)"

[spyglass_notify_muted_player]
Description = "Whether or not to notify a muted player when their message wasn't sent due to a mute."
Type = "Boolean"
DefaultValue = "1 (true)"
```
