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

// Type of notification type for muted players trying to chat.
global enum Spyglass_MuteNotificationType
{
    // The message is blocked, with no notice from Spyglass.
    Block = 0,
    // The message is blocked, Spyglass notifies the user.
    Notify = 1, 
    // The message is blocked, but sent back to the player. Only they can see it.
    Shadowban = 2, 
}

// Notification modes for sanctions when a sanctionned player joins the server, or gets sanctionned.
global enum Spyglass_SanctionNotificationMode
{
    // No sanction notification whatsoever for anyone.
    None = 0,
    // Only the sanctioned player will see the notification.
    PlayerOnly = 1,
    // Only the sanctioned player and online admins will see the notification.
    PlayerAndAdmins = 2,
    // Only server admins will see the sanction notification.
    AdminsOnly = 3,
    // Everyone will see the notification.
    Everyone = 4,
}

global enum Spyglass_AuthenticationResult 
{
    NotAdmin,
    AuthenticationDisabled,
    WrongPassword,
    InvalidPlayer,
    AlreadyAuthenticated,
    Success,
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