/**
 * The sanction manager handles querying and applying sanctions from the API. 
 * It caches sanctions and refreshes them when needed. 
 */

global function Spyglass_IsPlayerInSanctionCache;
global function Spyglass_GetCachedPlayerSanctions;
global function Spyglass_IsSanctionInCache;
global function Spyglass_GetCachedSanction;
global function Spyglass_RefreshAllPlayerSanctions;

// TODO: Custom callback for sanctions

// List of player UIDs with ongoing sanction queries.
array<string> Spyglass_OngoingSanctionQueries;
// Callbacks for player sanction queries. 
table<string, array<Spyglass_SanctionSearchResult> > Spyglass_SanctionQueryCallbacks;
// Table containing the cached sanctions for player UIDs.
table<string, array<Spyglass_PlayerInfraction> > Spyglass_CachedPlayerSanctions;
// Table containing the cached sanctions from their ids.
table<int, Spyglass_PlayerInfraction> Spyglass_CachedSanctions;

/**
 * Whether or not the given uid is in the player sanction cache. 
 * @param uid The unique id of the player to look for in the cache. 
 * @returns True if we have the player's sanctions in cache.
 */
bool function Spyglass_IsPlayerInSanctionCache(string uid)
{
    return uid in Spyglass_CachedPlayerSanctions;
}

/**
 * Returns the cached sanctions for the given player uid.
 * Check if the sanctions are cached first using Spyglass_IsPlayerInSanctionCache()!
 * @returns An array of the player's sanctions if any, or an empty array if the player has none.
 */
array<Spyglass_PlayerInfraction> function Spyglass_GetCachedPlayerSanctions(string uid)
{
    if (!Spyglass_IsPlayerInSanctionCache(uid))
    {
        throw "Cannot get cached player sanctions: uid not in sanction cache.";
    }

    return clone Spyglass_CachedPlayerSanctions[uid]; 
}

/**
 * Whether or not the given sanction id is in the sanction cache. 
 * @param id The unique id of the sanction to look for in the cache. 
 * @returns True if we have the sanction in cache.
 */
bool function Spyglass_IsSanctionInCache(int id)
{
    return id in Spyglass_CachedSanctions;
}

/**
 * Returns the cached sanction with the given id.
 * Check if the sanction is cached first using Spyglass_IsSanctionInCache()!
 * @returns The cached sanction with the given id.
 */
Spyglass_PlayerInfraction function Spyglass_GetCachedSanction(int id)
{
    if (!Spyglass_IsSanctionInCache(id))
    {
        throw "Cannot get cached sanction: id not in sanction cache.";
    }

    return clone Spyglass_CachedSanctions[id];
}

void function Spyglass_UpdateSanctions(Spyglass_SanctionSearchResult result)
{
    // Remove cached sanctions for players that returned no sanctions.
    foreach (string uid in result.UniqueIDs)
    {
        if (!(uid in result.Matches))
        {
            if (uid in Spyglass_CachedPlayerSanctions)
            {
                // Clear all sanctions with that id.
                foreach (Spyglass_PlayerInfraction sanction in Spyglass_CachedPlayerSanctions[uid])
                {
                    if (sanction.ID in Spyglass_CachedSanctions)
                    {
                        delete Spyglass_CachedSanctions[sanction.ID];
                    }
                }

                Spyglass_CachedPlayerSanctions[uid] = [];
            }
            else
            {
                Spyglass_CachedPlayerSanctions[uid] <- [];
            }
        }
    }

    // Update sanctions that differ from the currently known ones.
    foreach (string uid, array<Spyglass_PlayerInfraction> sanctions in result.Matches)
    {

    }
}

void function Spyglass_OnPlayerSanctionsRefreshed(Spyglass_SanctionSearchResult result)
{
    if (!result.ApiResult.Success)
    {
        Spyglass_SayAll(format("Failed to refresh player sanctions: %s", result.ApiResult.Error));
        return;
    }

    Spyglass_UpdateSanctions(result);
}

/**
 * Queries the sanctions of all connected players in order to ensure they are up to date.
 * @param invalidateCache Whether or not to clear the local cache. Only set to true if you know what you're doing.
 */
bool function Spyglass_RefreshAllPlayerSanctions(bool invalidateCache = false)
{
    if (invalidateCache)
    {
        Spyglass_CachedPlayerSanctions = {};
        Spyglass_CachedSanctions = {};
    }

    array<string> uids = [];

    foreach (entity player in GetPlayerArray())
    {
        if (IsValid(player))
        {
            if (!Spyglass_HasImmunity(player))
            {
                uids.append(player.GetUID());
            }
        }
    }

    if (uids.len() == 0)
    {
        // Fire the callback with no matches to refresh our local cache if required.
        Spyglass_SanctionSearchResult result;
        result.ApiResult.Success = true;

        foreach (entity player in GetPlayerArray())
        {
            if (IsValid(player))
            {
                result.UniqueIDs.append(player.GetUID());
            }
        }

        Spyglass_OnPlayerSanctionsRefreshed(result);
        return true;
    }

    return SpyglassApi_QueryPlayerSanctions(uids, Spyglass_OnPlayerSanctionsRefreshed, GetConVarBool("spyglass_maintainers_are_admins"), false, false);
}