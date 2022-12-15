globalize_all_functions

// Returns the smallest value between a or b, or a if equal.
int function Spyglass_Min(int a, int b)
{
    return a <= b ? a : b;
}

// Returns the smallest value between a or b, or a if equal.
float function Spyglass_Minf(float a, float b)
{
    return a <= b ? a : b;
}

// Returns the largest value between a or b, or a if equal.
int function Spyglass_Max(int a, int b)
{
    return a >= b ? a : b;
}

// Returns the largest value between a or b, or a if equal.
float function Spyglass_Maxf(float a, float b)
{
    return a >= b ? a : b;
}

/** 
 * Returns the singular representation of a string if the count is equal to one, else returns the plural representation. 
 */
string function Spyglass_Pluralize(string singular, string plural, int count)
{
    return count == 1 ? singular : plural;
}

// Nabbed from Fifty's Server Utils, go check them out! https://northstar.thunderstore.io/package/Fifty/Server_Utilities/
string function Spyglass_GetColoredConVarString(string cvarName)
{
    string realValue = GetConVarString(cvarName);
    array<string> realSplit = Spyglass_SplitEscapedString(realValue, "\\x1b");
    string result;

    foreach (_index, string value in realSplit)
    {
        result += value;

        if(_index != realSplit.len() - 1)
        {
            result += "\x1b";
        }
    }

    return result;
}

// Ditto! This was a life safer.
array<string> function Spyglass_SplitEscapedString(string value, string separator)
{
    array<string> result;
    string temp = value;

    int lastIndex = 0

    while (true)
    {
        var foundIndex = value.find(separator);

        if(foundIndex == null)
        {
            result.append(value.slice(lastIndex, value.len()));
            break;
        }

        int tempIndex = expect int(foundIndex);

        value = value.slice(0, tempIndex) + value.slice(tempIndex + separator.len(), value.len());
        result.append(value.slice(lastIndex, tempIndex));

        lastIndex = tempIndex;
    }

    if (result.len() == 0)
    {
        result.append(value);
    }

    return result;
}

/** Returns the string representation of a player infraction. */
string function Spyglass_GetInfractionAsString(Spyglass_PlayerInfraction infraction, bool disconnectMessage = false)
{
    string typeString = "Invalid";
    switch (infraction.Type)
    {
        case Spyglass_InfractionType.Spamming: typeString = "Spamming"; break;
        case Spyglass_InfractionType.Harassment: typeString = "Harassment"; break;
        case Spyglass_InfractionType.HateSpeech: typeString = "Hate Speech"; break;
        case Spyglass_InfractionType.Griefing: typeString = "Griefing"; break;
        case Spyglass_InfractionType.Exploiting: typeString = "Exploiting"; break;
        case Spyglass_InfractionType.Cheating: typeString = "Cheating"; break;
    }

    string punishmentString = "Invalid";
    switch (infraction.PunishmentType)
    {
        case Spyglass_SanctionType.Warn: punishmentString = "Warned"; break;
        case Spyglass_SanctionType.Mute: punishmentString = "Muted"; break;
        case Spyglass_SanctionType.Ban: punishmentString = "Banned"; break; 
    }

    if (!disconnectMessage)
    {
        return format("\x1b[38;5;123m[#%i @ %s] \x1b[38;2;254;64;64m(%s for %s): \x1b[0m%s\nExpires: %s", infraction.ID, infraction.IssuedAtReadable, punishmentString, typeString, infraction.Reason, infraction.ExpiresAtReadable);
    }

    string str = format("[Spyglass]: [#%i] %s for %s on %s. Reason: %s. Expires: %s.", infraction.ID, punishmentString, typeString, infraction.IssuedAtReadable, infraction.Reason, infraction.ExpiresAtReadable);
    string appeal = strip(GetConVarString("spyglass_appeal_server"));
    if (appeal.len() != 0)
    {
        str = format("%s Appeal on: %s", str, appeal);
    }

    return str;
}

/** Splits the value of the given string convar into an array, using commas as a separator. */
array<string> function Spyglass_GetConVarStringArray(string cvarName)
{
    string clean = strip(GetConVarString(cvarName));
    return split(clean, ",");
}

