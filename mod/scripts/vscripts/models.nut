global enum InfractionType
{
    ChatSpam, // The player has spammed chat with malicious intent.
    LightToxicity, // Insults/targeted harassment of one or more players, prolonged,
    HeavyToxicity, // Harassment based on a player's gender, sexuality, race, religion etc. Slurs included.
    Cheating, // Usage of external programs that provide unfair advantage to the player (aimbot, wallhack, speedhack etc.)
}

global struct PlayerInfraction
{
    // The type of infraction the player has committed.
    InfractionType Type
    // The date the infraction was added to the database, in human readable format.
    string Date
    // The Discord username of the user who issued the infraction in the database.
    string Issuer
    // The reason why this infraction was given to the user.
    string Reason
}