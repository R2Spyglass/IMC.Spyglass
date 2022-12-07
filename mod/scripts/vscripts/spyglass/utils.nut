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
string function Spyglass_GetInfractionAsString(Spyglass_PlayerInfraction infraction)
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

    return format("\x1b[38;5;123m[#%i @ %s] \x1b[38;2;254;64;64m(%s): \x1b[0m%s\nExpires: %s", infraction.ID, infraction.IssuedAtReadable, typeString, infraction.Reason, infraction.ExpiresAtReadable);
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