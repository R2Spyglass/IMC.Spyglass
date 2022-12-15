/**
 * The sanction manager handles querying and applying sanctions from the API. 
 * It caches sanctions and refreshes them when needed. 
 */

global function Spyglass_IsPlayerInSanctionCache;
global function Spyglass_GetCachedPlayerSanctions;
global function Spyglass_IsSanctionInCache;
global function Spyglass_GetCachedSanction;
global function Spyglass_RefreshAllPlayerSanctions;

global function Spyglass_AddPlayerSanctionOverrideCallback;
global function Spyglass_AddOnPlayerSanctionAppliedCallback;

global function Spyglass_IsPlayerMuted;
global function Spyglass_IsPlayerBanned;

// TODO: Custom callback for sanctions

/** List of player UIDs with ongoing sanction queries. */
array<string> Spyglass_OngoingSanctionQueries;
/** Callbacks for player sanction queries. */
table<string, array<Spyglass_SanctionSearchResult> > Spyglass_SanctionQueryCallbacks; 
/** Table containing the cached sanctions for player UIDs. */
table<string, array<Spyglass_PlayerInfraction> > Spyglass_CachedPlayerSanctions;
/** Table containing the cached sanctions from their ids. */
table<int, Spyglass_PlayerInfraction> Spyglass_CachedSanctions;

/** List of sanctions that were already applied and shouldn't have global chat notifications again. */
array<int> Spyglass_AppliedSanctionCache;

/** List of callbacks to override handling of player sanctions. */
array<int functionref(entity, Spyglass_PlayerInfraction)> Spyglass_PlayerSanctionOverrideCallbacks;
/** List of callbacks to run when a player sanction is applied. */
array<void functionref(entity, Spyglass_PlayerInfraction)> Spyglass_OnPlayerSanctionAppliedCallbacks;

/** List of currently muted players. */
array<string> Spyglass_MutedPlayers;

/** List of currently banned players. */
table<string, string> Spyglass_BannedPlayers;

/** 
 * Add a callback that lets you manually handle player sanctions.
 * Signature: Spyglass_SanctionOverrideResult function (entity player, Spyglass_PlayerInfraction infraction)
 * Check models.nut:Spyglass_SanctionOverrideResult's documentation for more information on valid values.
 */
void function Spyglass_AddPlayerSanctionOverrideCallback(int functionref(entity, Spyglass_PlayerInfraction) callback)
{
    if (callback != null)
    {
        Spyglass_PlayerSanctionOverrideCallbacks.append(callback);
    }
}

/** 
 * Add a callback to execute when a player sanction is applied.
 * Signature: bool function (entity player, Spyglass_PlayerInfraction infraction)
 * You should return true to prevent any further handling of the sanction by Spyglass or other callbacks.
 * Avoid doing so to improve compatibility with other mods.
 */
void function Spyglass_AddOnPlayerSanctionAppliedCallback(void functionref(entity, Spyglass_PlayerInfraction) callback)
{
    if (callback != null)
    {
        Spyglass_OnPlayerSanctionAppliedCallbacks.append(callback);
    }
}

/** 
 * Calls all valid callbacks in Spyglass_OnPlayerSanctionAppliedCallbacks with the given player and sanction.
 */
void function Spyglass_CallOnPlayerSanctionAppliedCallbacks(entity player, Spyglass_PlayerInfraction sanction)
{
    foreach (void functionref(entity, Spyglass_PlayerInfraction) callback in Spyglass_OnPlayerSanctionAppliedCallbacks)
    {
        if (callback != null)
        {
            callback(player, sanction);
        }
    }
}

/** 
 * Calls all valid callbacks in Spyglass_PlayerSanctionOverrideCallbacks with the given player and sanction.
 * If any callback doesn't return Spyglass_SanctionOverrideResult.Unhandled, it'll halt execution of further callbacks and return the result.
 */
