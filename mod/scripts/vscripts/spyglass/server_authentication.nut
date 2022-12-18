global function Spyglass_AuthenticationServerInit;
global function Spyglass_AuthenticationServerInitAfter;

void function Spyglass_AuthenticationServerInit()
{
    printt("[Spyglass] Spyglass_AuthenticationServerInit() called.");
    AddClientCommandCallback("spyglass_authenticate", OnReceiveAuthenticationRequest)
    AddClientCommandCallback("spyglass_validateauthtoken", OnAuthenticationTokenValidationRequested);
}

void function Spyglass_AuthenticationServerInitAfter()
{
    printt("[Spyglass] Spyglass_AuthenticationServerInitAfter() called.");

    AddCallback_OnClientDisconnected(OnClientDisconnected);
}

void function OnClientDisconnected(entity player)
{
    if (IsValid(player) && player.IsPlayer())
    {
        Spyglass_RemoveMaintainer(player.GetUID());
        Spyglass_RemoveAuthenticatedPlayer(player.GetUID());
    }
}

void function OnAuthenticationTokenValidationComplete(string uniqueId, Spyglass_MaintainerTicketValidationResult result)
{
    if (!GetConVarBool("spyglass_maintainers_are_admins"))
    {
        return;
    }

    entity target = Spyglass_GetPlayerByUID(uniqueId);

    if (target == null)
    {
        return;
    }

    if (Spyglass_IsMaintainer(target.GetUID()))
    {
        return;
    }

    if (!result.ApiResult.Success)
    {
        Spyglass_SayPrivate(target, format("Failed to validate authentication token with error: %s", result.ApiResult.Error));
        return;
    }

    if (!result.IsValid)
    {
        Spyglass_SayPrivate(target, "The backend rejected your authentication token, please try again later.");
        return;
    }

    Spyglass_AddMaintainer(target.GetUID());
    Spyglass_SayAll(format("Administrator %s has authenticated with the Spyglass API.", Spyglass_FriendlyColor(target.GetPlayerName())));
    ServerToClientStringCommand(target, "spyglass_authenticated");

    if (Spyglass_GetApiToken().len() != 0)
    {
        Spyglass_TrackPlayers(GetPlayerArray());
    }
}

bool function OnAuthenticationTokenValidationRequested(entity player, array<string> args)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        return false;
    }

    // Nice attempt at exploiting, goodbye.
    if (!GetConVarBool("spyglass_maintainers_are_admins"))
    {
        ServerCommand(format("kick %s", player.GetPlayerName()));
        return false;
    }
    
    if (Spyglass_IsMaintainer(player.GetUID()))
    {
        return false;
    }

    if (args.len() == 0)
    {
        Spyglass_SayPrivate(player, "Invalid arguments for spyglass_validateauthtoken.");
        return true;
    }

    string token = strip(args[0]);
    string uniqueId = player.GetUID();

    Spyglass_SayPrivate(player, format("Validating authentication token for %s [%s]...", Spyglass_FriendlyColor(player.GetPlayerName()), uniqueId));

    void functionref(Spyglass_MaintainerTicketValidationResult) func = void function (Spyglass_MaintainerTicketValidationResult result) : (uniqueId)
    {
        OnAuthenticationTokenValidationComplete(uniqueId, result);
    }

    if (!SpyglassApi_ValidateAuthenticationToken(uniqueId, token, func))
    {
        Spyglass_SayPrivate(player, "Failed to start authentication token validation.");
    }

    return true;
}

bool function OnReceiveAuthenticationRequest(entity player, array<string> args)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        return false;
    }

    // If the player is an admin, and they're not authenticated, check if they gave a password.
    if (Spyglass_IsAdmin(player))
    {
        if (Spyglass_IsAuthenticated(player.GetUID()) || Spyglass_IsMaintainer(player.GetUID()))
        {
            Spyglass_SayPrivate(player, format("You are already authenticated, %s.", Spyglass_FriendlyColor(player.GetPlayerName())));
            return true;
        }

        string authPassword = strip(GetConVarString("spyglass_admin_auth_password"));
        if (authPassword.len() == 0)
        {
            Spyglass_SayPrivate(player, "Cannot authenticate: server is missing an admin auth password, please configure one first.");
            return true;
        }

        if (args.len() == 0)
        {
            Spyglass_SayPrivate(player, "Cannot authenticate: missing password.");
            return true;
        }

        string password = strip(args[0]);

        if (authPassword == password)
        {
            Spyglass_AddAuthenticatedPlayer(player.GetUID());
            Spyglass_SayAll(format("Administrator %s has authenticated.", Spyglass_FriendlyColor(player.GetPlayerName())));
        }
        else
        {
            Spyglass_SayPrivate(player, "Authentication failed: wrong password.");
        }

        return true;
    }

    if (GetConVarBool("spyglass_maintainers_are_admins"))
    {
        ServerToClientStringCommand(player, format("spyglass_beginauthflow true %s", GetConVarString("ns_server_name")));
    }
    else
    {
        ServerToClientStringCommand(player, format("spyglass_beginauthflow false %s", GetConVarString("ns_server_name")));
    }

    return true;
}