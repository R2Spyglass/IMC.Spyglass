/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /
 */

global function SpyglassApi_GetLatestVersion;
global function SpyglassApi_GetMinimumVersion;
global function SpyglassApi_ParseVersionHeaders;
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

/** Internal only - retrieves and caches the version and minimum version from response headers. */
void function SpyglassApi_ParseVersionHeaders(string headers)
{
    array<string> values = split(headers, "\n");

    foreach (string header in values)
    {
        printt(header);
        var index = header.find(":");
        if (index == null)
        {
            continue;
        }

        string name = strip(header.slice(0, expect int(index)))
        string value = strip(header.slice(expect int(index) + 1));

        if (name == "Spyglass-API-Version")
        {
            SetConVarString("spyglass_cache_api_latest_version", value);
        }

        if (name == "Spyglass-API-MinimumVersion")
        {
            SetConVarString("spyglass_cache_api_minimum_version", value);
        }
    }
}

/** Called when an attempt to retrieve the api version was completed. */
void function SpyglassApi_OnApiVersionRequestComplete(int statusCode, string body, string headers)
{
    Spyglass_ApiVersion data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", statusCode);

    if (statusCode == 200)
    {
        SpyglassApi_ParseVersionHeaders(headers);

        table response = DecodeJSON(body);
        Spyglass_TryParseApiVersion(response, data);
    }

    foreach (void functionref(Spyglass_ApiVersion) callback in ApiVersionCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    ApiVersionCallbacks = [];
}

void function SpyglassApi_OnApiVersionRequestFailed(int errorCode, string errorMessage)
{
    printt(format("[Spyglass] SpyglassApi_GetApiVersion() failed with error code %i: %s", errorCode, errorMessage));
    
    Spyglass_ApiVersion data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("An internal error has occurred while processing the request (%i): %s", errorCode, errorMessage);

    foreach (void functionref(Spyglass_ApiVersion) callback in ApiVersionCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    ApiVersionCallbacks = [];
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
    string apiUrl = Spyglass_SanitizeUrl(format("%s/version", Spyglass_GetApiHostname()));
    if (NSHttpGet(apiUrl, {}, SpyglassApi_OnApiVersionRequestComplete, SpyglassApi_OnApiVersionRequestFailed))
    {
        ApiVersionCallbacks.append(callback);
        return true;
    }

    return false;
}

/** Called when an attempt to retrieve the api stats was completed. */
void function SpyglassApi_OnApiStatsRequestComplete(int statusCode, string body, string headers)
{
    Spyglass_ApiStats data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", statusCode);

    if (statusCode == 200)
    {
        SpyglassApi_ParseVersionHeaders(headers);

        table response = DecodeJSON(body);
        Spyglass_TryParseApiStats(response, data);
    }

    foreach (void functionref(Spyglass_ApiStats) callback in ApiStatsCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    ApiStatsCallbacks = [];
}

void function SpyglassApi_OnApiStatsRequestFailed(int errorCode, string errorMessage)
{
    printt(format("[Spyglass] SpyglassApi_GetApiStats() failed with error code %i: %s", errorCode, errorMessage));
    
    Spyglass_ApiStats data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("An internal error has occurred while processing the request (%i): %s", errorCode, errorMessage);
    
    foreach (void functionref(Spyglass_ApiStats) callback in ApiStatsCallbacks)
    {
        if (callback != null)
        {
            callback(data);
        }
    }

    ApiStatsCallbacks = [];
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
    string apiUrl = Spyglass_SanitizeUrl(format("%s/stats", Spyglass_GetApiHostname()));
    if (NSHttpGet(apiUrl, {}, SpyglassApi_OnApiStatsRequestComplete, SpyglassApi_OnApiStatsRequestFailed))
    {
        ApiStatsCallbacks.append(callback);
        return true;
    }

    return false;
}