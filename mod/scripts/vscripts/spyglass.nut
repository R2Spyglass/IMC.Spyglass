global function Spyglass_Init;
global function Spyglass_GetPlayerInfractions;
global function Spyglass_ChatSendPlayerInfractions;
global function Spyglass_SayAll;
global function Spyglass_SayPrivate;
global function Spyglass_IsAdmin;
global function Spyglass_IsMaintainer;
global function Spyglass_IsMuted;
global function Spyglass_IsBanned;
global function Spyglass_FindUIDByName;
global function Spyglass_FindPlayerNameByUID;

array<string> Spyglass_MutedPlayers;
array<string> Spyglass_BannedPlayers;
array<string> Spyglass_Maintainers = 
[
    "1005829030626", // Erlite
    "1008806725370", // Neinguar
];

// TODO: Custom callback for sanctions

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
    if (!IsValid(player))
    {
        return;
    }

    array<PlayerInfraction> foundInfractions = Spyglass_GetPlayerInfractions(player.GetUID());
    if (foundInfractions.len() == 0)
    {
        return;
    }

    float totalWeight = 0.0;
    int validInfractions = 0;

    bool shouldNotifyPlayer = GetConVarBool("spyglass_sanctions_notifications");
    bool shouldNotifyGlobal = GetConVarBool("spyglass_global_sanctions_notifications");
    bool bannedAlready = Spyglass_BannedPlayers.find(player.GetUID()) != -1;

    // Calculate the weight of all the player's infractions.
    // We're mostly going to see if they need to be banned while they're connecting.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        totalWeight += Spyglass_GetInfractionWeight(infraction);

        if (infraction.Type != InfractionType.Spoof)
        {
            validInfractions += 1;
        }
    }

    if(totalWeight >= GetConVarFloat("spyglass_ban_score_threshold"))
    {
        printt(format("[Spyglass] Player '%s' [%s] was banned due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer && shouldNotifyGlobal && !bannedAlready)
        {
            Spyglass_BannedPlayers.append(player.GetUID());
            string message = format("Player \x1b[111m%s\x1b[0m has been banned due to %i infraction(s):", player.GetPlayerName(), validInfractions);
            Spyglass_SayAll(message);
            Spyglass_ChatSendPlayerInfractions(player.GetUID());
        }

        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand(format("ban %s", player.GetPlayerName()));
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
        Chat_ServerPrivateMessage(player, Spyglass_GetColoredConVarString("spyglass_welcome_message"), false/*, false*/);
    }

    array<PlayerInfraction> foundInfractions = Spyglass_GetPlayerInfractions(player.GetUID());
    if (foundInfractions.len() == 0)
    {
        return;
    }

    int validInfractions = 0;
    float totalWeight = 0.0;

    bool shouldNotifyPlayer = GetConVarBool("spyglass_sanctions_notifications");
    bool shouldNotifyGlobal = GetConVarBool("spyglass_global_sanctions_notifications");

    // Calculate the weight of all the player's infractions.
    // Bans are already handled in OnClientConnecting so we don't need to check again.
    foreach (PlayerInfraction infraction in foundInfractions)
    {
        totalWeight += Spyglass_GetInfractionWeight(infraction);
        if (infraction.Type != InfractionType.Spoof)
        {
            validInfractions += 1;
        }
    }

    if (totalWeight >= GetConVarFloat("spyglass_mute_score_threshold"))
    {
        Spyglass_MutedPlayers.append(player.GetUID())
        printt(format("[Spyglass] Player '%s' [%s] was muted due to reaching an infraction score of %f.", player.GetPlayerName(), player.GetUID(), totalWeight))

        if (shouldNotifyPlayer)
        {
            if (shouldNotifyGlobal)
            {
                string message = format("Player \x1b[111m%s\x1b[0m has been muted due to %i infraction(s):", player.GetPlayerName(), validInfractions);
                Spyglass_SayAll(message);
                Spyglass_ChatSendPlayerInfractions(player.GetUID());
            }
            else
            {
                string reason = format("You have been muted due to %i infraction(s):", validInfractions);
                Spyglass_SayPrivate(player, reason, true, false);
                Spyglass_ChatSendPlayerInfractions(player.GetUID(), [ player ]);
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
                string message = format("Player \x1b[111m%s\x1b[0m has been warned due to %i infraction(s):", player.GetPlayerName(), validInfractions);
                Spyglass_SayAll(message);
                Spyglass_ChatSendPlayerInfractions(player.GetUID());
            }
            else
            {
                string reason = format("You have been warned due to %i infraction(s):", validInfractions);
                Spyglass_SayPrivate(player, reason, true, false);
                Spyglass_ChatSendPlayerInfractions(player.GetUID(), [ player ]);
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
    // Ignore if the message is already blocked.
    if (message.shouldBlock)
    {
        return message;
    }

    if (IsValid(message.player) && Spyglass_IsMuted(message.player))
    {
        message.shouldBlock = true;

        if (GetConVarBool("spyglass_notify_muted_player"))
        {
            Spyglass_SayPrivate(message.player, "I prevented you from talking as you are permanently muted.", true, false);
        }
        else
        {
            // Send the message back to them so they don't even know it was muted.
            Chat_PrivateMessage(message.player, message.player, message.message, false);
        }
    }

    return message;
}

/**
 * Returns the infractions of a player, if any.
 * @param uid The UID of the player to retrieve the infractions for.
 * @retuns An array containing the player's infractions if any, or an empty array if not.
 */
array<PlayerInfraction> function Spyglass_GetPlayerInfractions(string uid)
{
    array<PlayerInfraction> infractions = [];

    return uid in Spyglass_Infractions 
        ? clone Spyglass_Infractions[uid]
        : infractions;
}

/**
 * Sends the player's infractions in chat, if any. Packs them into messages together when possible.
 * @param uid The UID of the player for which to retrieve the infractions.
 * @param targets If set, the infractions will only be sent to those players. Leave empty to send globally.
 * @param limit The limit of infractions to send to the chat. Leave at default for all infractions.
 * @param fromNewest Whether or not to print the newest infractions first, or start from the oldest.
 */
void function Spyglass_ChatSendPlayerInfractions(string uid, array<entity> targets = [], int limit = 0, bool fromNewest = true)
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
    bool isGlobal = targets.len() == 0;
    array<PlayerInfraction> infractions = Spyglass_GetPlayerInfractions(uid);
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
        PlayerInfraction infraction = infractions[idx];
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
            if (isGlobal)
            {
                Chat_ServerBroadcast(currentMessage/*, false*/);
            }
            else
            {
                foreach (entity target in targets)
                {
                    if (IsValid(target) && target.IsPlayer())
                    {
                        Chat_ServerPrivateMessage(target, currentMessage, false /*, false*/);
                    }
                }
            }

            currentMessage = infractionStr;
        }
    }

    // If we have a message left, send it.
    if (currentMessage.len() > 0)
    {
        if (isGlobal)
        {
            Chat_ServerBroadcast(currentMessage /*, false*/);
        }
        else
        {
            foreach (entity target in targets)
            {
                if (IsValid(target) && target.IsPlayer())
                {
                    Chat_ServerPrivateMessage(target, currentMessage, false/*, false*/);
                }
            }
        }
    }
}

// TODO: Re-enable withServerTag once PR is merged.

/**
 * Sends a message to everyone in the chat as Spyglass.
 * @param message The message that Spyglass should send in chat.
 * @param withServerTag Whether or not to display the [SERVER] tag prior to Spyglass' name.
 */
void function Spyglass_SayAll(string message, bool withServerTag = false)
{
    string finalMessage = format("\x1b[38;5;208mSpyglass:\x1b[0m %s", message);
    Chat_ServerBroadcast(finalMessage /*, withServerTag*/);
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
    Chat_ServerPrivateMessage(player, finalMessage, isWhisper /*, withServerTag*/);
}

/** Checks whether or not the given player is in the admin uids convar. */
bool function Spyglass_IsAdmin(entity player)
{
    array<string> adminUIDs = Spyglass_GetConVarStringArray("spyglass_admin_uids");
    return IsValid(player) && player.IsPlayer() && adminUIDs.find(player.GetUID()) != -1;
}

/** Checks whether or not the given player is a maintainer of Spyglass. */
bool function Spyglass_IsMaintainer(entity player)
{
    return IsValid(player) && player.IsPlayer() && Spyglass_Maintainers.find(player.GetUID()) != -1;
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

/**
 * Attempts to find a player's UID from the given name.
 * Only players in the infractions database can be found.
 * @param name The name of the player to find, can be a partial name.
 * @returns The result of the query. May either contain an exact matched UID, or an array of player names that partially match.
 */
Spyglass_UIDQueryResult function Spyglass_FindUIDByName(string name)
{
    string clean = strip(name.tolower());
    Spyglass_UIDQueryResult result = { isExactMatch = false, foundUID = "", foundNames = [] };

    if (clean.len() == 0)
    {
        return result;
    }

    if (clean in Spyglass_PlayerNameUIDMap)
    {
        result.isExactMatch = true;
        result.foundUID = Spyglass_PlayerNameUIDMap[clean];
        return result;
    }

    array<string> allUIDs = [];
    // Try to find a partial match for the player name.
    foreach (key, value in Spyglass_PlayerNameUIDMap)
    {
        if (key.find(clean) != null)
        {
            // Get the infractions for the player and use the player name that's equal to the query.
            array<PlayerInfraction> infractions = Spyglass_GetPlayerInfractions(value);
            if (infractions.len() > 0)
            {
                foreach (PlayerInfraction infraction in infractions)
                {
                    string partialName = infraction.PlayerUsername.tolower();
                    if (partialName.find(clean) != null && result.foundNames.find(infraction.PlayerUsername) == -1)
                    {
                        result.foundNames.append(infraction.PlayerUsername);
                        
                        if (allUIDs.find(value) == -1)
                        {
                            allUIDs.append(value);
                        }
                    }
                }
            }
        }
    }

    // If we only got one UID with a partial match, make it an exact match.
    if (allUIDs.len() == 1)
    {
        result.isExactMatch = true;
        result.foundUID = allUIDs[0];
    }

    return result;
}

/** Returns an array of player names that match the given uid. */
array<string> function Spyglass_FindPlayerNameByUID(string uid)
{
    array<PlayerInfraction> infractions = Spyglass_GetPlayerInfractions(uid);
    array<string> matches = [];

    if (infractions.len() == 0)
    {
        return matches;
    }

    foreach (PlayerInfraction infraction in infractions)
    {
        if (matches.find(infraction.PlayerUsername) == -1)
        {
            matches.append(infraction.PlayerUsername);
        }
    }

    return matches;
}