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
 * Tries to parse the given key's value into a table from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseTable(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "table")
    {
        return true;
    }

    return false;
}


/**
 * Tries to parse the given key's value into an array from the provided table.
 * @param data The table to get the key's value from.
 * @param key The key to retrieve the value for. 
 * @returns True if we parsed it successfully, false otherwise.
 */
bool function Spyglass_TryParseArray(table data, string key)
{
    if (!(key in data))
    {
        return false;
    }

    var value = data[key];
    if (typeof value == "array")
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
 * @returns True if we've parsed the response successfully (check the ApiResult field as well!).
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

/**
 * Tries to parse the given API response into a Spyglass_PlayerInfraction struct.
 * @param response The decoded JSON response from the API.
 * @param outInfraction The parsed Spyglass_PlayerInfraction struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParsePlayerInfraction(table response, Spyglass_PlayerInfraction outInfraction)
{
    if (response.len() == 0)
    {
        return false;
    }

    bool success = Spyglass_TryParseInt(response, "id");
    success = success && Spyglass_TryParseString(response, "uniqueId");
    success = success && Spyglass_TryParseString(response, "issuerId");
    success = success && Spyglass_TryParseInt(response, "issuedAt");
    success = success && Spyglass_TryParseString(response, "issuedAtReadable");
    success = success && Spyglass_TryParseString(response, "expiresAtReadable");
    success = success && Spyglass_TryParseString(response, "reason");
    success = success && Spyglass_TryParseInt(response, "type");
    success = success && Spyglass_TryParseString(response, "typeReadable");
    success = success && Spyglass_TryParseInt(response, "punishmentType");
    success = success && Spyglass_TryParseString(response, "punishmentReadable");

    if (success)
    {
        outInfraction.ID = expect int(response["id"]);
        outInfraction.UniqueId = expect string(response["uniqueId"]);
        outInfraction.IssuerId = expect string(response["issuerId"]);
        outInfraction.IssuedAtTimestamp = expect int(response["issuedAt"]);
        outInfraction.IssuedAtReadable = expect string(response["issuedAtReadable"]);

        if (Spyglass_TryParseInt(response, "expiresAt"))
        {
            response.ExpiresAtTimestamp = expect int(response["expiresAt"]);
        }
        else
        {
            response.ExpiresAtTimestamp = -1
        }

        outInfraction.ExpiresAtReadable = expect string(response["expiresAtReadable"]);
        outInfraction.Reason = expect string(response["reason"]);
        outInfraction.Type = expect int(response["type"]);
        outInfraction.TypeReadable = expect string(response["typeReadable"]);
        outInfraction.PunishmentType = expect int(response["punishmentType"]);
        outInfraction.PunishmentReadable = expect string(response["punishmentReadable"]);
        
        return true;
    }

    return false;
}

/**
 * Tries to parse the given API response into a Spyglass_SanctionSearchResult struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_SanctionSearchResult struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParseSanctionSearchResult(table response, Spyglass_SanctionSearchResult outResult)
{
    if (response.len() == 0)
    {
        return false;
    }

    if (!Spyglass_TryParseInt(response, "id"))
    {
        return false;
    }

    outResult.UniqueIDs = [];
    outResult.Matches = {};
    outResult.Id = expect int(response["id"]);

    if (Spyglass_TryParseArray(response, "uniqueIds"))
    {
        foreach (var value in expect array(response["uniqueIds"]))
        {
            if (typeof value == "string")
            {
                outResult.UniqueIDs.append(expect string(value));
            }
        }
    }
    else if (Spyglass_TryParseTable(response, "matches"))
    {
        table matches = expect table(response["matches"]);

        foreach (var key, var value in matches)
        {
            if (typeof key == "string" && typeof value == "array")
            {
                string uid = expect string(key);
                array values = expect array(value);

                outResult.Matches[uid] <- [];

                foreach (var infraction in values)
                {
                    Spyglass_PlayerInfraction outInfraction;
                    if (typeof infraction == "table" && Spyglass_TryParsePlayerInfraction(expect table(infraction), outInfraction))
                    {
                        outResult.Matches[uid].append(outInfraction);
                    }
                }
            }
        }
    }
    else
    {
        return false;
    }

    return true;
}