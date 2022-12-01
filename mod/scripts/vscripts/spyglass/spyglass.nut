global function Spyglass_Init;
global function Spyglass_ChatSendPlayerInfractions;
global function Spyglass_SayAll;
global function Spyglass_SayPrivate;
global function Spyglass_IsAdmin;
global function Spyglass_HasImmunity;
global function Spyglass_IsMuted;
global function Spyglass_IsBanned;
global function Spyglass_GetOnlineAdmins;
global function Spyglass_AuthenticateAdmin;
global function Spyglass_IsAuthenticated;

array<string> Spyglass_MutedPlayers;
array<string> Spyglass_BannedPlayers;

array<string> Spyglass_AuthenticatedPlayers;

// TODO: Custom callback for sanctions

void function Spyglass_Init()
{
    printt("[Spyglass] Spyglass_Init() called.");
    AddCallback_OnClientConnecting(OnClientConnecting);
    AddCallback_OnClientConnected(OnClientConnected);
    AddCallback_OnClientDisconnected(OnClientDisconnected);
    // AddCallback_OnReceivedSayTextMessage(OnClientMessage);

    AddCallback_GameStateEnter(eGameState.Prematch, OnPrematchStarted);

    if (GetGameState() < eGameState.Prematch)
    {
        printt("[Spyglass] Before prematch, waiting. ")
    }
    else
    {
        OnPrematchStarted();
    }
}

void function OnPrematchStarted()
{
    printt("[Spyglass] Prematch started, connecting to API...");
    Spyglass_SayAll("Connecting to online sanction service...");
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
    //     message = format("Player \x1b[111m%s\x1b[0m has been muted due to %i infraction(s):", player.GetPlayerName(), validInfractions);
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

void function OnClientDisconnected(entity player)
{
    if (IsValid(player))
    {
        int foundIndex = Spyglass_MutedPlayers.find(player.GetUID());
        if (foundIndex != -1)
        {
            Spyglass_MutedPlayers.remove(foundIndex);
        }

        int authIndex = Spyglass_AuthenticatedPlayers.find(player.GetUID());
        if (authIndex != -1)
        {
            Spyglass_AuthenticatedPlayers.remove(authIndex);
        }
    }
}

ClServer_MessageStruct function OnClientMessage(ClServer_MessageStruct message)
{
    // Ignore if the message is already blocked, if the player is invalid or the player is immune.
    if (message.shouldBlock || !IsValid(message.player) || Spyglass_HasImmunity(message.player))
    {
        return message;
    }

    if (Spyglass_IsMuted(message.player))
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

/**
 * Sends the player's infractions in chat, if any. Packs them into messages together when possible.
 * @param uid The UID of the player for which to retrieve the infractions.
 * @param targets If set, the infractions will only be sent to those players. Leave empty to send globally.
 * @param limit The limit of infractions to send to the chat. Leave at default for all infractions.
 * @param fromNewest Whether or not to print the newest infractions first, or start from the oldest.
 */
void function Spyglass_ChatSendPlayerInfractions(string uid, array<Spyglass_PlayerInfraction> infractions, array<entity> targets = [], int limit = 0, bool fromNewest = true)
{
    foreach (entity target in targets)
    {
        if (!IsValid(target) || !target.IsPlayer())
        {
            printt("[Spyglass] Error: attempted to print player infractions to chat with invalid target entity.");
            return;
        }
    }

    // Get the player's infractions if any.
    if (infractions.len() == 0)
    {
        return;
    }

    // Define loop start index and direction + condition here to avoid writing code twice.
    int startIdx = fromNewest ? infractions.len() - 1 : 0;
    bool functionref(int, int, int, int, bool) loopCond = bool function (int start, int curr, int len, int limit, bool newest)
    {
        return newest
            ? (limit == 0  && curr >= 0) || curr >= Spyglass_Max(len - limit, 0)
            : curr < Spyglass_Max(limit, len);
    }

    int functionref(int, bool) loopInc = int function (int curr, bool newest) { return newest ? curr - 1 : curr + 1 }

    // Loop through all infractions to get their string respresentations.
    string currentMessage = "";
    for (int idx = startIdx; loopCond(startIdx, idx, infractions.len(), limit, fromNewest); idx = loopInc(idx, fromNewest))
    {
        Spyglass_PlayerInfraction infraction = infractions[idx];
        string infractionStr = Spyglass_GetInfractionAsString(infraction);

        // Check if we can merge the message together (limit is 254 characters)
        if (currentMessage.len() + infractionStr.len() + 1 <= 254)
        {
            currentMessage += currentMessage.len() != 0 
                ? format("\n%s", infractionStr)
                : infractionStr;
        }
        else
        {
            // Send the current message globally/to the targets.
            foreach (entity target in targets)
            {
                if (IsValid(target) && target.IsPlayer())
                {
                    Spyglass_SayPrivate(target, currentMessage, false, false);
                }
            }

            currentMessage = infractionStr;
        }
    }

    // If we have a message left, send it.
    if (currentMessage.len() > 0)
    {
        foreach (entity target in targets)
        {
            if (IsValid(target) && target.IsPlayer())
            {
                Spyglass_SayPrivate(target, currentMessage, false, false);
            }
        }
    }
}

/**
 * Sends a message to everyone in the chat as Spyglass.
 * @param message The message that Spyglass should send in chat.
 * @param withServerTag Whether or not to display the [SERVER] tag prior to Spyglass' name.
 */
void function Spyglass_SayAll(string message, bool withServerTag = false)
{
    string finalMessage = format("\x1b[38;5;208mSpyglass:\x1b[0m %s", message);
    Chat_ServerBroadcast(finalMessage, withServerTag);
}

/**
 * Sends a message to the target player in the chat as Spyglass.
 * @param player The player to send the message to.
 * @param message The message that Spyglass should send in chat.
 * @param isWhisper Whether or not to display the [WHISPER] tag prior to Spyglass' name.
 * @param withServerTag Whether or not to display the [SERVER] tag prior to Spyglass' name.
 */
void function Spyglass_SayPrivate(entity player, string message, bool isWhisper = false, bool withServerTag = false)
{
    string finalMessage = format("\x1b[38;5;208mSpyglass:\x1b[0m %s", message);
    Chat_ServerPrivateMessage(player, finalMessage, isWhisper/*, withServerTag*/);
}

/** Checks whether or not the given player is in the admin uids convar. */
bool function Spyglass_IsAdmin(entity player)
{
    array<string> adminUIDs = Spyglass_GetConVarStringArray("spyglass_admin_uids");
    return IsValid(player) && player.IsPlayer() && adminUIDs.find(player.GetUID()) != -1;
}

/** Checks whether or not the given player is immune to Spyglass sanctions. */
bool function Spyglass_HasImmunity(entity player)
{
    return GetConVarBool("spyglass_admin_immunity") && IsValid(player) && player.IsPlayer() && Spyglass_IsAdmin(player);
}

/** Checks whether or not the given player is currently muted. */
bool function Spyglass_IsMuted(entity player)
{
    return IsValid(player) && player.IsPlayer() && Spyglass_MutedPlayers.find(player.GetUID()) != -1;
}

/** Checks whether or not the given player uid is banned, and has attempted to join the server this map. */
bool function Spyglass_IsBanned(string uid)
{
    return Spyglass_BannedPlayers.find(uid) != -1;
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