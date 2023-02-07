# Spyglass

<a href="https://spyglass.tf" target="_blank">
  <img src="https://discordapp.com/api/guilds/897214251414994994/widget.png?style=shield" alt="Spyglass Discord Server"/>
</a>

A server-side mod that handles sanctioning players from a curated reports list on the Northstar Discord server.

Spyglass has been designed to be very customisable, up to a point where it can be made invisible to players on your server, keeping a strictly Vanilla experience if you prefer it, or publicly identify mischievous players that join your server.

The database is regularly updated and shared across servers, meaning the sanctions are as well, provided the servers do not change their individual sanction thresholds.

With Spyglass and your help, we can make the community scene of Titanfall 2 a safe & wholesome one.

## Installation

### Easy Mode 

Simply go to our [releases](https://github.com/Erlite/IMC.Spyglass/releases), grab the latest one and extract it in your server's mods folder.

You may also get the mod on [Thunderstore](https://northstar.thunderstore.io/package/IMC/Spyglass/).

You should delete any previous version you had installed before.

## Infractions

An infraction is a singular report that has been validated by the maintainers, contributors and Northstar community Discord. 

Reports are validated when they meet the following guidelines:

- The report is for an offence that is deemed sanction-able by the community & Spyglass.
- There is sufficient evidence that could not have been fabricated or otherwise taken out of context.
- If cheats are involved, the reported user cannot be a staff member of the server the report was made on.
- There is enough evidence that the reported player was not a Spoofed account (i.e. player impersonating another).

Currently, Spyglass supports the current types of infractions:

- Spamming: spamming text or voice chat with malicious intent.
- Harassment: harassing a player through text and/or voice chat.
- Hate Speech: Any discriminatory, threatening, abusive, hateful or otherwise offensive language.
- Griefing: Attempts to disrupt the game experience of one or more players outside of the accepted gameplay parameters.
  - A good example would be purposefully causing damage to a teammate, either directly or indirectly.
- Exploiting: Use or attempted use of exploits that may deteriorate the performance of game clients and/or the server.
- Cheating: The use of third-party hacking or cheating clients (aimbot, wallhack etc.) or any tool that provides an advantage, like macros.

This list is not final, and new infraction types can be added if the need arises. 

## Configuration Variables 

Spyglass is only configured through convars, meaning you can add them to your server's configuration files.
You shouldn't in any way, shape or form modify the mod itself if possible, to make it very easy for you to update the player infractions database as often as possible.

```ini
[spyglass_api_hostname]
Description = "The Spyglass API server to use. You shouldn't change this."
Type = "String"
DefaultValue = "https://spyglass.tf/"

[spyglass_api_token]
Description = "If set, the API token to use for trusted servers. Only given by Spyglass maintainers, leave this empty otherwise."
Type = "String"
DefaultValue = ""

[spyglass_appeal_link]
Description = "The link to a place where people can appeal Spyglass sanctions. You shouldn't change this."
Type = "String"
DefaultValue = "https://spyglass.tf"

[spyglass_admin_uids]
Description = "Comma separated list of UIDs belonging to server admins. Add your admin's UIDs here."
Type = "String"
DefaultValue = ""
Example = "5189484894874,4864848948949"

[spyglass_admin_immunity]
Description = "Whether or not server admins are immune to Spyglass sanctions."
Type = "Boolean"
DefaultValue = "1 (true)"

[spyglass_admin_auth_password]
Description = "The password used to allow admins to authenticate in order to avoid spoofed accounts."
Note = "You must set it to a non-empty or whitespace value, else authentication will be disabled and no commands will work."
Type = "String"
DefaultValue = ""

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
DefaultValue = "This server is monitored by Spyglass. Global sanctions are in effect."

[spyglass_message_mode]
Description = "Used to choose who receives normal Spyglass messages."
Values = "0: Everyone, 1: Admins Only"
Type = "Integer"
DefaultValue = "0"

[spyglass_sanction_message_mode]
Description = "Used to choose who receives a notification when a player with a sanction joins the server."
Values = "0: Everyone, 1: Player and Admins"
Type = "Integer"
DefaultValue = "0"

[spyglass_use_banlist_for_bans]
Description = "Whether or not we should add the player to the banlist.txt if they have a Ban sanction. If not, they will just be kicked while joining."
Type = "Boolean"
DefaultValue = "0 (false)"
```