int function Spyglass_CallPlayerSanctionOverrideCallbacks(entity player, Spyglass_PlayerInfraction sanction)
{
    foreach (int functionref(entity, Spyglass_PlayerInfraction) callback in Spyglass_PlayerSanctionOverrideCallbacks)
    {
        if (callback != null)
        {
            int result = callback(player, sanction);
            
            switch (result)
            {
                case Spyglass_SanctionOverrideResult.Unhandled:
                    break;
                case Spyglass_SanctionOverrideResult.Ignored:
                case Spyglass_SanctionOverrideResult.AppliedSanction:
                    return result;
                default: 
                    CodeWarning(format("[Spyglass] PlayerSanctionOverrideCallback returned invalid result '%i'.", result));
                    break;
            }
        }
    }

    return Spyglass_SanctionOverrideResult.Unhandled;
}

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

/**
 * Updates the local cache with the given sanction query result from the API.
 * Returns a table of uid -> list of new sanctions to apply.
 */
table<string, array<Spyglass_PlayerInfraction> > function Spyglass_UpdateSanctions(Spyglass_SanctionSearchResult result)
{
    table<string, array<Spyglass_PlayerInfraction> > deltaSanctions = {};

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

    if (result.Matches.len() == 0)
    {
        return {};
    }

    // Update sanctions that differ from the currently known ones.
    foreach (string uid, array<Spyglass_PlayerInfraction> sanctions in result.Matches)
    {
        array<Spyglass_PlayerInfraction> newSanctions = [];

        foreach (Spyglass_PlayerInfraction sanction in sanctions)
        {
            if (!Spyglass_IsSanctionInCache(sanction.ID))
            {
                newSanctions.append(sanction);

                Spyglass_CachedSanctions[sanction.ID] <- sanction;
            }
        }

        // Sort sanctions by id.
        sanctions.sort(int function (Spyglass_PlayerInfraction first, Spyglass_PlayerInfraction second)
        {
            if (first.ID > second.ID)
            {
                return -1;
            }

            return 1;
        });
        
        if (!(uid in Spyglass_CachedPlayerSanctions))
        {
            Spyglass_CachedPlayerSanctions[uid] <- sanctions;
        }
        else
        {
            Spyglass_CachedPlayerSanctions[uid] = sanctions;
        }

        // Sort sanctions to apply those with a higher punishment first.
        // For equal punishment, apply the newest sanctions first.
        newSanctions.sort(int function (Spyglass_PlayerInfraction first, Spyglass_PlayerInfraction second)
        {
            if (first.PunishmentType > second.PunishmentType)
            {
                return -1;
            }
            else if (first.PunishmentType == second.PunishmentType)
            {
                if (first.ID > second.ID)
                {
                    return -1;
                }
                else
                {
                    return 1;
                }
            }

            return 1;
        });

        if (newSanctions.len() != 0)
        {
            deltaSanctions[uid] <- newSanctions;
        }
    }

    return deltaSanctions;
}

/**
 * Applies the sanction to the given player.
 * @param player The player to apply the sanction to (must match the sanction's player uid.)
 * @param sanction The sanction to apply to the player.
 * @returns True if the player has been disconnected from the server and no other sanction processing should be done.
 */
bool function Spyglass_ApplySanction(entity player, Spyglass_PlayerInfraction sanction)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        CodeWarning("[Spyglass] Attempted to sanction null or non-player entity!");
        return false;
    }

    if (Spyglass_HasImmunity(player))
    {
        CodeWarning(format("[Spyglass] Attempted to sanction player '%s', but they have immunity!", player.GetPlayerName()));
        return false;
    }

    switch (sanction.PunishmentType)
    {
        case Spyglass_SanctionType.Warn: 
            return false;
        case Spyglass_SanctionType.Mute:
            Spyglass_MutePlayer(player);
            return false;
        case Spyglass_SanctionType.Ban:
            return Spyglass_BanPlayer(player, Spyglass_GetInfractionAsString(sanction, true));
    }

    CodeWarning(format("[Spyglass] Attempted to sanction player '%s' with unknown punishment type '%i'.", player.GetPlayerName(), sanction.PunishmentType));
    return false;
}

