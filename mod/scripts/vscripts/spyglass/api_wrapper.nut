/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 */

// The mod version the API expects (latest mod version)
string ApiVersion; 
// The minimum mod version required to interact with the API. 
// If set and lower than the current version, all API calls will fail until you update!
string MinimumModVersion; 