global function Spyglass_AdminCommandsInit;

void function Spyglass_AdminCommandsInit()
{
    Spyglass_RegisterAdminCommand("spyglass_listuids", Spyglass_AdminListUniqueIDs);
    Spyglass_RegisterAdminCommand("spyglass_refreshsanctions", Spyglass_AdminRefreshSanctions);
    Spyglass_RegisterAdminCommand("spyglass_kickplayer", Spyglass_AdminKickPlayer);
}

/**
 * Registers a new client command callback, and ensures the caller is an authenticated admin to execute.
 */
void function Spyglass_RegisterAdminCommand(string name, bool functionref(entity, array<string>) callback)
{
    bool functionref(entity, array<string>) checkedCallback = bool function (entity player, array<string> args) : (callback)
    {
        if (!IsValid(player) || !player.IsPlayer())
        {
            return false;
        }

        if (!Spyglass_IsMaintainer(player.GetUID()))
        {
            if (!Spyglass_IsAdmin(player))
            {
                return false;
            }

            if (!Spyglass_IsAuthenticated(player.GetUID()))
            {
                Spyglass_SayPrivate(player, "You must authenticate first, using the spyglass_authenticate [password] command.");
                return true;
            }
        }

        if (callback != null)
        {
            return callback(player, args);
        }

        return true;
    }

    AddClientCommandCallback(name, checkedCallback);
}

/**
 * Lists all of the unique ids of players on the server.
 */
bool function Spyglass_AdminListUniqueIDs(entity caller, array<string> args)
{
    foreach (entity player in Spyglass_GetAllPlayers())
    {
        if (IsValid(player))
        {
            Spyglass_SayPrivate(caller, format("%s: %s", Spyglass_FriendlyColor(player.GetPlayerName()), player.GetUID()));
        }
    }

    return true;
}

bool function Spyglass_AdminRefreshSanctions(entity caller, array<string> args)
{
    bool invalidate = false;
    if (args.len() != 0)
    {
        string arg = strip(args[0]);
        if (arg == "1" || arg.tolower() == "true")
        {
            invalidate = true;
        }
    }

    if (Spyglass_RefreshAllPlayerSanctions(invalidate))
    {
        Spyglass_SayAll(format("Administrator %s is refreshing all sanctions...", Spyglass_FriendlyColor(caller.GetPlayerName())));
    }

    return true;
}

bool function Spyglass_AdminKickPlayer(entity caller, array<string> args)
{
    if (args.len() == 0)
    {
        Spyglass_SayPrivate(caller, "Missing argument: name or uid.");
        return true;
    }

    string reason = format("Kicked by %s", caller.GetPlayerName());
    if (args.len() > 1)
    {
        reason = "";
        for (int i = 1; i < args.len(); i++)
        {
            reason = format("%s%s ", reason, args[i]);
        }
    }
    
    string query = args[0];
    array<entity> matches = [];

    foreach (entity player in GetPlayerArray())
    {
        if (caller.GetUID() == query)
        {
            if (NSDisconnectPlayer(player, reason))
            {
                Spyglass_SayAll(format("Administrator %s has kicked player %s:", Spyglass_FriendlyColor(caller.GetPlayerName()), Spyglass_FriendlyColor(player.GetPlayerName())));
                Spyglass_SayAll(format("Reason: %s", reason));
                return true;
            }
            else
            {
                Spyglass_SayPrivate(caller, format("Couldn't kick player %s due to an internal error.", Spyglass_FriendlyColor(player.GetPlayerName())));
                return true;
            }
        }

        if (player.GetPlayerName().find(query) != null)
        {
            matches.append(player);
        }
    }

    if (matches.len() == 1)
    {
        entity player = matches[0];
        if (NSDisconnectPlayer(player, reason))
        {
            Spyglass_SayAll(format("Administrator %s has kicked player %s:", Spyglass_FriendlyColor(caller.GetPlayerName()), Spyglass_FriendlyColor(player.GetPlayerName())));
            Spyglass_SayAll(format("Reason: %s", reason));
            return true;
        }
        else
        {
            Spyglass_SayPrivate(caller, format("Couldn't kick player %s due to an internal error.", Spyglass_FriendlyColor(player.GetPlayerName())));
            return true;
        }
    }

    Spyglass_SayPrivate(caller, format("Could not find player with name or uid '%s'.", query));
    return true;
}