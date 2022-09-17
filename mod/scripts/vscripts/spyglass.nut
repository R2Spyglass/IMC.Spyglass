global function Spyglass_Init
global array<string> Spyglass_MutedPlayers
global array<string> Spyglass_BannedPlayers

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

    array<PlayerInfraction> foundInfractions = Spyglass_Infractions[player.GetUID()];
    float totalWeight = 0.0;

    PlayerInfraction lastInfraction;
    int validInfractions = 0;
    bool shouldNotifyPlayers = GetConVarBool("spyglass_punishment_notifications") && GetConVarBool("spyglass_global_punishment_notifications") && Spyglass_BannedPlayers.find(player.GetUID()) == -1;


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

    // TODO: Potentially notify chat/server admins in chat that a player was punished.
    if(totalWeight >= GetConVarFloat("spyglass_ban_score_threshold"))
    {

        string reason = format("[Spyglass] You have been banned due to %i infraction(s). Latest infraction: %s", validInfractions, GetInfractionAsString(lastInfraction));
        printt(format("[Spyglass] Player '%s' [%s] was banned due to reaching an infraction score of %d.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayers)
        {
            Spyglass_BannedPlayers.append(player.GetUID());
            string message = format("\1xb[38;5;208mSpyglass\x1b[0m: Player '%s' has been banned due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, GetInfractionAsString(lastInfraction));
            Chat_ServerBroadcast(message);
        }

        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand("ban " + player.GetUID() + " " + reason);
        }
        else
        {
            ServerCommand("kick " + player.GetUID() + " " + reason);
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
        Chat_ServerPrivateMessage(player, GetConVarString("spyglass_welcome_message"), false)
    }

    if (!(player.GetUID() in Spyglass_Infractions))
    {
        return;
    }

    array<PlayerInfraction> foundInfractions = Spyglass_Infractions[player.GetUID()];
    float totalWeight = 0.0;
    int validInfractions = 0;
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

    if (totalWeight >= GetConVarFloat("spyglass_mute_score_threshold")
    {
        Spyglass_MutedPlayers.append(player.GetUID())
        printt(format("[Spyglass] Player '%s' [%s] was muted due to reaching an infraction score of %d.", player.GetPlayerName(), player.GetUID(), totalWeight))
        if (shouldNotifyPlayer)
        {
            if (shouldNotifyGlobal)
            {
                string message = format("\1xb[38;5;208mSpyglass\x1b[0m: Player '%s' has been muted due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, GetInfractionAsString(lastInfraction));
                Chat_ServerBroadcast(message);
            }
            else
            {
                string reason = format("\1xb[38;5;208mSpyglass\x1b[0m: You have been muted due to %i infraction(s).\nLatest infraction: %s", validInfractions, GetInfractionAsString(lastInfraction));
                Chat_ServerPrivateMessage(player, reason, false);
            }
        }
    }
    else if (totalWeight >= GetConVarFloat("spyglass_warn_score_threshold"))
    {
        printt(format("[Spyglass] Player '%s' [%s] was warned due to reaching an infraction score of %d.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer)
        {
            if (shouldNotifyGlobal)
            {
                string message = format("\1xb[38;5;208mSpyglass\x1b[0m: Player '%s' has been warned due to %i infraction(s).\nLatest infraction: %s", player.GetPlayerName(), validInfractions, GetInfractionAsString(lastInfraction));
                Chat_ServerBroadcast(message);
            }
            else
            {
                string reason = format("\1xb[38;5;208mSpyglass\x1b[0m: You have been warned due to %i infraction(s).\nLatest infraction: %s", validInfractions, GetInfractionAsString(lastInfraction));
                Chat_ServerPrivateMessage(player, reason, false);
            }
        }
    }
}

void function OnClientDisconnected(entity player)
{
    if (IsValid(player))
    {
        int FoundIndex = Spyglass_MutedPlayers.find(player.GetUID())
        if (FoundIndex != -1)
        {
            Spyglass_MutedPlayers.remove(FoundIndex)
        }
    }
}

ClClient_MessageStruct function OnClientMessage(ClClient_MessageStruct message)
{
    if(IsValid(message.player) && Spyglass_MutedPlayers.find(message.player.GetUID()) != -1)
    {
        message.shouldBlock = true;
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

string function GetInfractionAsString(PlayerInfraction infraction)
{
    string typeString = "Invalid";
    switch (infraction.Type)
    {
        case InfractionType.Spoof:
            return "Spoofed";
        case InfractionType.Spamming:
            return "Spamming";
        case InfractionType.Toxicity:
            return "Toxicity";
        case InfractionType.Discrimination:
            return "Discrimination";
        case InfractionType.Cheating:
            return "Cheating";
    }

    return format("[%s] (%s) By %s: %s", infraction.Date, typeString, infraction.Issuer, infraction.Reason)
}