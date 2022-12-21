/**
 * The sanction manager handles querying and applying sanctions from the API. 
 * It caches sanctions and refreshes them when needed. 
 */

global function Spyglass_InitSanctionManager;

global function Spyglass_IsPlayerInSanctionCache;
global function Spyglass_GetCachedPlayerSanctions;
global function Spyglass_IsSanctionInCache;
global function Spyglass_GetCachedSanction;
global function Spyglass_RefreshAllPlayerSanctions;

global function Spyglass_AddPlayerSanctionOverrideCallback;
global function Spyglass_AddOnPlayerSanctionAppliedCallback;

global function Spyglass_IsPlayerBanned;

/** List of player UIDs with ongoing sanction queries. */
array<string> Spyglass_OngoingSanctionQueries;
/** Callbacks for player sanction queries. */
table<string, array<Spyglass_SanctionSearchResult> > Spyglass_SanctionQueryCallbacks; 
/** Table containing the cached sanctions for player UIDs. */
table<string, array<Spyglass_PlayerInfraction> > Spyglass_CachedPlayerSanctions;
/** Table containing the cached sanctions from their ids. */
table<int, Spyglass_PlayerInfraction> Spyglass_CachedSanctions;

/** List of sanctions that were already applied and shouldn't have global chat notifications again. */
table<int, bool> Spyglass_NotifiedSanctionCache;
/** List of sanctions to notify the server when a player finishes connecting. */
table<string, array<Spyglass_PlayerInfraction> > Spyglass_OnConnectNotification;

/** List of callbacks to override handling of player sanctions. */
array<int functionref(entity, Spyglass_PlayerInfraction)> Spyglass_PlayerSanctionOverrideCallbacks;
/** List of callbacks to run when a player sanction is applied. */
array<void functionref(entity, Spyglass_PlayerInfraction)> Spyglass_OnPlayerSanctionAppliedCallbacks;

bool Spyglass_IsRefreshingSanctions = false;

/** List of currently banned players. */
table<string, string> Spyglass_BannedPlayers;

void function Spyglass_InitSanctionManager()
{
    printt("[Spyglass] Spyglass_InitSanctionManager() called.");
    AddCallback_OnClientConnecting(OnClientConnecting);
    AddCallback_OnClientConnected(OnClientConnected);
    AddCallback_OnClientDisconnected(OnClientDisconnected);

    // Apply muted players from the cache so we keep them muted until we refresh their sanctions.
    Spyglass_ApplyMutedPlayersCache();
    Spyglass_ApplyConnectedPlayersCache();
}

/**
 * Callbacks
 */

/** Prevent banned players from connecting. */
void function OnClientConnecting(entity player)
{
    if (Spyglass_IsDisabled())
    {
        return;
    }

    if (!IsValid(player) || !player.IsPlayer())
    {
        return;
    }

    // Add the player's entity to a connecting array as connecting players do not appear in GetPlayerArray().
    Spyglass_AddConnectingPlayer(player);

    if (Spyglass_HasImmunity(player))
    {
        return;
    }

    if (Spyglass_IsPlayerBanned(player.GetUID()))
    {
        if (GetConVarBool("spyglass_use_banlist_for_bans"))
        {
            ServerCommand(format("ban %s", player.GetUID()));
        }
        else
        {
            NSDisconnectPlayer(player, Spyglass_BannedPlayers[player.GetUID()]);
        }

        return;
    }

    // Query the player's sanctions if they're not in cache and apply them.
    if (Spyglass_IsPlayerInSanctionCache(player.GetUID()))
    {
        array<Spyglass_PlayerInfraction> sanctions = Spyglass_GetCachedPlayerSanctions(player.GetUID());
        string playerName = player.GetPlayerName();

        Spyglass_AppliedSanctionResult result = Spyglass_ApplySanctionsToPlayer(player, sanctions);
        if (result.DisconnectedPlayer)
        {
            array<Spyglass_PlayerInfraction> notificationList = [];
            foreach (Spyglass_PlayerInfraction sanction in sanctions)
            {
                if (!(sanction.ID in Spyglass_NotifiedSanctionCache))
                {
                    notificationList.append(sanction);
                    Spyglass_NotifiedSanctionCache[sanction.ID] <- true;
                }
            }

            if (notificationList.len() != 0)
            {
                array<entity> targets = Spyglass_GetSanctionMessageTargets();
                Spyglass_ChatSendPlayerInfractions(playerName, notificationList, Spyglass_GetSanctionMessageTargets());
            }
        }
        else
        {
            if (player.GetUID() in Spyglass_OnConnectNotification)
            {
                Spyglass_OnConnectNotification[player.GetUID()] = result.AppliedSanctions;
            }
            else
            {
                Spyglass_OnConnectNotification[player.GetUID()] <- result.AppliedSanctions;
            }
        }
    }
    else
    {
        // Check that the player wasn't in the connected cache and we're not in prematch.
        // If so, don't query sanctions. They'll be refreshed like everyone else.
        if (Spyglass_IsConnected(player.GetUID()) && GetGameState() < eGameState.Prematch)
        {
            printt(format("[Spyglass] Player '%s' was already connected last map, waiting for bulk sanction check on prematch.", player.GetPlayerName()));
            return;
        }

        if (!Spyglass_VerifyPlayerSanctions(player))
        {
            Spyglass_SayAllError(format("Failed to start verifying sanctions for player '%s'.", Spyglass_FriendlyColor(player.GetPlayerName())));
            return;
        }
    }
}