void function Spyglass_OnPlayerSanctionsRefreshed(Spyglass_SanctionSearchResult result)
{
    if (!result.ApiResult.Success)
    {
        Spyglass_SayAll(format("Failed to refresh player sanctions: %s", result.ApiResult.Error));
        return;
    }

    printt(format("[Spyglass] Player sanctions refreshed successfully, received %i matches.", result.Matches.len()));

    table<string, array<Spyglass_PlayerInfraction> > deltaSanctions = Spyglass_UpdateSanctions(result);
    
    foreach (entity player in GetPlayerArray())
    {
        if (!IsValid(player) || !(player.GetUID() in deltaSanctions) || Spyglass_HasImmunity(player))
        {
            continue;
        }

        string playerName = player.GetPlayerName();

        array<Spyglass_PlayerInfraction> appliedSanctions = [];

        foreach (Spyglass_PlayerInfraction sanction in deltaSanctions[player.GetUID()])
        {
            int result = Spyglass_CallPlayerSanctionOverrideCallbacks(player, clone sanction);
            
            if (result == Spyglass_SanctionOverrideResult.Unhandled)
            {
                bool disconnected = Spyglass_ApplySanction(player, sanction);
                appliedSanctions.append(sanction);

                if (disconnected)
                {
                    break;
                }
            }
            else if (result == Spyglass_SanctionOverrideResult.AppliedSanction)
            {
                Spyglass_CallOnPlayerSanctionAppliedCallbacks(player, clone sanction);
                appliedSanctions.append(sanction);
            }
        }

        if (appliedSanctions.len() != 0)
        {
            Spyglass_ChatSendPlayerInfractions(playerName, appliedSanctions, GetPlayerArray());
        }

        // TODO: Re-enable if this is fixed: https://github.com/R2Northstar/NorthstarMods/issues/524
        // if (IsValid(player))
        // {
        //     if (GetGameState() >= eGameState.Playing)
        //     {
        //         NSSendAnnouncementMessageToPlayer(player, "Sanction Applied", "Check chat for more information.", <1,0,0>, 1, 1);
        //     }
        //     else
        //     {
        //         void functionref() announcement = void function() : (player)
        //         {
        //             if (IsValid(player))
        //             {
        //                 NSSendAnnouncementMessageToPlayer(player, "Sanction Applied", "Check chat for more information.", <1,0,0>, 1, 1);
        //             }
        //         }

        //         AddCallback_GameStateEnter(eGameState.Playing, announcement);
        //     }
        // }
    }
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
        Spyglass_AppliedSanctionCache = [];
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

/** Checks whether or not the given player uid is currently muted. */
bool function Spyglass_IsPlayerMuted(string uid)
{
    return Spyglass_MutedPlayers.find(uid) != -1;
}

/** Checks whether or not the given player uid is banned, and has attempted to join the server this map. */
bool function Spyglass_IsPlayerBanned(string uid)
{
    return uid in Spyglass_BannedPlayers;
}

/** Mutes the given player. They won't be able to type in chat anymore. */
void function Spyglass_MutePlayer(entity player)
{
    if (IsValid(player) && player.IsPlayer())
    {
        if (!Spyglass_IsPlayerMuted(player.GetUID()))
        {
            Spyglass_MutedPlayers.append(player.GetUID());
        }
    }
}

/** Bans the given player, disconnecting them from the game with the given reason. */
bool function Spyglass_BanPlayer(entity player, string reason)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        CodeWarning(format("[Spyglass] Attempted to ban null or non-player entity."));
        return false;
    }

    printt(format("[Spyglass] Banned player '%s' [%s] with reason: %s", player.GetPlayerName(), player.GetUID(), reason));

    if (Spyglass_IsPlayerBanned(player.GetUID()))
    {
        Spyglass_BannedPlayers[player.GetUID()] = reason;
    }
    else
    {
        Spyglass_BannedPlayers[player.GetUID()] <- reason;
    }

    if (GetConVarBool("spyglass_use_banlist_for_bans"))
    {
        ServerCommand(format("ban %s", player.GetUID()));
    }
    else
    {
        //ClientCommand(player, format("disconnect \"%s\"", reason));
        ServerCommand(format("kick %s", player.GetPlayerName()));
    }

    return true;
}