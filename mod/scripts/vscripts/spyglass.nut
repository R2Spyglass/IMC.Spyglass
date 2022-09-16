global function Spyglass_Init
global array<int> Spyglass_MutedPlayers

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
    float TotalWeight = 0.0;

    // Calculate the weight of all the player's infractions.
    // We're mostly going to see if they need to be banned while they're connecting.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        TotalWeight += GetInfractionWeight(infraction);
    }

    // TODO: Potentially notify chat/server admins in chat that a player was punished.
    if(TotalWeight >= GetConVarFloat("spyglass_ban_score_threshold"))
    {
        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand("ban " + player.GetUID());
        }
        else
        {
            ServerCommand("kick " + player.GetUID());
        }

        // Chat_ServerBroadcast(player.GetPlayerName() +  " was banned because of his previous behaviour")
    }
}

void function OnClientConnected(entity player)
{
    if (!IsValid(player) || !(player.GetUID() in Spyglass_Infractions))
    {
        return;
    }

    array<PlayerInfraction> foundInfractions = Spyglass_Infractions[player.GetUID()];
    float TotalWeight = 0.0;

    // Calculate the weight of all the player's infractions.
    // Bans are already handled in OnClientConnecting so we don't need to check again.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        TotalWeight += GetInfractionWeight(infraction);
    }

    // TODO: Potentially notify chat/server admins in chat that a player was punished.
    // Make it configurable & we'll give the list of infractions to the player with their reasons.
    // [Spyglass] You have been muted due to the following infraction(s):
    // [01/12/2022] (HeavyToxicity) by Erlite#1337: Insulting using racial slur on Vanilla #5.
    // [01/12/2022] (ChatSpawm) by Erlite#1337: Spammed chat for 20 seconds.
    // Localization mostly.
    if (TotalWeight >= GetConVarFloat("spyglass_mute_score_threshold")
    {
        Spyglass_MutedPlayers.append(player.GetUID())
        printt(player.GetPlayerName()+ "(" +player.GetUID()+")" "has been muted")
        Chat_ServerPrivateMessage(player, "You have been muted due to your message history",false)
    }
    else if (TotalWeight >= GetConVarFloat("spyglass_warn_score_threshold"))
    {
        // TODO: write sth that sounds better
        Chat_ServerPrivateMessage(player, "You have been reported if you keep up with this you will be muted or banned",false)
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
    if(Spyglass_MutedPlayers.find(message.player.GetUID()) != -1)
    {
        message.shouldBlock = true
    }

    return messagee
}

float function GetInfractionWeight(PlayerInfraction infraction)
{
    switch (infraction.Type)
    {
        case InfractionType.ChatSpam:
            return GetConVarFloat("spyglass_chat_spam_weight");
        case InfractionType.LightToxicity:
            return GetConVarFloat("spyglass_light_toxicity_weight");
        case InfractionType.HeavyToxicity:
            return GetConVarFloat("spyglass_heavy_toxicity_weight");
        case InfractionType.Cheating:
            return GetConVarFloat("spyglass_cheating_weight");
    }

    return 0.0;
}