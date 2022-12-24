globalize_all_functions

/** List of player identities sent from the server when authenticated. */
table<string, string> Spyglass_PlayerIdentities = {};

/** Whether or not we're currently authenticated with the Spyglass API. */
bool IsAuthenticated = false;

/** Add a player name and uid to the identity table. */
void function Spyglass_AddPlayerIdentity(string uid, string username)
{
    RunUIScript("SpyglassUI_AddPlayerIdentity", uid, username);
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
void function Spyglass_RemovePlayerIdentity(string uid)
{
    RunUIScript("SpyglassUI_RemovePlayerIdentity", uid);

    if (uid in Spyglass_PlayerIdentities)
    {
        delete Spyglass_PlayerIdentities[uid];
    }
}

/** Returns all player identities. */
table<string, string> function Spyglass_GetPlayerIdentities()
{
    return Spyglass_PlayerIdentities;
}

/** Whether or not we have the identity of the player with the given uid. */
bool function Spyglass_HasIdentity(string uid)
{
    return uid in Spyglass_PlayerIdentities;
}

/** Returns the name of the player with the given uid, if we have it. */
string function Spyglass_GetPlayerName(string uid)
{
    if (Spyglass_HasIdentity(uid))
    {
        return Spyglass_PlayerIdentities[uid];
    }

    CodeWarning("[Spyglass] Attempted to get player identity of unknown player. Use Spyglass_HasIdentity() first!");
    return "";
}

/** Returns whether or not we're currently authenticated with the Spyglass API. */
bool function Spyglass_IsAuthenticated()
{
    return IsAuthenticated;
}

/** Sets whether or not we're currently authenticated. */
bool function Spyglass_SetAuthenticated(bool isAuthenticated)
{
    if (IsAuthenticated != isAuthenticated)
    {
        IsAuthenticated = isAuthenticated;
        RunUIScript("SpyglassUI_SetAuthenticated", isAuthenticated);
    }
}