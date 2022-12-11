/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /sanctions
 */

global function SpyglassApi_QueryPlayerSanctions;
global function SpyglassApi_QuerySanctionById;

void function SpyglassApi_OnQueryPlayerSanctionsSuccessful(HttpRequestResponse response, void functionref(Spyglass_SanctionSearchResult) callback)
{
    if (callback == null)
    {
        return;
    }

    Spyglass_SanctionSearchResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseSanctionSearchResult(decodedBody, data);
    }

    callback(data);
}

void function SpyglassApi_OnQueryPlayerSanctionsFailed(HttpRequestFailure failure, void functionref(Spyglass_SanctionSearchResult) callback)
{
    printt(format("[Spyglass] SpyglassApi_QueryPlayerSanctions() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    if (callback == null)
    {
        return;
    }

    Spyglass_SanctionSearchResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    callback(data);
}

/**
 * Queries the Spyglass API for sanctions belonging to players in the given list of uids.
 * @param uids The unique ids (UIDs) to lookup sanctions for.
 * @param excludeMaintainers Whether or not maintainers (Spyglass admins) should be excluded from the results.
 * @param withExpired Whether or not to include expired sanctions.
 * @param withPlayerInfo Whether or not to include player info in the sanctions.
 * @param callback The callback to execute when the API call is complete.
 * @returns Whether or not the HTTP request successfully started.
 */
bool function SpyglassApi_QueryPlayerSanctions(array<string> uids, void functionref(Spyglass_SanctionSearchResult) callback, bool excludeMaintainers = false, bool withExpired = true, bool withPlayerInfo = false)
{
    if (uids.len() == 0)
    {
        CodeWarning("[Spyglass] Attempted to query player sanctions with an empty list of uids.");
        return false;
    }

    if (callback == null)
    {
        CodeWarning("[Spyglass] Attempted to query player sanctions with no callback.");
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

void function SpyglassApi_OnQuerySanctionByIdSuccessful(HttpRequestResponse response, void functionref(Spyglass_SanctionSearchResult) callback)
{
    if (callback == null)
    {
        return;
    }

    Spyglass_SanctionSearchResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseSanctionSearchResult(decodedBody, data);
    }

    callback(data);
}

void function SpyglassApi_OnQuerySanctionByIdFailed(HttpRequestFailure failure, void functionref(Spyglass_SanctionSearchResult) callback)
{
    printt(format("[Spyglass] SpyglassApi_QuerySanctionById() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    if (callback == null)
    {
        return;
    }

    Spyglass_SanctionSearchResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    callback(data);
}

/**
 * Queries the Spyglass API for the sanction with the given id, if it exists.
 * @param id The id of the sanction to retrieve.
 * @returns Whether or not the HTTP request successfully started.
 */
bool function SpyglassApi_QuerySanctionById(int id, void functionref(Spyglass_SanctionSearchResult) callback)
{
    if (id < 0)
    {
        CodeWarning("[Spyglass] Attempted to query a sanction with a negative id.");
        return false;
    }

    if (callback == null)
    {
        CodeWarning("[Spyglass] Attempted to query a sanction with no callback.");
        return false;
    }

    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/sanctions/get_by_id", Spyglass_GetApiHostname()));
    request.queryParameters["id"] <- [id.tostring()];

    void functionref(HttpRequestResponse) onSuccess = void function (HttpRequestResponse response) : (callback)
    {
        SpyglassApi_OnQuerySanctionByIdSuccessful(response, callback);
    }

    void functionref(HttpRequestFailure) onFailure = void function (HttpRequestFailure failure) : (callback)
    {
        SpyglassApi_OnQuerySanctionByIdFailed(failure, callback);
    }

    return SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure);
}