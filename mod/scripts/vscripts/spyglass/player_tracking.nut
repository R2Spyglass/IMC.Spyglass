global function Spyglass_TrackPlayers;
global function Spyglass_TransmitPlayerIdentities;
global function Spyglass_RemovePlayerIdentities;

bool function Spyglass_TrackPlayers(array<entity> players, void functionref(Spyglass_ApiResult) callback = null)
{
    if (players.len() == 0)
    {
        return true;
    }

    // If there's no token, abort immediately.
    if (Spyglass_GetApiToken().len() == 0)
    {
        // However, if there is an authenticated maintainer, we can forward it to them so they can do it for us.
        foreach (entity player in GetPlayerArray())
        {
            if (IsValid(player) && Spyglass_IsMaintainer(player.GetUID()))
            {
                printt("[Spyglass] Sending tracking data to authenticated maintainer.");
                ServerToClientStringCommand(player, "spyglass_trackplayers");
                break;
            }
        }

        return false;
    }

    Spyglass_PlayerTrackingData data;
    data.Hostname = strip(GetConVarString("ns_server_name"));

    foreach (entity player in players)
    {
        if (!IsValid(player) || !player.IsPlayer())
        {
            continue;
        }

        Spyglass_PlayerIdentity identity;
        identity.Username = player.GetPlayerName();
        identity.UniqueID = player.GetUID();

        data.Players.append(identity);
    }

    return SpyglassApi_TrackPlayers(data, callback);
}

/** Sends the uids and usernames of the given players to the target. Target must be a maintainer to receive them. */
void function Spyglass_TransmitPlayerIdentities(entity target, array<entity> players)
{
    if (!IsValid(target) || !target.IsPlayer() || players.len() == 0)
    {
        return;
    }

    printt(format("[Spyglass] Transmitting %i player identities to player '%s'.", players.len(), target.GetPlayerName()));
    foreach (entity player in players)
    {
        printt(player.GetPlayerName())
        if (IsValid(player) && player.IsPlayer())
        {
            string cmd = format("spyglass_addplayeridentity %s %s", player.GetUID(), player.GetPlayerName());
            ServerToClientStringCommand(target, cmd);
        }
    }
}

/** Sends the uids the given players to the target so they can remove it. Target must be a maintainer to receive them. */
void function Spyglass_RemovePlayerIdentities(entity target, array<entity> players)
{
    if (!IsValid(target) || !target.IsPlayer() || players.len() == 0)
    {
        return;
    }

    printt(format("[Spyglass] Transmitting %i player identity removal requests to player '%s'.", players.len(), target.GetPlayerName()));
    foreach (entity player in players)
    {
        if (IsValid(player) && player.IsPlayer())
        {
            string cmd = format("spyglass_removeplayeridentity %s", player.GetUID());
            ServerToClientStringCommand(target, cmd);
        }
    }
}