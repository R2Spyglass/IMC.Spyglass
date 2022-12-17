global function Spyglass_AuthenticationServerInit;
global function Spyglass_IsMaintainer;

array<string> Spyglass_Maintainers = [];

void function Spyglass_AuthenticationServerInit()
{
    printt("[Spyglass] Spyglass_AuthenticationServerInit() called.");
    AddClientCommandCallback("spyglass_authenticate", OnReceiveAuthenticationRequest)
    AddClientCommandCallback("spyglass_validateauthtoken", OnAuthenticationTokenValidationRequested);
}

/** Returns true if the given player is an authenticated maintainer. */
bool function Spyglass_IsMaintainer(entity player)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        return false;
    }

    return Spyglass_Maintainers.find(player.GetUID()) != -1;
}

void function OnAuthenticationTokenValidationComplete(string uniqueId, Spyglass_MaintainerTicketValidationResult result)
{
    if (!GetConVarBool("spyglass_maintainers_are_admins"))
    {
        return;
    }

    entity target = null;

    foreach (entity player in GetPlayerArray())
    {
        if (IsValid(player) && player.GetUID() == uniqueId)
        {
            target = player;
            break;
        }
    }

    if (target == null)
    {
        return;
    }

    if (Spyglass_IsMaintainer(target))
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

    Spyglass_Maintainers.append(target.GetUID());
    Spyglass_SayAll(format("Administrator %s has authenticated with the Spyglass API.", Spyglass_FriendlyColor(target.GetPlayerName())));
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
    
    if (Spyglass_IsMaintainer(player))
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

    if (!GetConVarBool("spyglass_maintainers_are_admins"))
    {
        Spyglass_SayPrivate(player, "This server has disabled administration for maintainers.");
        return true;
    }
    
    if (Spyglass_IsMaintainer(player))
    {
        Spyglass_SayPrivate(player, format("You are already authenticated, %s.", Spyglass_FriendlyColor(player.GetPlayerName())));
        return true;
    }

    ServerToClientStringCommand(player, "spyglass_beginauthflow");
    return true;
}