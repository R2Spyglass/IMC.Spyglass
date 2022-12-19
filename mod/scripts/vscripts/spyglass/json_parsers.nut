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
 * Tries to parse the given API response into a Spyglass_ApiResult struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_ApiResult struct on success.
 * @returns True if we've parsed the response successfully (check the ApiResult field first!).
 */
bool function Spyglass_TryParseApiResult(table response, Spyglass_ApiResult outResult)
{
    outResult.Success = false;
    outResult.Error = "Failed to parse API response into a Spyglass_ApiResult struct.";

    if (Spyglass_TryParseBool(response, "success"))
    {
        outResult.Success = expect bool(response["success"]);

        if (!outResult.Success)
        {
            if (Spyglass_TryParseString(response, "error"))
            {
                outResult.Error = expect string(response["error"]);
            }
            else
            {
                return false;
            }
        }

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

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }

    outVersion.ApiResult.Success = parsedResult.Success;
    outVersion.ApiResult.Error = parsedResult.Error;

    if (!outVersion.ApiResult.Success)
    {
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

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }
    
    outStats.ApiResult.Success = parsedResult.Success;
    outStats.ApiResult.Error = parsedResult.Error;

    if (!outStats.ApiResult.Success)
    {
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
 * Tries to parse the given API response into a Spyglass_PlayerInfo struct.
 * @param response The decoded JSON response from the API.
 * @param outPlayerInfo The parsed Spyglass_PlayerInfo struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParsePlayerInfo(table response, Spyglass_PlayerInfo outPlayerInfo)
{
    if (response.len() == 0)
    {
        return false;
    }

    outPlayerInfo.KnownAliases = [];

    bool success = Spyglass_TryParseString(response, "uniqueId");
    success = success && Spyglass_TryParseString(response, "username");
    success = success && Spyglass_TryParseBool(response, "isMaintainer");
    success = success && Spyglass_TryParseInt(response, "createdAtTimestamp");
    success = success && Spyglass_TryParseString(response, "createdAtReadable");
    success = success && Spyglass_TryParseInt(response, "lastSeenAtTimestamp");
    success = success && Spyglass_TryParseString(response, "lastSeenAtReadable");

    if (success)
    {
        outPlayerInfo.UniqueId = expect string(response["uniqueId"]);
        outPlayerInfo.Username = expect string(response["username"]);
        outPlayerInfo.IsMaintainer = expect bool(response["isMaintainer"]);
        outPlayerInfo.CreatedAtTimestamp = expect int(response["createdAtTimestamp"]);
        outPlayerInfo.CreatedAtReadable = expect string(response["createdAtReadable"]);
        outPlayerInfo.LastSeenAtTimestamp = expect int(response["lastSeenAtTimestamp"]);
        outPlayerInfo.LastSeenAtReadable = expect string(response["lastSeenAtReadable"]);

        if (Spyglass_TryParseString(response, "lastSeenOnServer"))
        {
            outPlayerInfo.LastSeenOnServer = expect string(response["lastSeenOnServer"]);
        }
        else
        {
            outPlayerInfo.LastSeenOnServer = null;
        }

        if (Spyglass_TryParseArray(response, "knownAliases"))
        {
            foreach (var alias in expect array(response["knownAliases"]))
            {
                if (typeof alias == "string")
                {
                    outPlayerInfo.KnownAliases.append(expect string(alias));
                }
            }
        }

        return true;
    }

    return false;
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
    success = success && Spyglass_TryParseInt(response, "issuedAtTimestamp");
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

        if (Spyglass_TryParseTable(response, "owningPlayer"))
        {
            table owner = expect table(response["owningPlayer"]);
            Spyglass_PlayerInfo parsedOwner;
            
            if (Spyglass_TryParsePlayerInfo(owner, parsedOwner))
            {
                outInfraction.OwningPlayer = parsedOwner;
            }
        }

        outInfraction.IssuerId = expect string(response["issuerId"]);

        if (Spyglass_TryParseTable(response, "issuerInfo"))
        {
            table issuer = expect table(response["issuerInfo"]);
            Spyglass_PlayerInfo parsedIssuer;
            
            if (Spyglass_TryParsePlayerInfo(issuer, parsedIssuer))
            {
                outInfraction.IssuerInfo = parsedIssuer;
            }
        }

        outInfraction.IssuedAtTimestamp = expect int(response["issuedAtTimestamp"]);
        outInfraction.IssuedAtReadable = expect string(response["issuedAtReadable"]);

        if (Spyglass_TryParseInt(response, "expiresAtTimestamp"))
        {
            outInfraction.ExpiresAtTimestamp = expect int(response["expiresAtTimestamp"]);
        }
        else
        {
            outInfraction.ExpiresAtTimestamp = null;
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
    outResult.ApiResult.Success = false;
    outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_SanctionSearchResult struct.";

    if (response.len() == 0)
    {
        return false;
    }

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }

    outResult.ApiResult.Success = parsedResult.Success;
    outResult.ApiResult.Error = parsedResult.Error;

    if (!outResult.ApiResult.Success)
    {
        return true;
    }

    outResult.UniqueIDs = [];
    outResult.Matches = {};
    outResult.Id = -1;

    if (Spyglass_TryParseArray(response, "uniqueIDs"))
    {
        foreach (var value in expect array(response["uniqueIDs"]))
        {
            if (typeof value == "string")
            {
                outResult.UniqueIDs.append(expect string(value));
            }
        }
    }
    else if (Spyglass_TryParseInt(response, "id"))
    {
        outResult.Id = expect int(response["id"]);
    }
    else
    {
        return false;
    }
    
    if (Spyglass_TryParseTable(response, "matches"))
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

    return true;
}

/**
 * Tries to parse the given API response into a Spyglass_MaintainerAuthenticationTicket struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_MaintainerAuthenticationTicket struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParseMaintainerAuthenticationTicket(table response, Spyglass_MaintainerAuthenticationTicket outResult)
{
    if (Spyglass_TryParseString(response, "token"))
    {
        outResult.Token = expect string(response["token"]);
        return true;
    }

    return false;
}

/**
 * Tries to parse the given API response into a Spyglass_MaintainerTicketValidationResult struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_MaintainerTicketValidationResult struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParseMaintainerTicketValidationResult(table response, Spyglass_MaintainerTicketValidationResult outResult)
{
    outResult.ApiResult.Success = false;
    outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_MaintainerTicketValidationResult struct.";

    if (response.len() == 0)
    {
        return false;
    }

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }

    outResult.ApiResult.Success = parsedResult.Success;
    outResult.ApiResult.Error = parsedResult.Error;

    if (!outResult.ApiResult.Success)
    {
        return true;
    }

    if (Spyglass_TryParseBool(response, "isValid"))
    {
        outResult.IsValid = expect bool(response["isValid"]);
        return true;
    }

    return false;
}

/**
 * Tries to parse the given API response into a Spyglass_MaintainerAuthenticationResult struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_MaintainerAuthenticationResult struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParseMaintainerAuthenticationResult(table response, Spyglass_MaintainerAuthenticationResult outResult)
{
    outResult.ApiResult.Success = false;
    outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_MaintainerAuthenticationResult struct.";

    if (response.len() == 0)
    {
        return false;
    }

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }

    outResult.ApiResult.Success = parsedResult.Success;
    outResult.ApiResult.Error = parsedResult.Error;

    if (!outResult.ApiResult.Success)
    {
        return true;
    }

    if (Spyglass_TryParseTable(response, "ticket"))
    {
        table ticketData = expect table(response["ticket"]);
        Spyglass_MaintainerAuthenticationTicket ticket;
        if (Spyglass_TryParseMaintainerAuthenticationTicket(ticketData, ticket))
        {
            outResult.Ticket = ticket;
        }
        else
        {
            outResult.ApiResult.Success = false;
            outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_MaintainerAuthenticationResult struct (ticket parameter is invalid).";
            return false;
        }
    }
    else
    {
        outResult.Ticket = null;
    }

    return true;
}

/**
 * Tries to parse the given API response into a Spyglass_SanctionIssueResult struct.
 * @param response The decoded JSON response from the API.
 * @param outResult The parsed Spyglass_SanctionIssueResult struct on success.
 * @returns True if we've parsed the response successfully.
 */
bool function Spyglass_TryParseSanctionIssueResult(table response, Spyglass_SanctionIssueResult outResult)
{
    outResult.ApiResult.Success = false;
    outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_SanctionIssueResult struct.";

    if (response.len() == 0)
    {
        return false;
    }

    Spyglass_ApiResult parsedResult;
    if (!Spyglass_TryParseApiResult(response, parsedResult))
    {
        return false;
    }

    outResult.ApiResult.Success = parsedResult.Success;
    outResult.ApiResult.Error = parsedResult.Error;

    if (!outResult.ApiResult.Success)
    {
        return true;
    }

    if (Spyglass_TryParseTable(response, "issuedSanction"))
    {
        table sanction = expect table(response["issuedSanction"]);
        
        Spyglass_PlayerInfraction issuedSanction;
        if (Spyglass_TryParsePlayerInfraction(sanction, issuedSanction))
        {
            outResult.IssuedSanction = issuedSanction;
            return true;
        }
    }

    outResult.ApiResult.Success = false;
    outResult.ApiResult.Error = "Failed to parse API response into a Spyglass_SanctionIssueResult struct (issuedSanction parameter).";
    return false;
}

/**
 * Serializes a Spyglass_PlayerTrackingData struct into a table, ready for JSON encoding.
 * @param data The player tracking data to serialize.
 * @returns A table representation of the tracking data.
 */
table function Spyglass_SerializePlayerTrackingData(Spyglass_PlayerTrackingData data)
{
    table serialized = {};
    serialized["hostname"] <- data.Hostname;

    array players = [];

    foreach (Spyglass_PlayerIdentity identity in data.Players)
    {
        table identityData = {};
        identityData["username"] <- identity.Username;
        identityData["uniqueID"] <- identity.UniqueID;

        players.append(identityData);
    }

    serialized["players"] <- players;
    return serialized;
}

/**
 * Serializes a Spyglass_SanctionIssueData struct into a table, ready for JSON encoding.
 * @param data The sanction issue data to serialize.
 * @returns A table representation of the sanction issue data.
 */
table function Spyglass_SerializeSanctionIssueData(Spyglass_SanctionIssueData data)
{
    table serialized = {};
    serialized["uniqueId"] <- data.UniqueId;
    serialized["issuerId"] <- data.IssuerId;

    if (data.ExpiresIn != null)
    {
        int expiry = expect int (data.ExpiresIn);
        serialized["expiresIn"] <- expiry;
    }

    serialized["reason"] <- data.Reason;
    serialized["type"] <- data.Type;
    serialized["punishmentType"] <- data.PunishmentType;

    return serialized;
}