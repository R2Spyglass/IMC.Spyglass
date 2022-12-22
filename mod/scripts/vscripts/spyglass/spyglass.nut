global function Spyglass_Init;

void function Spyglass_Init()
{
    printt("[Spyglass] Spyglass_Init() called.");
    // Reset disabled flag, will be reset on init if required.
    SetConVarBool("spyglass_cache_disabled_from_error", false);

    AddCallback_OnReceivedSayTextMessage(OnClientMessage);
    AddCallback_OnClientConnected(OnClientConnected);

    AddCallback_GameStateEnter(eGameState.Prematch, OnPrematchStarted);
    AddCallback_GameStateEnter(eGameState.Playing, OnPlayingStarted);

    if (GetGameState() >= eGameState.Prematch)
    {
        OnPrematchStarted();
    }

    if (GetGameState() >= eGameState.Playing)
    {
        OnPlayingStarted();
    }
}

void function Spyglass_OnTrackPlayersComplete(Spyglass_ApiResult result)
{
    if (result.Success)
    {
        Spyglass_SayAdmins("Tracking data uploaded completed successfully.");
    }
    else
    {
        Spyglass_SayAdmins(format("Failed to upload tracking data with error: %s", result.Error));
    }
}

// TODO: Retry on error, up to three times. Local error not counting (fail immediate).
void function OnStatsRequestComplete(Spyglass_ApiStats response)
{
    if (response.ApiResult.Success)
    {
        Spyglass_SayAll(format("Uplink established successfully, API version v%s.", Spyglass_GetLatestVersion()));
        
        switch (Spyglass_VersionCheck())
        {
            case Spyglass_VersionCheckResult.Outdated:
                Spyglass_SayAll(format("A new version '%s' is available. Please update whenever possible.", Spyglass_GetLatestVersion()));
                break;
            case Spyglass_VersionCheckResult.Unknown:
            case Spyglass_VersionCheckResult.OutdatedIncompatible:
                Spyglass_SayAllError(format("This server is running an incompatible version of Spyglass, please update to '%s'.", Spyglass_GetLatestVersion()));
                Spyglass_SayAllError("This mod will not work until updated");
                printt("[Spyglass] Outdated and not meeting minimum required version by the API. Update as soon as possible.");
                SetConVarBool("spyglass_cache_disabled_from_error", true);
                return;
        }

        Spyglass_SayAll(format("I am currently tracking %i %s and %i %s.", response.Players, Spyglass_Pluralize("pilot", "pilots", response.Players), response.Sanctions,
            Spyglass_Pluralize("sanction", "sanctions", response.Sanctions)));
        
        if (!Spyglass_RefreshAllPlayerSanctions())
        {
            Spyglass_SayAllError("Failed to refresh player sanctions, check the server's console for more information.");
        }
        
        if (Spyglass_TrackPlayers(GetPlayerArray(), Spyglass_OnTrackPlayersComplete))
        {
            Spyglass_SayAdmins("API token detected, sending connected player identities to the API for tracking...");
        }
    }
    else
    {
        Spyglass_SayAllError(format("An error has occurred while establishing the uplink: %s", response.ApiResult.Error));
    }
}

void function OnPrematchStarted()
{
    printt("[Spyglass] Prematch started, connecting to API...");
    Spyglass_SayAll(format("Initializing core, version %s.", NSGetModVersionByModName("IMC.Spyglass")));
    Spyglass_SayAll("Establishing uplink to IMC sanction database...");

    if (!SpyglassApi_GetStats(OnStatsRequestComplete))
    {
        SetConVarBool("spyglass_cache_disabled_from_error", true);
        Spyglass_SayAllError("An error has occurred, check server console for more information.");
        Spyglass_SayAllError("This mod will not work until the issue is resolved.");
    }
}

void function OnPlayingStarted()
{
    if (Spyglass_IsDisabled())
    {
        return;
    }

    if (GetConVarBool("spyglass_welcome_message_enabled"))
    {
        foreach (entity player in GetPlayerArray())
        {
            if (IsValid(player))
            {
                NSSendInfoMessageToPlayer(player, GetConVarString("spyglass_welcome_message"));
            }
        }
    }
}

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

    // Track the player if we're already in pre-match.
    if (GetGameState() >= eGameState.Prematch)
    {
        Spyglass_TrackPlayers([player]);

        if (GetConVarBool("spyglass_welcome_message_enabled"))
        {
            foreach (entity player in GetPlayerArray())
            {
                if (IsValid(player))
                {
                    NSSendInfoMessageToPlayer(player, GetConVarString("spyglass_welcome_message"));
                }
            }
        }
    }
}

ClServer_MessageStruct function OnClientMessage(ClServer_MessageStruct message)
{
    // Ignore if the message is already blocked, if the player is invalid or the player is immune.
    if (message.shouldBlock || !IsValid(message.player) || Spyglass_HasImmunity(message.player))
    {
        return message;
    }

    if (Spyglass_IsMuted(message.player.GetUID()))
    {
        message.shouldBlock = true;
    }

    return message;
}