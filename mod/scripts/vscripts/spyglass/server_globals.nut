/**
 * This file holds globals and functions to access them.
 * Loaded first so all other files can access these when required.
 */

globalize_all_functions

/** List of authenticated maintainers. */
array<string> Spyglass_Maintainers = [];

/** List of players that finished connecting. */
array<string> Spyglass_ConnectedPlayers = [];

/** List of currently muted players. */
array<string> Spyglass_MutedPlayers = [];

/** List of admins that authenticated using the admin auth password. */
array<string> Spyglass_AuthenticatedPlayers = [];

/** Returns an array containing all authenticated maintainers. */
array<string> function Spyglass_GetMaintainers()
{
    return clone Spyglass_Maintainers;
}

/** Whether or not the given uid belongs to an authenticated maintainer. */
bool function Spyglass_IsMaintainer(string uid)
{
    return Spyglass_Maintainers.find(uid) != -1;
}

void function Spyglass_AddMaintainer(string uid)
{
    if (!Spyglass_IsMaintainer(uid))
    {
        Spyglass_Maintainers.append(uid);
    }
}

/** Removes the given uid from the authenticated maintainers list if it exists. */
void function Spyglass_RemoveMaintainer(string uid)
{
    int index = Spyglass_Maintainers.find(uid);
    if (index != -1)
    {
        Spyglass_Maintainers.remove(index);
    }
}

/** Returns an array containing all players that finished connecting. */
array<string> function Spyglass_GetConnectedPlayers()
{
    return clone Spyglass_ConnectedPlayers;
}

/** Whether or not the given uid belongs to an authenticated maintainer. */
bool function Spyglass_IsConnected(string uid)
{
    return Spyglass_ConnectedPlayers.find(uid) != -1;
}

/** Add a newly connected player to the array of connected players. */
void function Spyglass_AddConnectedPlayer(string uid)
{
    if (!Spyglass_IsConnected(uid))
    {
        Spyglass_ConnectedPlayers.append(uid);
    }
}

/** Removes the given uid from the list of connected players if it exists. */
void function Spyglass_RemoveConnectedPlayer(string uid)
{
    int index = Spyglass_ConnectedPlayers.find(uid);
    if (index != -1)
    {
        Spyglass_ConnectedPlayers.remove(index);
    }
}

/** Returns an array containing all players that are currently muted. */
array<string> function Spyglass_GetMutedPlayers()
{
    return clone Spyglass_MutedPlayers;
}

/** Checks whether or not the given player uid is currently muted. */
bool function Spyglass_IsMuted(string uid)
{
    return Spyglass_MutedPlayers.find(uid) != -1;
}

/** Add a muted player to the array of muted players. */
void function Spyglass_AddMutedPlayer(string uid)
{
    if (!Spyglass_IsMuted(uid))
    {
        Spyglass_MutedPlayers.append(uid);
    }
}

/** Removes the given uid from the list of muted players if it exists. */
void function Spyglass_RemoveMutedPlayer(string uid)
{
    int index = Spyglass_MutedPlayers.find(uid);
    if (index != -1)
    {
        Spyglass_MutedPlayers.remove(index);
    }
}

/** Empties the muted players array. */
void function Spyglass_EmptyMutedPlayers()
{
    Spyglass_MutedPlayers = [];
}

/** Returns true if the given player uid is an authenticated admin. */
bool function Spyglass_IsAuthenticated(string uid)
{
    return Spyglass_AuthenticatedPlayers.find(uid) != -1;
}

/** Adds the given uid to the list of authenticated players if they aren't in already. */
void function Spyglass_AddAuthenticatedPlayer(string uid)
{
    if (!Spyglass_IsAuthenticated(uid))
    {
        Spyglass_AuthenticatedPlayers.append(uid);
    }
}

/** Removes the given uid from the list of authenticated players if they in it. */
void function Spyglass_RemoveAuthenticatedPlayer(string uid)
{
    int index = Spyglass_AuthenticatedPlayers.find(uid);
    if (index != -1)
    {
        Spyglass_AuthenticatedPlayers.remove(index);
    }
}