/** Returns the base hostname of the configured Spyglass API backend. */
string function Spyglass_GetApiHostname()
{
    return GetConVarString("spyglass_api_hostname");
}

/** Returns a sanitized url for the Spyglass API */
string function Spyglass_SanitizeUrl(string url)
{
    while (url.find("//") != null)
    {
        url = StringReplace(url, "//", "/", true, true);
    }
    
    return strip(url);
}

/** 
 * Returns the cached latest version of Spyglass.
 * Updated every time we make a successful API call.
 */
string function Spyglass_GetLatestVersion()
{
    return strip(GetConVarString("spyglass_cache_api_latest_version"));
}

/** 
 * Returns the cached minimum required version of Spyglass.
 * Updated every time we make a successful API call.
 */
string function Spyglass_GetMinimumVersion()
{
    return strip(GetConVarString("spyglass_cache_api_minimum_version"));
}

/**
 * Parses the text representation of a version into a version structure.
 * Must be in Major.Minor.Patch form.
 * @param text The text representation of the version.
 * @param outVersion The version data that was parsed from the string.
 * @returns True if parsing was successful.
 */
bool function Spyglass_ParseVersion(string text, Spyglass_Version outVersion)
{
    text = strip(text);
    array<string> components = split(text, ".");
    
    if (components.len() != 3)
    {
        return false;
    }

    for (int i = 0; i < components.len(); i++)
    {
        components[i] = strip(components[i]);
    }

    outVersion.Major = components[0].tointeger();
    outVersion.Minor = components[1].tointeger();
    outVersion.Patch = components[2].tointeger();

    // Make sure parsing worked by comparing them back into strings.
    return outVersion.Major.tostring() == components[0]
        && outVersion.Minor.tostring() == components[1]
        && outVersion.Patch.tostring() == components[2];
}

/**
 * Compares the local version to the other version.
 * @param localVersion The local version to compare the other version to. 
 * @param otherVersion The other version to compare the local one to.
 * @returns -1 if outdated, 0 if equal, +1 if greater than the other version.
 */
int function Spyglass_CompareVersions(Spyglass_Version localVersion, Spyglass_Version otherVersion)
{
    if (localVersion.Major == otherVersion.Major
        && localVersion.Minor == otherVersion.Minor
        && localVersion.Patch == otherVersion.Patch)
    {
        return 0;
    }

    if (localVersion.Major > otherVersion.Major
        || localVersion.Major == otherVersion.Major && localVersion.Minor > otherVersion.Minor
        || localVersion.Major == otherVersion.Major && localVersion.Minor == otherVersion.Minor && localVersion.Patch > otherVersion.Patch)
    {
        return 1;
    }

    return -1;
}

/** 
 * Checks the local version against the API's version if cached. 
 * Returns a Spyglass_VersionCheckResult in integer form.
 */
int function Spyglass_VersionCheck()
{
    Spyglass_Version localVersion;
    Spyglass_Version minimumVersion;
    Spyglass_Version latestVersion;

    if (!Spyglass_ParseVersion(NSGetModVersionByModName("IMC.Spyglass"), localVersion)
        || !Spyglass_ParseVersion(Spyglass_GetMinimumVersion(), minimumVersion)
        || !Spyglass_ParseVersion(Spyglass_GetLatestVersion(), latestVersion))
    {
        return Spyglass_VersionCheckResult.Unknown;
    }

    int minimumCheck = Spyglass_CompareVersions(localVersion, minimumVersion);
    if (minimumCheck == -1)
    {
        return Spyglass_VersionCheckResult.OutdatedIncompatible;
    }

    int latestCheck = Spyglass_CompareVersions(localVersion, latestVersion);
    if (latestCheck == -1)
    {
        return Spyglass_VersionCheckResult.Outdated;
    }

    return Spyglass_VersionCheckResult.UpToDate;
}

/** Returns whether or not Spyglass is currently disabled due to an error. */
bool function Spyglass_IsDisabled()
{
    return GetConVarBool("spyglass_cache_disabled_from_error");
}

#if SERVER

