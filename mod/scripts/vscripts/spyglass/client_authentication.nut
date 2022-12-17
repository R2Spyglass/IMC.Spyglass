global function Spyglass_AuthenticationClientInit;

void function Spyglass_AuthenticationClientInit()
{
    printt("[Spyglass] Spyglass_AuthenticationClientInit() called.");
    AddServerToClientStringCommandCallback("spyglass_beginauthflow", BeginAuthenticationFlow);
}

void function OnAuthenticationTicketReceived(Spyglass_MaintainerAuthenticationResult result)
{
    if (!result.ApiResult.Success)
    {
        Spyglass_ClientSayError(format("Authentication ticket request failed with error: %s", result.ApiResult.Error));
        return;
    }

    if (result.Ticket == null)
    {
        Spyglass_ClientSayError("Authentication ticket is null, check for parsing errors.");
        return;
    }

    Spyglass_MaintainerAuthenticationTicket ticket = expect Spyglass_MaintainerAuthenticationTicket(result.Ticket);

    Spyglass_ClientSay("Authentication ticket received, transmitting to server.");
    GetLocalClientPlayer().ClientCommand(format("spyglass_validateauthtoken \"%s\"", ticket.Token));
}

void function BeginAuthenticationFlow(array<string> args)
{
    if (IsWatchingReplay() || IsPlayingDemo())
    {
        return;
    }

    printt("[Spyglass] Server requested we begin authentication flow.");
    Spyglass_ClientSay("Requesting authentication ticket from API...");

    if (!SpyglassApi_RequestAuthenticationTicket(OnAuthenticationTicketReceived))
    {
        Spyglass_ClientSayError("Failed to start authentication ticket request, check console for more information.");
    }
}
