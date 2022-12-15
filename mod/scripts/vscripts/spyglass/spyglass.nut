global function Spyglass_Init;
global function Spyglass_GetOnlineAdmins;
global function Spyglass_AuthenticateAdmin;
global function Spyglass_IsAuthenticated;

array<string> Spyglass_AuthenticatedPlayers;

void function Spyglass_Init()
{
    printt("[Spyglass] Spyglass_Init() called.");
    // Reset disabled flag, will be reset on init if required.
    SetConVarBool("spyglass_cache_disabled_from_error", false);

    AddCallback_OnClientConnecting(OnClientConnecting);
    AddCallback_OnClientConnected(OnClientConnected);
    //AddCallback_OnClientDisconnected(OnClientDisconnected);
    // AddCallback_OnReceivedSayTextMessage(OnClientMessage);

    AddCallback_GameStateEnter(eGameState.Prematch, OnPrematchStarted);
    AddCallback_GameStateEnter(eGameState.Playing, OnPlayingStarted)

    if (GetGameState() >= eGameState.Prematch)
    {
        OnPrematchStarted();
    }

    if (GetGameState() >= eGameState.Playing)
    {
        OnPlayingStarted();
    }
}

// TODO: Retry on error, up to three times. Local error not counting (fail immediate).
void function OnStatsRequestComplete(Spyglass_ApiStats response)
{
    if (response.ApiResult.Success)
    {
        Spyglass_SayAll(format("Uplink established successfully, API version v%s.", Spyglass_GetLatestVersion()));
        
        switch (Spyglass_VersionCheck())
        {
            case Spyglass_VersionCheckResult.Outdated:
                Spyglass_SayAll(format("A new version '%s' is available. Please update whenever possible.", Spyglass_GetLatestVersion()));
                break;
            case Spyglass_VersionCheckResult.Unknown:
            case Spyglass_VersionCheckResult.OutdatedIncompatible:
                Spyglass_SayAll(format("\x1b[38;2;254;0;0mThis server is running an incompatible version of Spyglass, please update to '%s'.\x1b[0m", Spyglass_GetLatestVersion()));
                Spyglass_SayAll("\x1b[38;2;254;0;0mThis mod will not work until updated.\x1b[0m");
                printt("[Spyglass] Outdated and not meeting minimum required version by the API. Update as soon as possible.");
                SetConVarBool("spyglass_cache_disabled_from_error", true);
                return;
        }

        Spyglass_SayAll(format("I am currently tracking %i %s and %i %s.", response.Players, Spyglass_Pluralize("pilot", "pilots", response.Players), response.Sanctions,
            Spyglass_Pluralize("sanction", "sanctions", response.Sanctions)));
        Spyglass_RefreshAllPlayerSanctions();
    }
    else
    {
        Spyglass_SayAll(format("An error has occurred while establishing the uplink: %s", response.ApiResult.Error));
    }
}

void function OnPrematchStarted()
{
    printt("[Spyglass] Prematch started, connecting to API...");
    Spyglass_SayAll(format("Initializing core, version %s.", NSGetModVersionByModName("IMC.Spyglass")));
    Spyglass_SayAll("Establishing uplink to IMC sanction database...");

    if (!SpyglassApi_GetStats(OnStatsRequestComplete))
    {
        SetConVarBool("spyglass_cache_disabled_from_error", true);
        Spyglass_SayAll("\x1b[38;2;254;0;0mAn error has occurred, check server console for more information.\x1b[0m");
        Spyglass_SayAll("\x1b[38;2;254;0;0mThis mod will not work until the issue is resolved.\x1b[0m");
    }
}

void function OnPlayingStarted()
{
    if (Spyglass_IsDisabled())
    {
        return;
    }

    if (GetConVarBool("spyglass_welcome_message_enabled"))
    {
        foreach (entity player in GetPlayerArray())
        {
            if (IsValid(player))
            {
                NSSendInfoMessageToPlayer(player, GetConVarString("spyglass_welcome_message"));
            }
        }
    }
}

void function OnClientConnecting(entity player)
{
    if (!IsValid(player) || Spyglass_HasImmunity(player))
    {
        return;
    }

    // array<Spyglass_PlayerInfraction> foundInfractions = Spyglass_GetSpyglass_PlayerInfractions(player.GetUID());
    // if (foundInfractions.len() == 0)
    // {
    //     return;
    // }

    // float totalWeight = 0.0;
    // int validInfractions = 0;

    // int notifyMode = GetConVarInt("spyglass_sanction_notification_mode");
    // bool bannedAlready = Spyglass_BannedPlayers.find(player.GetUID()) != -1;

    // // Calculate the weight of all the player's infractions.
    // // We're mostly going to see if they need to be banned while they're connecting.
    // foreach (Spyglass_PlayerInfraction infraction in foundInfractions)
    // {
    //     totalWeight += Spyglass_GetInfractionWeight(infraction);

    //     if (infraction.Type != Spyglass_InfractionType.Spoof)
    //     {
    //         validInfractions += 1;
    //     }
    // }


    // if (GetConVarBool("spyglass_use_banlist_for_bans"))
    // {
    //     ServerCommand(format("ban %s", player.GetUID()));
    // }
    // else
    // {
    //     ServerCommand(format("kick %s", player.GetPlayerName()));
    // }
}