/**
 * Sends a message to everyone in the chat as Spyglass.
 * @param message The message that Spyglass should send in chat.
 * @param withServerTag Whether or not to display the [SERVER] tag prior to Spyglass' name.
 */
void function Spyglass_SayAll(string message, bool withServerTag = false)
{
    string finalMessage = format("\x1b[113mSpyglass:\x1b[0m %s", message);
    Chat_ServerBroadcast(finalMessage, withServerTag);
}

/**
 * Sends a message to the target player in the chat as Spyglass.
 * @param player The player to send the message to.
 * @param message The message that Spyglass should send in chat.
 * @param isWhisper Whether or not to display the [WHISPER] tag prior to Spyglass' name.
 * @param withServerTag Whether or not to display the [SERVER] tag prior to Spyglass' name.
 */
void function Spyglass_SayPrivate(entity player, string message, bool isWhisper = false, bool withServerTag = false)
{
    string finalMessage = format("\x1b[113mSpyglass:\x1b[0m %s", message);
    Chat_ServerPrivateMessage(player, finalMessage, isWhisper, withServerTag);
}

/** Checks whether or not the given player is in the admin uids convar. */
bool function Spyglass_IsAdmin(entity player)
{
    array<string> adminUIDs = Spyglass_GetConVarStringArray("spyglass_admin_uids");
    return IsValid(player) && player.IsPlayer() && adminUIDs.find(player.GetUID()) != -1;
}

/**
 * Sends the player's infractions in chat, if any. Packs them into messages together when possible.
 * @param playerName The name of the player that owns the given infractions.
 * @param targets If set, the infractions will only be sent to those players. Leave empty to send globally.
 * @param limit The limit of infractions to send to the chat. Leave at default for all infractions.
 * @param fromNewest Whether or not to print the newest infractions first, or start from the oldest.
 */
void function Spyglass_ChatSendPlayerInfractions(string playerName, array<Spyglass_PlayerInfraction> infractions, array<entity> targets = [], int limit = 0, bool fromNewest = true)
{
    foreach (entity target in targets)
    {
        if (!IsValid(target) || !target.IsPlayer())
        {
            CodeWarning("[Spyglass] Error: attempted to print player infractions to chat with invalid target entity.");
            return;
        }
    }

    // Get the player's infractions if any.
    if (infractions.len() == 0)
    {
        return;
    }

    foreach (entity target in targets)
    {
        if (IsValid(target) && target.IsPlayer())
        {
            Spyglass_SayPrivate(target, format("Player \x1b[111m%s\x1b[0m has been sanctioned due to %i %s:", playerName, infractions.len(), 
                Spyglass_Pluralize("infraction", "infractions", infractions.len())), false, false);
        }
    }

    // Define loop start index and direction + condition here to avoid writing code twice.
    int startIdx = fromNewest ? infractions.len() - 1 : 0;
    bool functionref(int, int, int, int, bool) loopCond = bool function (int start, int curr, int len, int limit, bool newest)
    {
        return newest
            ? (limit == 0  && curr >= 0) || curr >= Spyglass_Max(len - limit, 0)
            : curr < Spyglass_Max(limit, len);
    }

    int functionref(int, bool) loopInc = int function (int curr, bool newest) { return newest ? curr - 1 : curr + 1 }

    // Loop through all infractions to get their string respresentations.
    for (int idx = startIdx; loopCond(startIdx, idx, infractions.len(), limit, fromNewest); idx = loopInc(idx, fromNewest))
    {
        Spyglass_PlayerInfraction infraction = infractions[idx];
        string infractionStr = Spyglass_GetInfractionAsString(infraction);

        foreach (entity target in targets)
        {
            if (IsValid(target) && target.IsPlayer())
            {
                Spyglass_SayPrivate(target, infractionStr, false, false);
            }
        }
    }
}

/** Checks whether or not the given player is immune to Spyglass sanctions. */
bool function Spyglass_HasImmunity(entity player)
{
    return GetConVarBool("spyglass_admin_immunity") && IsValid(player) && player.IsPlayer() && Spyglass_IsAdmin(player);
}
#endif