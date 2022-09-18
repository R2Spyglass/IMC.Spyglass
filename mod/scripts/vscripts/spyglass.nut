global function Spyglass_Init;
global function Spyglass_GetPlayerInfractions;
global function Spyglass_ChatSendPlayerInfractions;
global function Spyglass_SayAll;
global function Spyglass_SayPrivate;

global array<string> Spyglass_MutedPlayers;
global array<string> Spyglass_BannedPlayers;
global array<string> Spyglass_Maintainers = 
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

    array<PlayerInfraction> foundInfractions = Spyglass_GetPlayerInfractions(player);
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
        totalWeight += GetInfractionWeight(infraction);

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
            Spyglass_ChatSendPlayerInfractions(player);
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

    array<PlayerInfraction> foundInfractions = Spyglass_GetPlayerInfractions(player);
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
        totalWeight += GetInfractionWeight(infraction);
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
                Spyglass_ChatSendPlayerInfractions(player);
            }
            else
            {
                string reason = format("You have been muted due to %i infraction(s):", validInfractions);
                Spyglass_SayPrivate(player, reason, true, false);
                Spyglass_ChatSendPlayerInfractions(player, [ player ]);
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
                Spyglass_ChatSendPlayerInfractions(player);
            }
            else
            {
                string reason = format("You have been warned due to %i infraction(s):", validInfractions);
                Spyglass_SayPrivate(player, reason, true, false);
                Spyglass_ChatSendPlayerInfractions(player, [ player ]);
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
            Spyglass_SayPrivate(message.player, "I prevented you from talking as you are permanently muted.", true, false);
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

string function GetInfractionAsString(PlayerInfraction infraction)
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

    return format("\x1b[38;5;123m[%s] \x1b[38;2;254;64;64m(%s): \x1b[0m%s", infraction.Date, typeString, infraction.Reason);
}

/**
 * Returns the infractions of a player, if any.
 * @param player The player to retrieve the infractions for.
 * @retuns An array containing the player's infractions if any, or an empty array if not.
 */
array<PlayerInfraction> function Spyglass_GetPlayerInfractions(entity player)
{
    array<PlayerInfraction> infractions = [];

    if (!IsValid(player) || !player.IsPlayer())
    {
        printt("[Spyglass] Error: attempted to get player infractions with invalid player entity.");
        return infractions;
    }

    return player.GetUID() in Spyglass_Infractions 
        ? clone Spyglass_Infractions[player.GetUID()]
        : infractions;
}

/**
 * Sends the player's infractions in chat, if any. Packs them into messages together when possible.
 * @param player The player for which to retrieve the infractions.
 * @param targets If set, the infractions will only be sent to those players. Leave empty to send globally.
 * @param limit The limit of infractions to send to the chat. Leave at default for all infractions.
 * @param fromNewest Whether or not to print the newest infractions first, or start from the oldest.
 */
void function Spyglass_ChatSendPlayerInfractions(entity player, array<entity> targets = [], int limit = 0, bool fromNewest = true)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        printt("[Spyglass] Error: attempted to print player infractions to chat with invalid player entity.");
        return;
    }

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
    array<PlayerInfraction> infractions = Spyglass_GetPlayerInfractions(player);
    if (infractions.len() == 0)
    {
        return;
    }

    // Define loop start index and direction + condition here to avoid writing code twice.
    int startIdx = fromNewest ? infractions.len() - 1 : 0;
    var functionref(int, int, int, int, bool) loopCond = function (int start, int curr, int len, int limit, bool newest)
    {
        return newest
            ? (limit == 0  && curr >= 0) || curr >= Spyglass_Max(len - limit, 0)
            : curr < Spyglass_Min(limit, len);
    }

    var functionref(int, bool) loopInc = function (int curr, bool newest) { return newest ? curr - 1 : curr + 1 }

    // Loop through all infractions to get their string respresentations.
    string currentMessage = "";
    for (int idx = startIdx; loopCond(startIdx, idx, infractions.len(), limit, fromNewest); idx = expect int(loopInc(idx, fromNewest)))
    {
        PlayerInfraction infraction = infractions[idx];
        string infractionStr = GetInfractionAsString(infraction);

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
void function Spyglass_SayPrivate(entity player, string message, bool isWhisper, bool withServerTag = false)
{
    string finalMessage = format("\x1b[38;5;208mSpyglass:\x1b[0m %s", message);
    Chat_ServerPrivateMessage(player, finalMessage, isWhisper /*, withServerTag*/);
}