/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /players
 */

global function SpyglassApi_TrackPlayers;

void function SpyglassApi_OnPlayerTrackingAttemptSuccessful(HttpRequestResponse response, void functionref(Spyglass_ApiResult) callback)
{
    if (callback == null)
    {
        return;
    }

    Spyglass_ApiResult data;
    data.Success = false;
    data.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseApiResult(decodedBody, data);
    }

    if (data.Success)
    {
        printt("[Spyglass] Successfully send tracking data to the API.");
    }
    else
    {
        printt(format("[Spyglass] Failed to send player identities to the API with error: %s", data.Error));
    }

    callback(data);
}

void function SpyglassApi_OnPlayerTrackingAttemptFailed(HttpRequestFailure failure, void functionref(Spyglass_ApiResult) callback)
{
    printt(format("[Spyglass] SpyglassApi_TrackPlayers() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    if (callback == null)
    {
        return;
    }

    Spyglass_ApiResult data;
    data.Success = false;
    data.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    callback(data);
}

/**
 * Tracks the given players UIDs with their usernames at the time, creating or updating player info in the database.
 * @param data The tracking data to send to the database.
 * @param callback The callback to execute when the tracking is done.
 * @returns Whether or not the request successfully started.
 */
bool function SpyglassApi_TrackPlayers(Spyglass_PlayerTrackingData data, void functionref(Spyglass_ApiResult) callback)
{
    if (data.Players.len() == 0)
    {
        return true;
    }

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

    if (SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure, true))
    {
        printt(format("[Spyglass] Sending %i player identities to the API for tracking...", data.Players.len()));
        return true;
    }

    CodeWarning(format("[Spyglass] Request to send %i player identities to the API failed.", data.Players.len()));
    return false;
}