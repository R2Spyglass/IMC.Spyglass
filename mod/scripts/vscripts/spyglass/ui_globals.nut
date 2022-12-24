globalize_all_functions

/** List of player identities sent from the server when authenticated. */
table<string, string> Spyglass_PlayerIdentities = {};

/** Whether or not we're currently authenticated with the Spyglass API. */
bool IsAuthenticated = false;

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

/** Resets player identities to an empty table. */
void function SpyglassUI_ResetPlayerIdentities()
{
    Spyglass_PlayerIdentities = {};
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

/** Returns whether or not we're currently authenticated with the Spyglass API. */
bool function SpyglassUI_IsAuthenticated()
{
    return IsAuthenticated;
}

/** Sets whether or not we're currently authenticated. */
bool function SpyglassUI_SetAuthenticated(bool isAuthenticated)
{
    IsAuthenticated = isAuthenticated;
}