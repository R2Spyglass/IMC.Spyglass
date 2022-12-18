global function Spyglass_AdminCommandsInit;

void function Spyglass_AdminCommandsInit()
{
    Spyglass_RegisterAdminCommand("spyglass_listuids", Spyglass_AdminListUniqueIDs);
    Spyglass_RegisterAdminCommand("spyglass_refreshsanctions", Spyglass_AdminRefreshSanctions);
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
    foreach (entity player in GetPlayerArray())
    {
        Spyglass_SayPrivate(caller, format("%s: %s", Spyglass_FriendlyColor(player.GetPlayerName()), player.GetUID()));
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