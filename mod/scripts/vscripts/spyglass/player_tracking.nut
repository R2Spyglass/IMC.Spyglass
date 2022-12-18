global function Spyglass_TrackPlayers;

bool function Spyglass_TrackPlayers(array<entity> players, void functionref(Spyglass_ApiResult) callback = null)
{
    if (players.len() == 0)
    {
        return true;
    }

    // If there's no token, abort immediately.
    if (Spyglass_GetApiToken().len() != 0)
    {
        // However, if there is an authenticated maintainer, we can forward it to them so they can do it for us.
        foreach (entity player in GetPlayerArray())
        {
            if (IsValid(player) && Spyglass_IsMaintainer(player.GetUID()))
            {
                foreach (entity target in players)
                {
                    if (IsValid(target) && target.IsPlayer())
                    {
                        string cmd = format("spyglass_addplayeridentity %s %s", target.GetPlayerName(), target.GetUID());
                        ServerToClientStringCommand(player, cmd);
                    }
                }

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