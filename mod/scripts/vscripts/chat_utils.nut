global function Spyglass_ChatUtils_Init;
table<string, void functionref(entity, array<string>)> SpyglassCommands = {}

void function Spyglass_ChatUtils_Init()
{
    AddCallback_OnReceivedSayTextMessage(HandleSpyglassCommand);

    SpyglassCommands["infractions"] <- SpyglassCommand_Infractions;
    SpyglassCommands["find"] <- SpyglassCommand_FindPlayer;
}

ClServer_MessageStruct function HandleSpyglassCommand(ClServer_MessageStruct message)
{
    if (!IsValid(message.player))
    {
        return message;
    }

    // Ignore if the player is muted or the message has been blocked by another callback.
    if (Spyglass_IsMuted(message.player) || message.shouldBlock)
    {
        return message;
    }

    bool bAdminOnly = GetConVarBool("spyglass_commands_admin_only");
    // Check that the player is allowed to execute this command.
    if (bAdminOnly && (!Spyglass_IsAdmin(message.player)))
    {
        return message;
    }

    // Make sure the message started with the command prefix.
    string msg = strip(message.message);
    string commandPrefix = strip(GetConVarString("spyglass_command_prefix"));
    var prefixIndex = msg.find(commandPrefix);

    if (prefixIndex == null || expect int(prefixIndex) != 0)
    {
        return message;
    }

    // Remove the prefix from the message.
    string prefixless = msg.slice(expect int(prefixIndex) + commandPrefix.len(), msg.len());
    prefixless = strip(prefixless);

    // Split the message into command arguments.
    array<string> args = split(prefixless, " ");
    string commandName = args[0].tolower();
    
    // Ensure the command name is a valid command.
    if(!(commandName in SpyglassCommands))
    {
        return message;
    }
    
    // Remove the command from the arguments.
    args.remove(0);

    // Send the command message back to the player so they know what they sent.
    Chat_PrivateMessage(message.player, message.player, message.message, false);

    // Execute the command and block the message.
    SpyglassCommands[commandName](message.player, args);

    message.shouldBlock = true;
    return message;
}

void function SpyglassCommand_FindPlayer(entity player, array<string> args)
{
    if(args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Please specify a username or UID to search for.");
        return;
    }
    
    string query = strip(args[0]);

    // Check if we can find a UID that matches that query first.
    array<string> matches = Spyglass_FindPlayerNameByUID(query);
    if (matches.len() > 0)
    {
        if (matches.len() == 1)
        {
            Spyglass_SayPrivate(player, format("UID [%s] belongs to player '%s'.", query, matches[0]));
            return;
        }

        Spyglass_SayPrivate(player, format("UID [%s] belongs to the player with the following usernames:", query));

        string message = matches[0];
        for (int idx = 1; idx < matches.len(); ++idx)
        {
            string formatted = format("\n%s", matches[idx]);

            if (message.len() + formatted.len() <= 254)
            {
                message += formatted;
            }
            else
            {
                Spyglass_SayPrivate(player, message);
                message = matches[idx];
            }
        }

        if (message.len() > 0)
        {
            Spyglass_SayPrivate(player, message);
        }

        return;
    }

    // If not, try to check if the query matches any username(s).
    Spyglass_UIDQueryResult result = Spyglass_FindUIDByName(query);

    if (result.IsExactMatch)
    {
        Spyglass_SayPrivate(player, format("Found an exact match for username '%s': [%s]", result.FoundNames[0], result.FoundUID));
        return;
    }

    if (result.FoundNames.len() == 1)
    {
        Spyglass_UIDQueryResult partialResult = Spyglass_FindUIDByName(result.FoundNames[0]);
        Spyglass_SayPrivate(player, format("Found a partial username match '%s' from query '%s': [%s]", result.FoundNames[0], query, partialResult.FoundUID));
        return;
    }
    
    // We found some partial matches, output them if there's not too many results.
    if (result.FoundNames.len() > 0)
    {
        if (result.FoundNames.len() > 10)
        {
            Spyglass_SayPrivate(player, format("Too many partial matches for username '%s', please try to narrow down your query.", query));
            return;
        }

        Spyglass_SayPrivate(player, format("Found %i partial username matches for query '%s', did you mean:", result.FoundNames.len(), query));
        string matches = format("'%s'", result.FoundNames[0]);

        for (int idx = 1; idx < result.FoundNames.len(); ++idx)
        {
            string formatted = format(", '%s'", result.FoundNames[idx]);

            if (matches.len() + formatted.len() <= 254)
            {
                matches += formatted;
            }
            else
            {
                Spyglass_SayPrivate(player, matches);
                matches = result.FoundNames[idx];
            }
        }

        if (matches.len() > 0)
        {
            Spyglass_SayPrivate(player, matches);
        }
    }
    else
    {
        Spyglass_SayPrivate(player, "Could not find any UID or username matching the query.");
    }
}

void function SpyglassCommand_Infractions(entity player, array<string> args)
{
    if(args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Please specify a username to search for.");
        return;
    }

    string clean = strip(args[0]);
    
    // Check if this is a valid UID. 
    array<PlayerInfraction> infractions = Spyglass_GetPlayerInfractions(clean);
    string uid = clean;

    if (infractions.len() == 0)
    {
        Spyglass_UIDQueryResult result = Spyglass_FindUIDByName(clean);
        if (!result.IsExactMatch)
        {
            Spyglass_SayPrivate(player, format("Could not find an exact match for username or UID '%s'.\nPlease use the 'finduid' and 'findname' commands to narrow your query down.", clean));
            return;
        }

        infractions = Spyglass_GetPlayerInfractions(result.FoundUID);
        uid = result.FoundUID;
    }
    
    if (infractions.len() == 0)
    {
        Spyglass_SayPrivate(player, format("There are no infractions recorded for username or UID '%s'.", uid));
        return;
    }

    Spyglass_SayPrivate(player, format("Found %i infraction(s) for '%s' [%s]:", infractions.len(), infractions[0].PlayerUsername, uid));
    Spyglass_ChatSendPlayerInfractions(uid, [ player ], 0, false);
}