void function OnClientConnected(entity player)
{
    // if (!IsValid(player))
    // {
    //     return;
    // }

    // if (GetConVarBool("spyglass_welcome_message_enabled"))
    // {
    //     Chat_ServerPrivateMessage(player, Spyglass_GetColoredConVarString("spyglass_welcome_message"), false, false);
    // }

    // if (Spyglass_HasImmunity(player))
    // {
    //     return;
    // }

    // array<Spyglass_PlayerInfraction> foundInfractions = Spyglass_GetSpyglass_PlayerInfractions(player.GetUID());
    // if (foundInfractions.len() == 0)
    // {
    //     return;
    // }

    // int validInfractions = 0;
    // float totalWeight = 0.0;

    // // Calculate the weight of all the player's infractions.
    // // Bans are already handled in OnClientConnecting so we don't need to check again.
    // foreach (Spyglass_PlayerInfraction infraction in foundInfractions)
    // {
    //     totalWeight += Spyglass_GetInfractionWeight(infraction);
    //     if (infraction.Type != Spyglass_InfractionType.Spoof)
    //     {
    //         validInfractions += 1;
    //     }
    // }

    // string message = "";

    // if (totalWeight >= GetConVarFloat("spyglass_mute_score_threshold"))
    // {
    //     Spyglass_MutedPlayers.append(player.GetUID())
    //     printt(format("[Spyglass] Player '%s' [%s] was muted due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))
    //     message = ;
    // }
    // else if (totalWeight >= GetConVarFloat("spyglass_warn_score_threshold"))
    // {
    //     printt(format("[Spyglass] Player '%s' [%s] was warned due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))
    //     message = format("Player \x1b[111m%s\x1b[0m has been warned due to %i infraction(s):", player.GetPlayerName(), validInfractions);
    // }

    // int notifyMode = GetConVarInt("spyglass_sanction_notification_mode");
    // if (notifyMode == Spyglass_SanctionNotificationMode.Everyone)
    // {          
    //     Spyglass_SayAll(message);
    //     Spyglass_ChatSendPlayerInfractions(player.GetUID(), GetPlayerArray());
    // }

    // if (notifyMode == Spyglass_SanctionNotificationMode.PlayerOnly || notifyMode == Spyglass_SanctionNotificationMode.PlayerAndAdmins)
    // {
    //     Spyglass_SayPrivate(player, message);
    //     Spyglass_ChatSendPlayerInfractions(player.GetUID(), [ player ]);
    // }

    // if (notifyMode == Spyglass_SanctionNotificationMode.PlayerAndAdmins || notifyMode == Spyglass_SanctionNotificationMode.AdminsOnly)
    // {
    //     array<entity> admins = Spyglass_GetOnlineAdmins();
    //     foreach (entity target in admins)
    //     {
    //         Spyglass_SayPrivate(target, message);
    //     }

    //     Spyglass_ChatSendPlayerInfractions(player.GetUID(), admins);
    // }
}

// void function OnClientDisconnected(entity player)
// {
//     if (IsValid(player))
//     {
//         int foundIndex = Spyglass_MutedPlayers.find(player.GetUID());
//         if (foundIndex != -1)
//         {
//             Spyglass_MutedPlayers.remove(foundIndex);
//         }

//         int authIndex = Spyglass_AuthenticatedPlayers.find(player.GetUID());
//         if (authIndex != -1)
//         {
//             Spyglass_AuthenticatedPlayers.remove(authIndex);
//         }
//     }
// }

ClServer_MessageStruct function OnClientMessage(ClServer_MessageStruct message)
{
    // Ignore if the message is already blocked, if the player is invalid or the player is immune.
    if (message.shouldBlock || !IsValid(message.player) || Spyglass_HasImmunity(message.player))
    {
        return message;
    }

    if (Spyglass_IsPlayerMuted(message.player.GetUID()))
    {
        message.shouldBlock = true;

        int muteType = GetConVarInt("spyglass_mute_sanction_type");
        if (muteType == Spyglass_MuteNotificationType.Notify)
        {
            Spyglass_SayPrivate(message.player, "I prevented you from talking as you are permanently muted.", true, false);
        }
        else if (muteType == Spyglass_MuteNotificationType.Shadowban)
        {
            // Send the message back to them so they don't even know it was muted.
            Chat_PrivateMessage(message.player, message.player, message.message, false);
        }
    }

    return message;
}

/** Returns an array of admins that are currently online on this server. */
array<entity> function Spyglass_GetOnlineAdmins()
{
    array<entity> admins = [];

    foreach (entity ply in GetPlayerArray())
    {
        if (IsValid(ply) && Spyglass_IsAdmin(ply))
        {
            admins.append(ply);
        }
    }

    return admins;
}

/**
 * Authenticates the given player using the password they inputted. 
 * @param player The player that wishes to authenticate.
 * @param password The password they've tried to authenticate with.
 * @returns A Spyglass_AuthenticationResult enum value, as an int.
 */
int function Spyglass_AuthenticateAdmin(entity player, string password)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        return Spyglass_AuthenticationResult.InvalidPlayer;
    }

    if (!Spyglass_IsAdmin(player))
    {
        return Spyglass_AuthenticationResult.NotAdmin;
    }

    string authPassword = strip(GetConVarString("spyglass_admin_auth_password"));
    if (authPassword.len() == 0)
    {
        return Spyglass_AuthenticationResult.AuthenticationDisabled;
    }

    if (authPassword == password)
    {
        if (Spyglass_IsAuthenticated(player))
        {
            return Spyglass_AuthenticationResult.AlreadyAuthenticated;
        }

        Spyglass_AuthenticatedPlayers.append(player.GetUID());
        return Spyglass_AuthenticationResult.Success;
    }

    return Spyglass_AuthenticationResult.WrongPassword;
}

/** Returns true if the given player is an authenticated admin. */
bool function Spyglass_IsAuthenticated(entity player)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        return false;
    }

    return Spyglass_AuthenticatedPlayers.find(player.GetUID()) != -1;
}