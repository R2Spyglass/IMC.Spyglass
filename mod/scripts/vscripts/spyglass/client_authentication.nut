global function Spyglass_AuthenticationClientInit;

array<string> TrackedIdentities = [];
string Hostname = "";

void function Spyglass_AuthenticationClientInit()
{
    printt("[Spyglass] Spyglass_AuthenticationClientInit() called.");
    AddServerToClientStringCommandCallback("spyglass_beginauthflow", BeginAuthenticationFlow);
    AddServerToClientStringCommandCallback("spyglass_authenticated", OnAuthenticated);
    AddServerToClientStringCommandCallback("spyglass_authfailed", OnAuthenticationFailed);
    AddServerToClientStringCommandCallback("spyglass_addplayeridentity", OnAddPlayerIdentity);
    AddServerToClientStringCommandCallback("spyglass_removeplayeridentity", OnRemovePlayerIdentity);
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

    string enabled = strip(args[0]);
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

    if (!Spyglass_IsAuthenticated())
    {
        Spyglass_SetAuthenticated(true);
        Spyglass_ClientSay("Successfully authenticated with the server.");
    }
}

void function OnAuthenticationFailed(array<string> args)
{
    if (IsPlayingDemo())
    {
        return;
    }

    
}

void function OnAddPlayerIdentity(array<string> args)
{
    if (IsPlayingDemo())
    {
        printt("wut")
        return;
    }

    if (!Spyglass_IsAuthenticated())
    {
        printt("[Spyglass] Received spyglass_addplayeridentity while unauthenticated, aborting.");
        return;
    }

    if (args.len() < 2)
    {
        printt(format("[Spyglass] Invalid spyglass_addplayeridentity request: expected 2 args, got %i", args.len()));
        return;
    }

    string uid = strip(args[0]);
    string username = "";

    for (int i = 1; i < args.len(); i++)
    {
        username = format("%s%s ", username, args[i]);
    }

    username = strip(username);

    if (username.len() == 0 || uid.len() == 0)
    {
        printt(format("[Spyglass] Invalid spyglass_addplayeridentity request: invalid username '%i' or uid '%i'", username, uid));
        return;
    }

    Spyglass_AddPlayerIdentity(uid, username);
    printt(format("[Spyglass] Received player identity '%s' [%s] from server.", username, uid));
}

void function OnRemovePlayerIdentity(array<string> args)
{
    if (IsPlayingDemo())
    {
        return;
    }

    if (!Spyglass_IsAuthenticated())
    {
        printt("[Spyglass] Received spyglass_addplayeridentity while unauthenticated, aborting.");
        return;
    }

    if (args.len() != 1)
    {
        printt(format("[Spyglass] Invalid spyglass_removeplayeridentity request: expected 1 args, got %i", args.len()));
        return;
    }

    string uid = strip(args[0]);

    if (uid.len() == 0)
    {
        printt(format("[Spyglass] Invalid spyglass_removeplayeridentity request: invalid uid '%i'", uid));
        return;
    }

    Spyglass_RemovePlayerIdentity(uid);
    int foundIndex = TrackedIdentities.find(uid);
    if (foundIndex != -1)
    {
        TrackedIdentities.remove(foundIndex);
    }

    printt(format("[Spyglass] Removed player identity '%s' as requested by server.", uid));
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

    if (!Spyglass_IsAuthenticated())
    {
        printt("[Spyglass] Received spyglass_trackplayers while unauthenticated, aborting.");
        return;
    }

    Spyglass_PlayerTrackingData data;
    data.Hostname = Hostname;

    foreach (string uid, string username in Spyglass_GetPlayerIdentities())
    {
        if (TrackedIdentities.find(uid) != -1)
        {
            Spyglass_PlayerIdentity ident;
            ident.Username = username;
            ident.UniqueID = uid;

            data.Players.append(ident);
            TrackedIdentities.append(uid);
        }
    }

    if (data.Players.len() == 0)
    {
        printt("[Spyglass] Server called spyglass_trackplayers with no players. Aborting.");
        return;
    }

    if (SpyglassApi_TrackPlayers(data, OnTrackPlayersComplete))
    {
        Spyglass_ClientSay(format("Sending tracking data for %i %s to the API, on the server's behalf...", data.Players.len(), Spyglass_Pluralize("player", "players", data.Players.len())));
    }
    else
    {
        printt("[Spyglass] Failed to send tracking data on the server's behalf.");
    }
}
