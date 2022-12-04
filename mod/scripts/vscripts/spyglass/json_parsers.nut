globalize_all_functions

/**
 * Tries to parse the given key's value into a boolean from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseBool(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "bool")
    {
        return true;
    }

    return false;
}

/**
 * Tries to parse the given key's value into a string from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseString(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "string")
    {
        return true;
    }

    return false;
}

/**
 * Tries to parse the given key's value into an int from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseInt(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "int")
    {
        return true;
    }

    return false;
}

/**
 * Tries to parse the given key's value into a float from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseFloat(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "float")
    {
        return true;
    }

    return false;
}

/**
 * Tries to parse the given API response into a Spyglass_ApiVersion struct.
 * @param response The decoded JSON response from the API.
 * @param outVersion The parsed Spyglass_ApiVersion struct on success.
 * @returns True if we've parsed the response successfully (check the ApiResult field first!).
 */
bool function Spyglass_TryParseApiVersion(table response, Spyglass_ApiVersion outVersion)
{
    outVersion.ApiResult.Success = false;
    outVersion.ApiResult.Error = "Failed to parse API response into a Spyglass_ApiVersion struct.";

    if (response.len() == 0)
    {
        return false;
    }

    if (!Spyglass_TryParseBool(response, "success"))
    {
        return false;
    }

    outVersion.ApiResult.Success = expect bool(response["success"]);

    if (!outVersion.ApiResult.Success)
    {
        if (Spyglass_TryParseString(response, "error"))
        {
            outVersion.ApiResult.Error = expect string(response["error"]);
        }

        return true;
    }

    bool success = Spyglass_TryParseString(response, "version");
    success = success && Spyglass_TryParseString(response, "minimumVersion");

    if (success)
    {
        outVersion.Version = expect string(response["version"]);
        outVersion.MinimumVersion = expect string(response["minimumVersion"]);
    }
    
    return success;
}

/**
 * Tries to parse the given API response into a Spyglass_ApiStats struct.
 * @param response The decoded JSON response from the API.
 * @param outStats The parsed Spyglass_ApiStats struct on success.
 * @returns True if we've parsed the response successfully (check the ApiResult field first!).
 */
bool function Spyglass_TryParseApiStats(table response, Spyglass_ApiStats outStats)
{
    outStats.ApiResult.Success = false;
    outStats.ApiResult.Error = "Failed to parse API response into a Spyglass_ApiVersion struct.";

    if (response.len() == 0)
    {
        return false;
    }

    if (!Spyglass_TryParseBool(response, "success"))
    {
        return false;
    }

    outStats.ApiResult.Success = expect bool(response["success"]);

    if (!outStats.ApiResult.Success)
    {
        if (Spyglass_TryParseString(response, "error"))
        {
            outStats.ApiResult.Error = expect string(response["error"]);
        }

        return true;
    }

    bool success = Spyglass_TryParseInt(response, "players");
    success = success && Spyglass_TryParseInt(response, "sanctions");

    if (success)
    {
        outStats.Players = expect int(response["players"]);
        outStats.Sanctions = expect int(response["sanctions"]);
    }
    
    return success;
}