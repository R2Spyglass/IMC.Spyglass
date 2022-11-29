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

// Details about a sanction that was issued to a player.
global struct Spyglass_PlayerInfraction
{
    // The unique id given to this player sanction.
    int ID 
    // The unique id (UID) of the player this sanction belongs to.
    string UniqueId
    // The unique id (UID) of the player who issued this sanction.
    string IssuerId
    // The unix timestamp seconds of the date & time the sanction was issued.
    int IssuedAtTimestamp
    // The date and time at which this sanction was issued, in a readable string format.
    string IssuedAtReadable
    // The unix timestamp seconds of the date & time this sanction expires, if any.
    // Null, empty or -1 means this sanction never expires.
    int ExpiresAtTimestamp
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