/** Displays the player's sanctions if any. */
void function OnClientConnected(entity player)
{
    if (Spyglass_IsDisabled())
    {
        return;
    }

    if (!IsValid(player) || !player.IsPlayer())
    {
        return;
    }

    Spyglass_RemoveConnectingPlayer(player.GetUID());
    Spyglass_AddConnectedPlayer(player.GetUID());

    if (Spyglass_HasImmunity(player))
    {
        return;
    }

    if (!(player.GetUID() in Spyglass_OnConnectNotification))
    {
        return;
    }

    array<Spyglass_PlayerInfraction> notificationList = [];
    foreach (Spyglass_PlayerInfraction sanction in Spyglass_OnConnectNotification[player.GetUID()])
    {
        if (!(sanction.ID in Spyglass_NotifiedSanctionCache))
        {
            notificationList.append(sanction);
            Spyglass_NotifiedSanctionCache[sanction.ID] <- true;
        }
    }

    delete Spyglass_OnConnectNotification[player.GetUID()];
    if (notificationList.len() != 0)
    {
        Spyglass_ChatSendPlayerInfractions(player.GetPlayerName(), notificationList, Spyglass_GetSanctionMessageTargets());
    }
}

/** Removes the player from muted players on disconnect. */
void function OnClientDisconnected(entity player)
{
    if (IsValid(player))
    {
        if (Spyglass_IsMuted(player.GetUID()))
        {
            Spyglass_RemoveMutedPlayer(player.GetUID());
            Spyglass_CacheMutedPlayers();
        }

        Spyglass_RemoveConnectingPlayer(player.GetUID());
        Spyglass_RemoveConnectedPlayer(player.GetUID());
    }
}

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

/**
 * Applies the sanctions to the given player, calling the necessary callbacks.
 * @param player The player to apply the sanctions to.
 * @param sanctions The sanctions to apply to the player.
 * @returns An array containing the applied sanctions.
 */
Spyglass_AppliedSanctionResult function Spyglass_ApplySanctionsToPlayer(entity player, array<Spyglass_PlayerInfraction> sanctions)
{
    Spyglass_AppliedSanctionResult applyResult;
    applyResult.AppliedSanctions = [];

    if (!IsValid(player) || !player.IsPlayer())
    {
        CodeWarning("[Spyglass] Attempted to call Spyglass_ApplySanctionsToPlayer() on invalid or non-player entity.");
        return applyResult;
    }

    string playerName = player.GetPlayerName();

    foreach (Spyglass_PlayerInfraction sanction in sanctions)
    {
        int result = Spyglass_CallPlayerSanctionOverrideCallbacks(player, clone sanction);
        
        if (result == Spyglass_SanctionOverrideResult.Unhandled)
        {
            applyResult.DisconnectedPlayer = Spyglass_ApplySanction(player, sanction);
            applyResult.AppliedSanctions.append(sanction);

            if (applyResult.DisconnectedPlayer)
            {
                break;
            }
        }
        else if (result == Spyglass_SanctionOverrideResult.AppliedSanction)
        {
            Spyglass_CallOnPlayerSanctionAppliedCallbacks(player, clone sanction);
            applyResult.AppliedSanctions.append(sanction);
        }
    }

    return applyResult;
}

