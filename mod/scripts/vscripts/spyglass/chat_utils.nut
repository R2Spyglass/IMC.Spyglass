global function Spyglass_ChatUtils_Init;
table<string, void functionref(entity, array<string>)> SpyglassCommands = {}

void function Spyglass_ChatUtils_Init()
{
    AddCallback_OnReceivedSayTextMessage(HandleSpyglassCommand);

    SpyglassCommands["auth"] <- SpyglassCommand_Authenticate;
}

ClServer_MessageStruct function HandleSpyglassCommand(ClServer_MessageStruct message)
{
    if (!IsValid(message.player))
    {
        return message;
    }

    // Ignore if the player is muted or the message has been blocked by another callback.
    if (Spyglass_IsMuted(message.player.GetUID()) || message.shouldBlock)
    {
        return message;
    }

    // Check that the player is allowed to execute this command.
    if (!Spyglass_IsAdmin(message.player))
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
        Spyglass_SayPrivate(message.player, format("Unknown command '%s'.", commandName));
        message.shouldBlock = true;
        return message;
    }

    // Check that the player is authenticated first.
    if (!Spyglass_IsAuthenticated(message.player))
    {
        if (SpyglassCommands[commandName] != SpyglassCommand_Authenticate)
        {
            Spyglass_SayPrivate(message.player, "You must authenticate first!");
            message.shouldBlock = true;
            return message;
        }
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

void function SpyglassCommand_Authenticate(entity player, array<string> args)
{
    if (args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Cannot authenticate: please input the password when trying to authenticate.");
        return;
    }

    string password = strip(args[0]);
    int result = Spyglass_AuthenticateAdmin(player, password);

    string message = "An internal issue has occurred, please try again later.";
    switch (result)
    {
        case Spyglass_AuthenticationResult.NotAdmin:
            message = "Only admins can authenticate.";
            break;
        case Spyglass_AuthenticationResult.AuthenticationDisabled:
            message = "The server is missing a valid auth password in the 'spyglass_admin_auth_password' convar.";
            break;
        case Spyglass_AuthenticationResult.WrongPassword:
            message = "Wrong password.";
            break;
        case Spyglass_AuthenticationResult.AlreadyAuthenticated:
            message = "You are already authenticated.";
            break;
        case Spyglass_AuthenticationResult.Success:
            message = "Authentication successful, welcome back administrator.";
            break;
    }

    Spyglass_SayPrivate(player, message);
}

void function SpyglassCommand_GetUID(entity player, array<string> args)
{
    foreach (entity target in GetPlayerArray())
    {
        if (IsValid(target) && target.IsPlayer())
        {
            Chat_ServerPrivateMessage(player, format("%s: %s", target.GetPlayerName(), target.GetUID()), false);
        }
    }
}