// Who to send Spyglass messages to. 
global enum Spyglass_MessageMode
{
    /** Messages will be sent to everyone. */
    Everyone = 0,
    /** Messages will be sent to admins only. */
    Admins = 1
}

// Who to send sanctions to.
global enum Spyglass_SanctionMessageMode
{
    /** Sanction messages will be sent to everyone. */
    Everyone = 0,
    /** Sanction messages will be sent to the sanctionee and admins only. */
    Sanctionee = 1,
}

// Result of a version check.
global enum Spyglass_VersionCheckResult
{
    /** We do not have any remote version to compare to. */
    Unknown = 0,
    /** We are outdated and incompatible with the API. Spyglass will not function. */
    OutdatedIncompatible = 1,
    /** We are outdated but will still function correctly. */
    Outdated = 2,
    /** We are up to date with the latest version. */
    UpToDate = 3,
}

/** Results for a Spyglass sanction override (see sanction_manager.nut:Spyglass_AddPlayerSanctionOverrideCallback) */
global enum Spyglass_SanctionOverrideResult
{
    /** This sanction was not handled, and we should continue calling other callbacks or fallback to default implementation. */
    Unhandled = 0,
    /** This sanction was ignored, and we shouldn't handle it any further. */
    Ignored = 1,
    /** This sanction was applied manually, and we shouldn't handle it any further. This will also execute the Spyglass_AddOnPlayerSanctionAppliedCallback() registered callbacks. */
    AppliedSanction = 2,
}

// Holds data about a spyglass local or remote version, with major.minor.patch.
global struct Spyglass_Version
{
    // Major.Minor.Patch
    int Major
    int Minor
    int Patch
}

// The type of infraction that resulted in a player sanction.
global enum Spyglass_InfractionType
{
    // Spamming text and/or voice chat. 
    Spamming = 0,
    // Harassing a player through text and/or voice chat.
    Harassment = 1, 
    // Any discriminatory, threatening, abusive, hateful or otherwise offensive language.
    // This is a level higher than harassment.
    HateSpeech = 2, 
    // Attempts to disrupt the game experience of one or more players outside of the accepted gameplay parameters.
    // A good example would be purposefully causing damage to a teammate, either directly or indirectly.
    // Or disconnecting to prevent the enemy team from getting points.
    Griefing = 3,
    // Use or attempted use of exploits that may deteriorate the performance of game clients and/or the server,
    // or otherwise maliciously impact the set gameplay parameters of Titanfall 2.
    Exploiting = 4,
    // The use of third-party hacking or cheating clients (aimbot, wallhack etc.) or any tool that provides an advantage, like macros.
    Cheating = 5,
}

// The type of punishment that should be applied for a sanction.
global enum Spyglass_SanctionType
{
    // The player should receive a visible warning, either in text chat or as a pop-up notification.
    Warn = 0,
    // The player should be prevented from communicating using text and voice chat until the sanction expires.
    Mute = 1,
    // The player will be banned from playing on Spyglass protected servers until the sanction expires.
    Ban = 2,
}

// Basic information about a tracked Titanfall 2 player.
global struct Spyglass_PlayerInfo
{
    // The unique id (UID) of the player.
    string UniqueId
    // The username this player was initially seen with.
    string Username
    // Whether or not this player is a maintainer for Spyglass.
    bool IsMaintainer
    // The unix timestamp seconds of the date & time the player was added.
    int CreatedAtTimestamp
    // The time at which the player was added, in a readable string format.
    string CreatedAtReadable
    // The unix timestamp seconds of the date & time the player was last seen at.
    int LastSeenAtTimestamp
    // The time at which this player was last seen at, in a readable string format.
    string LastSeenAtReadable
    // The name of the server this player was last seen on, if any.
    string ornull LastSeenOnServer
    // List of known username aliases for this player.
    array<string> KnownAliases
}

// Used by trusted servers to track player data to the API.
global struct Spyglass_PlayerIdentity
{
    // The unique id (UID) of the player.
    string UniqueID
    // The username the player currently has.
    string Username
}

global struct Spyglass_PlayerTrackingData
{
    // The hostname of the server making the tracking request. 
    string Hostname
    // The players the server is currently tracking.
    array<Spyglass_PlayerIdentity> Players
}