void function Spyglass_OnPlayerSanctionsRefreshed(Spyglass_SanctionSearchResult result, bool invalidateCache)
{
    Spyglass_IsRefreshingSanctions = false;

    if (!result.ApiResult.Success)
    {
        Spyglass_SayAllError(format("Failed to refresh player sanctions: %s", result.ApiResult.Error));
        return;
    }

    printt(format("[Spyglass] Player sanctions refreshed successfully, received %i matches.", result.Matches.len()));

    if (invalidateCache)
    {
        Spyglass_CachedPlayerSanctions = {};
        Spyglass_CachedSanctions = {};
        Spyglass_NotifiedSanctionCache = {};

        // Refresh the mute and ban caches.
        Spyglass_EmptyMutedPlayers();
        Spyglass_BannedPlayers = {};

        Spyglass_CacheMutedPlayers();
    }

    table<string, array<Spyglass_PlayerInfraction> > deltaSanctions = Spyglass_UpdateSanctions(result);
    
    foreach (entity player in Spyglass_GetAllPlayers())
    {
        if (!IsValid(player) || !(player.GetUID() in deltaSanctions) || Spyglass_HasImmunity(player))
        {
            continue;
        }

        string playerName = player.GetPlayerName();
        Spyglass_AppliedSanctionResult result = Spyglass_ApplySanctionsToPlayer(player, deltaSanctions[player.GetUID()]);

        array<Spyglass_PlayerInfraction> notificationList = [];
        foreach (Spyglass_PlayerInfraction sanction in result.AppliedSanctions)
        {
            if (!(sanction.ID in Spyglass_NotifiedSanctionCache))
            {
                notificationList.append(sanction);
                Spyglass_NotifiedSanctionCache[sanction.ID] <- true;
            }
        }

        if (notificationList.len() != 0)
        {
            Spyglass_ChatSendPlayerInfractions(playerName, notificationList, Spyglass_GetSanctionMessageTargets());
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

void function Spyglass_OnVerifyPlayerSanctionsComplete(Spyglass_SanctionSearchResult result, string playerName, string uid)
{
    // Remove the queried uid from ongoing sanction queries.
    int index = Spyglass_OngoingSanctionQueries.find(uid);
    if (index != -1)
    {
        Spyglass_OngoingSanctionQueries.remove(index);
    }
    
    if (!result.ApiResult.Success)
    {
        Spyglass_SayAllError(format("Failed to verify player sanctions for player %s: ", Spyglass_FriendlyColor(playerName), result.ApiResult.Error));
        return;
    }

    printt(format("[Spyglass] Player sanction query for '%s' [%s] completed successfully, received %i matches.", playerName, uid, result.Matches.len()));

    table<string, array<Spyglass_PlayerInfraction> > deltaSanctions = Spyglass_UpdateSanctions(result);
    if (!(uid in deltaSanctions))
    {
        return;
    }

    entity player = Spyglass_GetPlayerByUID(uid);
    // Player isn't connected anymore, stop.
    if (player == null)
    {
        return;
    }
    
    // Keep track of whether or not the player finished connecting.
    bool isConnected = Spyglass_IsConnected(player.GetUID());
    Spyglass_AppliedSanctionResult result = Spyglass_ApplySanctionsToPlayer(player, deltaSanctions[player.GetUID()]);

    // If we got rid of the player, or the player finished connecting, notify everyone immediately, if the game state isn't waiting for players.
    if (result.DisconnectedPlayer || isConnected)
    {
        array<Spyglass_PlayerInfraction> notificationList = [];
        foreach (Spyglass_PlayerInfraction sanction in result.AppliedSanctions)
        {
            if (!(sanction.ID in Spyglass_NotifiedSanctionCache))
            {
                notificationList.append(sanction);
                Spyglass_NotifiedSanctionCache[sanction.ID] <- true;
            }
        }

        if (notificationList.len() != 0)
        {
            Spyglass_ChatSendPlayerInfractions(playerName, notificationList, Spyglass_GetSanctionMessageTargets());
        }
    }
    // Else if the player isn't connected, way for them to finish connecting first.
    else if (!isConnected)
    {
        if (uid in Spyglass_OnConnectNotification)
        {
            Spyglass_OnConnectNotification[player.GetUID()] = result.AppliedSanctions;
        }
        else
        {
            Spyglass_OnConnectNotification[player.GetUID()] <- result.AppliedSanctions;
        }
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

/**
 * Queries the sanctions of the given player, generally called while they're connecting.
 * @param player The player to verify the sanctions for.
 * @returns Whether or not the request started successfully.
 */
bool function Spyglass_VerifyPlayerSanctions(entity player)
{
    if (!IsValid(player) || !player.IsPlayer())
    {
        CodeWarning("[Spyglass] Attempted to verify player sanctions of null or non-player entity.");
        return false;
    }

    string playerName = player.GetPlayerName();
    string uid = player.GetUID();

    if (Spyglass_OngoingSanctionQueries.find(uid) != -1)
    {
        CodeWarning(format("[Spyglass] Attempted to verify player sanctions of player %s, but a verification is already ongoing.", player.GetPlayerName()));
        return true;
    }

    void functionref(Spyglass_SanctionSearchResult) callback = void function (Spyglass_SanctionSearchResult result) : (playerName, uid)
    {
        Spyglass_OnVerifyPlayerSanctionsComplete(result, playerName, uid);
    }

    bool excludeMaintainers = GetConVarBool("spyglass_maintainers_are_admins") && GetConVarBool("spyglass_admin_immunity");
    if (SpyglassApi_QueryPlayerSanctions([uid], callback, excludeMaintainers, false, false))
    {
        Spyglass_OngoingSanctionQueries.append(uid);
        return true;
    }

    return false;
}

/**
 * Queries the sanctions of all connected players in order to ensure they are up to date.
 * @param invalidateCache Whether or not to clear the local cache. Only set to true if you know what you're doing.
 */
bool function Spyglass_RefreshAllPlayerSanctions(bool invalidateCache = false)
{
    if (Spyglass_IsRefreshingSanctions)
    {
        CodeWarning("[Spyglass] Attempted to refresh all player sanctions, but we're already refreshing them.");
        return false;
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

        foreach (entity player in Spyglass_GetAllPlayers())
        {
            if (IsValid(player))
            {
                result.UniqueIDs.append(player.GetUID());
            }
        }

        Spyglass_OnPlayerSanctionsRefreshed(result, true);
        return true;
    }

    void functionref(Spyglass_SanctionSearchResult) onSanctionsRefreshed = void function(Spyglass_SanctionSearchResult result) : (invalidateCache)
    {
        Spyglass_OnPlayerSanctionsRefreshed(result, invalidateCache);
    }

    bool excludeMaintainers = GetConVarBool("spyglass_maintainers_are_admins") && GetConVarBool("spyglass_admin_immunity");
    if (SpyglassApi_QueryPlayerSanctions(uids, onSanctionsRefreshed, excludeMaintainers, false, false))
    {
        Spyglass_IsRefreshingSanctions = true;
        return true;
    }

    return false;
}

/** Checks whether or not the given player uid is banned, and has attempted to join the server this map. */
bool function Spyglass_IsPlayerBanned(string uid)
{
    return uid in Spyglass_BannedPlayers;
}

/** Caches the currently muted players in a convar, in order to keep them muted after map change. */
void function Spyglass_CacheMutedPlayers()
{
    string cache = "";

    foreach (entity player in Spyglass_GetAllPlayers())
    {
        if (IsValid(player) && player.IsPlayer() && Spyglass_IsMuted(player.GetUID()))
        {
            cache = format("%s%s,", cache, player.GetUID());
        }
    }

    SetConVarString("spyglass_cache_muted_players", cache);
}

/** Reads the muted players cache and applies the mutes. */
void function Spyglass_ApplyMutedPlayersCache()
{
    array<string> muted = Spyglass_GetConVarStringArray("spyglass_cache_muted_players");

    foreach (string uid in muted)
    {
        string sanitized = strip(uid);

        if (uid.len() != 0 && !Spyglass_IsMuted(uid))
        {
            Spyglass_AddMutedPlayer(uid);
        }
    }
}

/** Reads the connected players cache and applies the mutes. */
void function Spyglass_ApplyConnectedPlayersCache()
{
    array<string> connected = Spyglass_GetConVarStringArray("spyglass_cache_connected_players");

    foreach (string uid in connected)
    {
        string sanitized = strip(uid);

        if (uid.len() != 0 && !Spyglass_IsConnected(uid))
        {
            Spyglass_AddConnectedPlayer(uid);
        }
    }
}

/** Mutes the given player. They won't be able to type in chat anymore. */
void function Spyglass_MutePlayer(entity player)
{
    if (IsValid(player) && player.IsPlayer())
    {
        if (!Spyglass_IsMuted(player.GetUID()))
        {
            Spyglass_AddMutedPlayer(player.GetUID());
            Spyglass_CacheMutedPlayers();
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
        NSDisconnectPlayer(player, reason);
    }

    return true;
}