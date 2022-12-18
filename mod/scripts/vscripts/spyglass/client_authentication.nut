global function Spyglass_AuthenticationClientInit;

table<string, string> PlayerIdentities = {};
bool IsAuthenticated = false;
string Hostname = "";

void function Spyglass_AuthenticationClientInit()
{
    printt("[Spyglass] Spyglass_AuthenticationClientInit() called.");
    AddServerToClientStringCommandCallback("spyglass_beginauthflow", BeginAuthenticationFlow);
    AddServerToClientStringCommandCallback("spyglass_authenticated", OnAuthenticated);
    AddServerToClientStringCommandCallback("spyglass_addplayeridentity", OnAddPlayerIdentity);
    AddServerToClientStringCommandCallback("spyglass_trackplayers", OnTrackPlayerRequest);
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
    if (IsPlayingDemo())
    {
        return;
    }

    if (args.len() == 0)
    {
        printt("[Spyglass] spyglass_beginauthflow received from the server with no args. Ignoring.");
        return;
    }

    if (args.len() < 2)
    {
        printt(format("[Spyglass] spyglass_beginauthflow started with invalid number of arguments, expected at least 2, got %i.", args.len()));
        return;
    }

    string enabled = args[0];
    string hostname = "";

    for (int i = 1; i < args.len(); i++)
    {
        hostname = format("%s%s ", hostname, args[i]);
    }

    Hostname = strip(hostname);

    if (enabled != "true")
    {
        Spyglass_ClientSay("The server has disabled authentication for maintainers.");
        return;
    }

    printt("[Spyglass] Server requested we begin authentication flow.");
    Spyglass_ClientSay("Requesting authentication ticket from API...");
    Spyglass_ClientSay(format("Hostname: %s", Hostname));

    if (!SpyglassApi_RequestAuthenticationTicket(OnAuthenticationTicketReceived))
    {
        Spyglass_ClientSayError("Failed to start authentication ticket request, check console for more information.");
    }
}

void function OnAuthenticated(array<string> args)
{
    if (IsPlayingDemo())
    {
        return;
    }

    if (!IsAuthenticated)
    {
        IsAuthenticated = true;
        Spyglass_ClientSay("Successfully authenticated with the server.");
    }
}

void function OnAddPlayerIdentity(array<string> args)
{
    if (IsPlayingDemo())
    {
        return;
    }

    if (!IsAuthenticated)
    {
        printt("[Spyglass] Received spyglass_addplayeridentity while unauthenticated, aborting.");
        return;
    }

    if (args.len() != 2)
    {
        printt(format("[Spyglass] Invalid spyglass_addplayeridentity request: expected 2 args, got %i", args.len()));
        return;
    }

    string username = strip(args[0]);
    string uid = strip(args[1]);

    if (username.len() == 0 || uid.len() == 0)
    {
        printt(format("[Spyglass] Invalid spyglass_addplayeridentity request: invalid username '%i' or uid '%i'", username, uid));
        return;
    }

    if (uid in PlayerIdentities)
    {
        PlayerIdentities[uid] = username;
    }
    else
    {
        PlayerIdentities[uid] <- username;
    }

    printt(format("[Spyglass] Received player identity '%s' [%s] from server.", username, uid));
}

void function OnTrackPlayersComplete(Spyglass_ApiResult result)
{
    if (result.Success)
    {
        printt("[Spyglass] Tracking successful.")
    }
    else
    {
        Spyglass_ClientSayError(format("Failed to track players with error: %s", result.Error));
    }
}

// The server requested we track a player as a maintainer.
void function OnTrackPlayerRequest(array<string> args)
{
    if (IsPlayingDemo())
    {
        return;
    }

    if (!IsAuthenticated)
    {
        printt("[Spyglass] Received spyglass_trackplayers while unauthenticated, aborting.");
        return;
    }

    Spyglass_PlayerTrackingData data;
    data.Hostname = Hostname;

    foreach (string uid, string username in PlayerIdentities)
    {
        Spyglass_PlayerIdentity ident;
        ident.Username = username;
        ident.UniqueID = uid;

        data.Players.append(ident);
    }

    if (data.Players.len() == 0)
    {
        printt("[Spyglass] Server called spyglass_trackplayers with no players. Aborting.");
        return;
    }

    if (SpyglassApi_TrackPlayers(data, OnTrackPlayersComplete))
    {
        Spyglass_ClientSay(format("Sending tracking data for %i players to the API, on the server's behalf...", data.Players.len()));
    }
    else
    {
        printt("[Spyglass] Failed to send tracking data on the server's behalf.");
    }

    PlayerIdentities = {};
}
