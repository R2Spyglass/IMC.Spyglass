/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /players
 */

global function SpyglassApi_TrackPlayers;

void function SpyglassApi_OnPlayerTrackingAttemptSuccessful(HttpRequestResponse response, void functionref(Spyglass_ApiResult) callback)
{

}

void function SpyglassApi_OnPlayerTrackingAttemptFailed(HttpRequestFailure failure, void functionref(Spyglass_ApiResult) callback)
{

}

/**
 * Tracks the given players UIDs with their usernames at the time, creating or updating player info in the database.
 * @param data The tracking data to send to the database.
 * @param callback The callback to execute when the tracking is done.
 * @returns Whether or not the request successfully started.
 */
bool function SpyglassApi_TrackPlayers(Spyglass_PlayerTrackingData data, void functionref(Spyglass_ApiResult) callback)
{
    table serialized = Spyglass_SerializePlayerTrackingData(data);

    HttpRequest request;
    request.method = HttpRequestMethod.POST;
    request.url = Spyglass_SanitizeUrl(format("%s/players/track_players", Spyglass_GetApiHostname()));
    request.body = EncodeJSON(serialized);

    void functionref(HttpRequestResponse) onSuccess = void function (HttpRequestResponse response) : (callback)
    {
        SpyglassApi_OnPlayerTrackingAttemptSuccessful(response, callback);
    }

    void functionref(HttpRequestFailure) onFailure = void function (HttpRequestFailure failure) : (callback)
    {
        SpyglassApi_OnPlayerTrackingAttemptFailed(failure, callback);
    }

    return SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure, true);
}