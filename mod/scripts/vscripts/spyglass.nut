global function Spyglass_Init
global array<string> Spyglass_MutedPlayers
global array<string> Spyglass_BannedPlayers
global function Spyglass_GetInfractionAsString

// TODO: Custom callback for punishment

void function Spyglass_Init()
{
    printt("[Spyglass] Spyglass_Init() called.");
    AddCallback_OnClientConnecting(OnClientConnecting);
    AddCallback_OnClientConnected(OnClientConnected);
    AddCallback_OnClientDisconnected(OnClientDisconnected);
    AddCallback_OnReceivedSayTextMessage(OnClientMessage);
}

void function OnClientConnecting(entity player)
{
    if (!IsValid(player) || !(player.GetUID() in Spyglass_Infractions))
    {
        return;
    }

    // TODO: Remove me temp
    if (player.GetPlayerName() == "ErliteDev")
    {
        return;
    }

    array<PlayerInfraction> foundInfractions = Spyglass_Infractions[player.GetUID()];
    float totalWeight = 0.0;

    PlayerInfraction lastInfraction;
    int validInfractions = 0;

    bool shouldNotifyPlayer = GetConVarBool("spyglass_punishment_notifications");
    bool shouldNotifyGlobal = GetConVarBool("spyglass_global_punishment_notifications");
    bool bannedAlready = Spyglass_BannedPlayers.find(player.GetUID()) != -1;

    // Calculate the weight of all the player's infractions.
    // We're mostly going to see if they need to be banned while they're connecting.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        totalWeight += GetInfractionWeight(infraction);

        if (infraction.Type != InfractionType.Spoof)
        {
            validInfractions += 1;
            lastInfraction = infraction;
        }
    }

    if(totalWeight >= GetConVarFloat("spyglass_ban_score_threshold"))
    {
        string reason = format("[Spyglass] You have been banned due to %i infraction(s). Latest infraction: %s", validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
        printt(format("[Spyglass] Player '%s' [%s] was banned due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer && shouldNotifyGlobal && !bannedAlready)
        {
            Spyglass_BannedPlayers.append(player.GetUID());
            string message = format("\x1b[38;5;208mSpyglass\x1b[0m: Player \x1b[111m%s\x1b[0m has been banned due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
            Chat_ServerBroadcast(message);
        }

        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand("ban " + player.GetPlayerName());
        }
        else
        {
            ServerCommand(format("kick %s", player.GetPlayerName()));
        }
    }
}

void function OnClientConnected(entity player)
{
    if (!IsValid(player))
    {
        return;
    }

    if (GetConVarBool("spyglass_chat_welcome"))
    {
        Chat_ServerPrivateMessage(player, GetColoredConVarString("spyglass_welcome_message"), false)
    }

    if (!(player.GetUID() in Spyglass_Infractions))
    {
        return;
    }

    array<PlayerInfraction> foundInfractions = Spyglass_Infractions[player.GetUID()];
    PlayerInfraction lastInfraction;
    int validInfractions = 0;
    float totalWeight = 0.0;

    bool shouldNotifyPlayer = GetConVarBool("spyglass_punishment_notifications");
    bool shouldNotifyGlobal = GetConVarBool("spyglass_global_punishment_notifications");

    // Calculate the weight of all the player's infractions.
    // Bans are already handled in OnClientConnecting so we don't need to check again.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        totalWeight += GetInfractionWeight(infraction);
        if (infraction.Type != InfractionType.Spoof)
        {
            validInfractions += 1;
            lastInfraction = infraction;
        }
    }

    if(totalWeight >= GetConVarFloat("spyglass_ban_score_threshold"))
    {
        string reason = format("[Spyglass] You have been banned due to %i infraction(s). Latest infraction: %s", validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
        printt(format("[Spyglass] Player '%s' [%s] was banned due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer && shouldNotifyGlobal && Spyglass_BannedPlayers.find(player.GetUID()) == -1)
        {
            Spyglass_BannedPlayers.append(player.GetUID());
            string message = format("\x1b[38;5;208mSpyglass\x1b[0m: Player \x1b[111m%s\x1b[0m has been banned due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
            Chat_ServerBroadcast(message);
        }

        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand("ban " + player.GetPlayerName());
        }
        else
        {
            ServerCommand(format("kick %s", player.GetPlayerName()));
        }
    }
    else if (totalWeight >= GetConVarFloat("spyglass_mute_score_threshold"))
    {
        Spyglass_MutedPlayers.append(player.GetUID())
        printt(format("[Spyglass] Player '%s' [%s] was muted due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))
        if (shouldNotifyPlayer)
        {
            if (shouldNotifyGlobal)
            {
                string message = format("\x1b[38;5;208mSpyglass\x1b[0m: Player \x1b[111m%s\x1b[0m has been muted due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
                Chat_ServerBroadcast(message);
            }
            else
            {
                string reason = format("\x1b[38;5;208mSpyglass\x1b[0m: You have been muted due to %i infraction(s).\nLatest infraction: %s", validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
                Chat_ServerPrivateMessage(player, reason, true);
            }
        }
    }
    else if (totalWeight >= GetConVarFloat("spyglass_warn_score_threshold"))
    {
        printt(format("[Spyglass] Player '%s' [%s] was warned due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer)
        {
            if (shouldNotifyGlobal)
            {
                string message = format("\x1b[38;5;208mSpyglass\x1b[0m: Player \x1b[111m%s\x1b[0m has been warned due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
                Chat_ServerBroadcast(message);
            }
            else
            {
                string reason = format("\x1b[38;5;208mSpyglass\x1b[0m: You have been warned due to %i infraction(s).\nLatest infraction: %s", validInfractions, Spyglass_GetInfractionAsString(lastInfraction));
                Chat_ServerPrivateMessage(player, reason, true);
            }
        }
    }
}

void function OnClientDisconnected(entity player)
{
    if (IsValid(player))
    {
        int foundIndex = Spyglass_MutedPlayers.find(player.GetUID())
        if (foundIndex != -1)
        {
            Spyglass_MutedPlayers.remove(foundIndex)
        }
    }
}

ClServer_MessageStruct function OnClientMessage(ClServer_MessageStruct message)
{
    if (IsValid(message.player) && Spyglass_MutedPlayers.find(message.player.GetUID()) != -1)
    {
        message.shouldBlock = true;

        if (GetConVarBool("spyglass_notify_muted_player"))
        {
            Chat_ServerPrivateMessage(message.player, "\x1b[38;5;208mSpyglass\x1b[0m: your message was blocked as you are permanently muted.", true);
        }
    }

    return message;
}

float function GetInfractionWeight(PlayerInfraction infraction)
{
    switch (infraction.Type)
    {
        case InfractionType.Spamming:
            return GetConVarFloat("spyglass_spamming_weight");
        case InfractionType.Toxicity:
            return GetConVarFloat("spyglass_toxicity_weight");
        case InfractionType.Discrimination:
            return GetConVarFloat("spyglass_discrimination_weight");
        case InfractionType.Cheating:
            return GetConVarFloat("spyglass_cheating_weight");
    }

    return 0.0;
}

string function Spyglass_GetInfractionAsString(PlayerInfraction infraction)
{
    string typeString = "Invalid";
    switch (infraction.Type)
    {
        case InfractionType.Spoof: typeString = "Spoofed"; break;
        case InfractionType.Spamming: typeString = "Spamming"; break;
        case InfractionType.Toxicity: typeString = "Toxicity"; break;
        case InfractionType.Discrimination: typeString = "Discrimination"; break;
        case InfractionType.Cheating: typeString = "Cheating"; break;
    }

    return format("[%s] (%s) By %s: %s", infraction.Date, typeString, infraction.Issuer, infraction.Reason);
}

// Nabbed from Fifty's Server Utils, go check them out!
string function GetColoredConVarString(string cvarName)
{
    string realValue = GetConVarString(cvarName);
    array<string> realSplit = SplitEscapedString(realValue, "\\x1b");
    string result;

    foreach (_index, string value in realSplit)
    {
        result += value;

        if(_index != realSplit.len() - 1)
        {
            result += "\x1b";
        }

        printt(result);
    }

    return result;
}

array<string> function SplitEscapedString(string value, string separator)
{
    array<string> result;
    string temp = value;

    int lastIndex = 0

    while (true)
    {
        var foundIndex = value.find(separator);

        if(foundIndex == null)
        {
            result.append(value.slice(lastIndex, value.len()));
            break;
        }

        int tempIndex = expect int(foundIndex);

        value = value.slice(0, tempIndex) + value.slice(tempIndex + separator.len(), value.len());
        result.append(value.slice(lastIndex, tempIndex));

        lastIndex = tempIndex;
    }

    if (result.len() == 0)
    {
        result.append(value);
    }

    return result;
}