// Details about a sanction that was issued to a player.
global struct Spyglass_PlayerInfraction
{
    // The unique id given to this player sanction.
    int ID 
    // The unique id (UID) of the player this sanction belongs to.
    string UniqueId
    // Information about the player this sanction belongs to, if queried.
    Spyglass_PlayerInfo ornull OwningPlayer
    // The unique id (UID) of the player who issued this sanction.
    string IssuerId
    // Information about the player who issued this sanction, if queried.
    Spyglass_PlayerInfo ornull IssuerInfo
    // The unix timestamp seconds of the date & time the sanction was issued.
    int IssuedAtTimestamp
    // The date and time at which this sanction was issued, in a readable string format.
    string IssuedAtReadable
    // The unix timestamp seconds of the date & time this sanction expires, if any.
    int ornull ExpiresAtTimestamp
    // The time at which this sanction expires, if any, in a readable string format.
    string ExpiresAtReadable
    // The reason why this sanction was applied to the player.
    string Reason
    // The type of infraction that led to this sanction.
    int Type
    // A human readable, uppercase string of the sanction's infraction type.
    string TypeReadable
    // The punishment that should be applied for this sanction.
    int PunishmentType
    // A human readable, uppercase string of the sanction's punishment type.
    string PunishmentReadable
}

// Data about a sanction to issue to a player.
global struct Spyglass_SanctionIssueData
{
    // The unique id of the player the sanction belongs to.
    string UniqueId
    // The unique id of the player who issued the id.
    string IssuerId
    // The time at which this sanction expires, in minutes in the future. Null if it's permanent.
    int ornull ExpiresIn
    // The reason why this sanction was applied to the player.
    string Reason
    // The type of infraction that led to this sanction.
    int Type
    // The punishment that should be applied for this sanction.
    int PunishmentType
}

// Base class for API response results.
global struct Spyglass_ApiResult
{
    // Whether or not the API request was successful.
    bool Success
    // The message that was returned by the API for the error, if any.
    string Error
}

// Contains data about the API's current version, and the minimum client version required to interact with it.
global struct Spyglass_ApiVersion
{
    Spyglass_ApiResult ApiResult
    
    // The current version of the Spyglass API.
    string Version
    // The minimum client version required to interact with this API.
    string MinimumVersion
}

// API stats returned by the /stats endpoint.
global struct Spyglass_ApiStats
{
    Spyglass_ApiResult ApiResult
    // The amount of players tracked in the database.
    int Players
    // The amount of sanctions tracked in the database.
    int Sanctions
}

// Contains the result of an attempt to search for a sanction, either by id or owning player uid.
global struct Spyglass_SanctionSearchResult
{
    Spyglass_ApiResult ApiResult
    
    // The unique ids (UID) that were used to search for sanctions, if any.
    array<string> UniqueIDs
    // The id that was used to search for the sanction, if any. (-1 if it wasn't used)
    int Id
    // The list of players who match the query and their sanctions, if any.
    table<string, array<Spyglass_PlayerInfraction> > Matches
}

global struct Spyglass_AppliedSanctionResult
{
    // The array of sanctions we applied to the player.
    array<Spyglass_PlayerInfraction> AppliedSanctions
    // True if we disconnected the player.
    bool DisconnectedPlayer
}

// An authentication ticket allowing a maintainer to authenticate on a Northstar server.
global struct Spyglass_MaintainerAuthenticationTicket
{
    // The token used to ensure the authentication attempt is valid.
    string Token
}

// Contains the result of a maintainer's authentication attempt.
global struct Spyglass_MaintainerAuthenticationResult
{
    Spyglass_ApiResult ApiResult

    // The authentication ticket that was created on success.
    Spyglass_MaintainerAuthenticationTicket ornull Ticket
}

// The result of an attempt to validate a maintainer's authentication token.
global struct Spyglass_MaintainerTicketValidationResult
{
    Spyglass_ApiResult ApiResult

    // Whether or not the authentication token is valid.
    bool IsValid
}

// A result of an attempt to issue a sanction to a player.
global struct Spyglass_SanctionIssueResult
{
    Spyglass_ApiResult ApiResult

    // The sanction that was issued to the player, if any.
    Spyglass_PlayerInfraction ornull IssuedSanction
}