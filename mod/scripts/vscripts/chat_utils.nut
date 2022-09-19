global function Spyglass_ChatUtils_Init;
array<Spyglass_Command> RegisteredCommands = []

void function Spyglass_ChatUtils_Init()
{
    AddCallback_OnReceivedSayTextMessage(HandleSpyglassCommand);
    //command name max length is 17 characters to make it look cool I hope
    RegisterCommand("infractions", "Shows you the reports for a speciffic player",SpyglassCommand_Infractions )
    RegisterCommand("finduid","Returns the UID of a player based on a name",SpyglassCommand_FindUID)
    RegisterCommand("findname", "Returns the name of a player based on a UID",SpyglassCommand_FindName)
    RegisterCommand("help", "Tells you available chat commands for spyglass",SpyglassCommand_Help )
    RegisterCommand("spyglass", "Tells you what spyglass is",SpyglassCommand_SpyglassInfo )

}

void function SpyglassCommand_SpyglassInfo(entity player, array<string> args)
{
    string message = "Spyglass is a Northstar mod for banning and muteing players across servers"
    Chat_ServerPrivateMessage(player, message,false)
}

void function SpyglassCommand_Help(entity player, array<string> args)
{
    string message = "Available commands are:\n"
    foreach(Spyglass_Command cmd in RegisteredCommands)
    {
        Chat_ServerPrivateMessage(player,"\x1b[38;5;45m"+ cmd.Name + "\x1b[0m:  " + cmd.Description , false)
    }
}

void function SpyglassCommand_FindUID(entity player, array<string> args)
{
    if(args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Please specify a username to search for.");
        return;
    }
    
    string query = strip(args[0]);
    Spyglass_UIDQueryResult result = Spyglass_FindUIDByName(query);

    if (result.isExactMatch)
    {
        Spyglass_SayPrivate(player, format("Found an exact match for username '%s': [%s]", result.foundNames[0], result.foundUID));
        return;
    }

    if (result.foundNames.len() == 1)
    {
        Spyglass_UIDQueryResult partialResult = Spyglass_FindUIDByName(result.foundNames[0]);
        Spyglass_SayPrivate(player, format("Found a partial match '%s' from query '%s': [%s]", result.foundNames[0], query, partialResult.foundUID));
        return;
    }
    
    // We found some partial matches, output them if there's not too many results.
    if (result.foundNames.len() > 0)
    {
        if (result.foundNames.len() > 10)
        {
            Spyglass_SayPrivate(player, format("Too many partial matches for username '%s', please try to narrow down your query.", query));
            return;
        }

        Spyglass_SayPrivate(player, format("Found %i partial matches for username '%s', did you mean:", result.foundNames.len(), query));
        string matches = format("'%s'", result.foundNames[0]);

        for (int idx = 1; idx < result.foundNames.len(); ++idx)
        {
            string formatted = format(", '%s'", result.foundNames[idx]);

            if (matches.len() + formatted.len() <= 254)
            {
                matches += formatted;
            }
            else
            {
                Spyglass_SayPrivate(player, matches);
                matches = result.foundNames[idx];
            }
        }

        if (matches.len() > 0)
        {
            Spyglass_SayPrivate(player, matches);
        }
    }
    else
    {
        Spyglass_SayPrivate(player, format("Could not find a full or partial match for username '%s'.", query));
    }
}

void function SpyglassCommand_FindName(entity player, array<string> args)
{
    if(args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Please specify a UID to search for.");
        return;
    }

    string clean = strip(args[0]);
    array<string> matches = Spyglass_FindPlayerNameByUID(clean);

    if (matches.len() == 0)
    {
        Spyglass_SayPrivate(player, format("Could not find any match for UID [%s] in the database.", clean));
        return;
    }

    if (matches.len() == 1)
    {
        Spyglass_SayPrivate(player, format("UID [%s] belongs to player '%s'.", clean, matches[0]));
        return;
    }

    Spyglass_SayPrivate(player, format("UID [%s] belongs to the player with the following usernames:", clean));

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
    Spyglass_Command currentCommand = CheckForCommand(commandName)
    if(currentCommand.isFound == false)
    {
        return message
    }
    
    // Remove the command from the arguments.
    args.remove(0);

    // Send the command message back to the player so they know what they sent.
    Chat_PrivateMessage(message.player, message.player, message.message, false);

    // Execute the command and block the message.
    currentCommand.CommandFunction(message.player, args)

    message.shouldBlock = true;
    return message;
}
Spyglass_Command function CheckForCommand(string commandName)
{
    foreach(Spyglass_Command cmd in RegisteredCommands)
    {
        if(cmd.Name == commandName|| cmd.Aliases.find(commandName)!= -1 )
        {   
            cmd.isFound = true
            return cmd
        }
    }
    Spyglass_Command IsFalseReturn = {isFound = false,...}
    return IsFalseReturn
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
        if (!result.isExactMatch)
        {
            Spyglass_SayPrivate(player, format("Could not find an exact match for username or UID '%s'.\nPlease use the 'finduid' and 'findname' commands to narrow your query down.", clean));
            return;
        }

        infractions = Spyglass_GetPlayerInfractions(result.foundUID);
        uid = result.foundUID;
    }
    
    if (infractions.len() == 0)
    {
        Spyglass_SayPrivate(player, format("There are no infractions recorded for username or UID '%s'.", uid));
        return;
    }

    Spyglass_SayPrivate(player, format("Found %i infraction(s) for '%s' [%s]:", infractions.len(), infractions[0].PlayerUsername, uid));
    Spyglass_ChatSendPlayerInfractions(uid, [ player ], 0, false);
}

void function RegisterCommand(string Name,string Description,void functionref(entity, array<string>) CommandFunction, array<string> Aliases = [] )
{
    Spyglass_Command cmd ={...}
        cmd.Name = Name
        cmd.Description = Description
        cmd.CommandFunction = CommandFunction
        cmd.Aliases = Aliases
    
    RegisteredCommands.append(cmd)
}