globalize_all_functions
/** List of player identities sent from the server when authenticated. */
table<string, string> Spyglass_PlayerIdentities = {};

/** Add a player name and uid to the identity table. */
void function SpyglassUI_AddPlayerIdentity(string uid, string username)
{
    if (!(uid in Spyglass_PlayerIdentities))
    {
        Spyglass_PlayerIdentities[uid] <- username
    }
    else
    {
        Spyglass_PlayerIdentities[uid] = username
    }
}

/** Remove a player name and uid to the identity table. */
void function SpyglassUI_RemovePlayerIdentity(string uid)
{
    if (uid in Spyglass_PlayerIdentities)
    {
        delete Spyglass_PlayerIdentities[uid];
    }
}

/** Returns all player identities. */
table<string, string> function SpyglassUI_GetPlayerIdentities()
{
    return Spyglass_PlayerIdentities;
}

/** Whether or not we have the identity of the player with the given uid. */
bool function SpyglassUI_HasIdentity(string uid)
{
    return uid in Spyglass_PlayerIdentities;
}

/** Returns the name of the player with the given uid, if we have it. */
string function SpyglassUI_GetPlayerName(string uid)
{
    if (SpyglassUI_HasIdentity(uid))
    {
        return Spyglass_PlayerIdentities[uid];
    }

    CodeWarning("[Spyglass] Attempted to get player identity of unknown player. Use SpyglassUI_HasIdentity() first!");
    return "";
}