/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /
 */

global function SpyglassApi_GetLatestVersion;
global function SpyglassApi_GetMinimumVersion;
global function SpyglassApi_MakeHttpRequest;
global function SpyglassApi_GetApiVersion;
global function SpyglassApi_GetStats;

array<void functionref(Spyglass_ApiVersion)> ApiVersionCallbacks;
array<void functionref(Spyglass_ApiStats)> ApiStatsCallbacks;

/** 
 * Returns the cached latest version of Spyglass.
 * Updated every time we make a successful API call.
 */
string function SpyglassApi_GetLatestVersion()
{
    return GetConVarString("spyglass_cache_api_latest_version");
}

/** 
 * Returns the cached minimum required version of Spyglass.
 * Updated every time we make a successful API call.
 */
string function SpyglassApi_GetMinimumVersion()
{
    return GetConVarString("spyglass_cache_api_minimum_version");
}

/**
 * Wraps NSHttpRequest() to setup special headers in a request, and capture responses for processing. 
 * @param request The parameters to use for this request.
 * @param onSuccess The callback to execute if the request is successful.
 * @param onFailure The callback to execute if the request has failed.
 * @returns Whether or not the request has been successfully started.
 */
bool function SpyglassApi_MakeHttpRequest(HttpRequest request, void functionref(HttpRequestResponse) onSuccess = null, void functionref(HttpRequestFailure) onFailure = null)
{
    SpyglassApi_SetupHeaders(request);

    // Wrap the success callback to capture headers.
    void functionref(HttpRequestResponse) responseCapture = void function (HttpRequestResponse response) : (onSuccess)
    {
        if (response.statusCode == 200)
        {
            SpyglassApi_ParseVersionHeaders(response);
        }
        
        if (onSuccess != null)
        {
            onSuccess(response);
        }
    }

    return NSHttpRequest(request, responseCapture, onFailure);
}

/** Internal only - retrieves and caches the version and minimum version from response headers. */
void function SpyglassApi_ParseVersionHeaders(HttpRequestResponse response)
{
    if ("Spyglass-API-Version" in response.headers)
    {
        SetConVarString("spyglass_cache_api_latest_version", response.headers["Spyglass-API-Version"][0]);
    }

    if ("Spyglass-API-MinimumVersion" in response.headers)
    {
        SetConVarString("spyglass_cache_api_minimum_version", response.headers["Spyglass-API-MinimumVersion"][0]);
    }
}

/** Internal only - sets up headers that may be used by the API. */
void function SpyglassApi_SetupHeaders(HttpRequest request)
{
    if (!("Northstar-Server-Name" in request.headers))
    {
        request.headers["Northstar-Server-Name"] <- [ GetConVarString("ns_server_name") ];
    }
}

void function SpyglassApi_ExecuteApiVersionCallbacks(Spyglass_ApiVersion data, bool empty = true)
{
    foreach (void functionref(Spyglass_ApiVersion) callback in ApiVersionCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    if (empty)
    {
        ApiVersionCallbacks = [];
    }
}

/** Called when an attempt to retrieve the api version was completed. */
void function SpyglassApi_OnApiVersionRequestComplete(HttpRequestResponse response)
{
    Spyglass_ApiVersion data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseApiVersion(decodedBody, data);
    }

    SpyglassApi_ExecuteApiVersionCallbacks(data);
}

/** Called when an attempt to retrieve the api version has failed. */
void function SpyglassApi_OnApiVersionRequestFailed(HttpRequestFailure failure)
{
    printt(format("[Spyglass] SpyglassApi_GetApiVersion() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    Spyglass_ApiVersion data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    SpyglassApi_ExecuteApiVersionCallbacks(data);
}

/** 
 * Queries the API for the current API mod version, and minimum required version of the mod for it to work.
 * @param callback The callback to execute when the API call is complete.
 * @returns Whether or not the API request has successfully started.
 */
bool function SpyglassApi_GetApiVersion(void functionref(Spyglass_ApiVersion) callback)
{
    // If we're already running a query in the background, simply add it to the callback array.
    if (ApiVersionCallbacks.len() != 0)
    {
        ApiVersionCallbacks.append(callback);
        return true;
    }

    // Make the request, and if successfully started, queue the callback.
    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/version", Spyglass_GetApiHostname()));

    if (SpyglassApi_MakeHttpRequest(request, SpyglassApi_OnApiVersionRequestComplete, SpyglassApi_OnApiVersionRequestFailed))
    {
        ApiVersionCallbacks.append(callback);
        return true;
    }

    return false;
}

void function SpyglassApi_ExecuteApiStatsCallbacks(Spyglass_ApiStats data, bool empty = true)
{
    foreach (void functionref(Spyglass_ApiStats) callback in ApiStatsCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    if (empty)
    {
        ApiStatsCallbacks = [];
    }
}

/** Called when an attempt to retrieve the api stats was completed. */
void function SpyglassApi_OnApiStatsRequestComplete(HttpRequestResponse response)
{
    Spyglass_ApiStats data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseApiStats(decodedBody, data);
    }

    SpyglassApi_ExecuteApiStatsCallbacks(data);
}

/** Called when an attempt to retrieve the api stats has failed. */
void function SpyglassApi_OnApiStatsRequestFailed(HttpRequestFailure failure)
{
    printt(format("[Spyglass] SpyglassApi_GetApiStats() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    Spyglass_ApiStats data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);
    
    SpyglassApi_ExecuteApiStatsCallbacks(data);
}

bool function SpyglassApi_GetStats(void functionref(Spyglass_ApiStats) callback)
{
    // If we're already running a query in the background, simply add it to the callback array.
    if (ApiStatsCallbacks.len() != 0)
    {
        ApiStatsCallbacks.append(callback);
        return true;
    }

    // Make the request, and if successfully started, queue the callback.
    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/stats", Spyglass_GetApiHostname()));

    if (SpyglassApi_MakeHttpRequest(request, SpyglassApi_OnApiStatsRequestComplete, SpyglassApi_OnApiStatsRequestFailed))
    {
        ApiStatsCallbacks.append(callback);
        return true;
    }

    return false;
}