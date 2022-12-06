/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /sanctions
 */

// TODO: Add convar to kick player on sanction query timeout. Defaults to disabled with a hefty warning on the danger of enabling!
global function SpyglassApi_QueryPlayerSanctions;

void function SpyglassApi_OnQueryPlayerSanctionsSuccessful(HttpRequestResponse response, void functionref(Spyglass_SanctionSearchResult) callback)
{
}

void function SpyglassApi_OnQueryPlayerSanctionsFailed(HttpRequestFailure failure, void functionref(Spyglass_SanctionSearchResult) callback)
{
}

/**
 * Queries the Spyglass API for sanctions belonging to players in the given list of uids.
 * @param uids The unique ids (UIDs) to lookup sanctions for.
 * @param excludeMaintainers Whether or not maintainers (Spyglass admins) should be excluded from the results.
 * @param withExpired Whether or not to include expired sanctions.
 * @param withPlayerInfo Whether or not to include player info in the sanctions.
 * @param callback The callback to execute when the API call is complete.
 */
bool function SpyglassApi_QueryPlayerSanctions(array<string> uids, void functionref(Spyglass_SanctionSearchResult) callback, bool excludeMaintainers = false, bool withExpired = true, bool withPlayerInfo = false)
{
    if (uids.len() == 0)
    {
        CodeWarning("[Spyglass] Attempted to query player sanctions with an empty list of uids.");
        return false;
    }

    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/sanctions/lookup_uid", Spyglass_GetApiHostname()));
    request.queryParameters["uids"] <- uids;
    request.queryParameters["excludeMaintainers"] <- [excludeMaintainers.tostring()];
    request.queryParameters["withExpired"] <- [withExpired.tostring()];
    request.queryParameters["withPlayerInfo"] <- [withPlayerInfo.tostring()];

    void functionref(HttpRequestResponse) onSuccess = void function (HttpRequestResponse response) : (callback)
    {
        SpyglassApi_OnQueryPlayerSanctionsSuccessful(response, callback);
    }

    void functionref(HttpRequestFailure) onFailure = void function (HttpRequestFailure failure) : (callback)
    {
        SpyglassApi_OnQueryPlayerSanctionsFailed(failure, callback);
    }

    return SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure);
}