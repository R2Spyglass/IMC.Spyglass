/**
 * This is the Spyglass API wrapper for this mod. 
 * Feel free to call functions in your own mods if required!
 * Try to be mindful of the backend however, as you'll potentially get ratelimited or blacklisted for abuse.
 * Controller: /authenticate
 *
 * A kind note about this file: this is for Spyglass administrators to authenticate as admins on your servers.
 * This "admin" status will only allow us to run commands if 'spyglass_maintainers_are_admins' is set to 1.
 * It is by default. The commands will generally just be grabbing UIDs of players (aka safe) and making your server refresh sanctions (also safe).
 * If you do not wish to allow us to do this, please add this to your server config: spyglass_maintainers_are_admins 0
 * Do note it will severely impact our ability to help your server in case of issues.

 * Do not run code here manually, it isn't useful and will just annoy the backend (please be nice to it).
 * Your server will automatically call some of the code here if a maintainer requests to authenticate.
 */

#if CLIENT
global function SpyglassApi_RequestAuthenticationTicket;
#endif

#if SERVER
global function SpyglassApi_ValidateAuthenticationToken;
#endif

#if CLIENT
void function SpyglassApi_OnRequestAuthenticationTicketSuccessful(HttpRequestResponse response, void functionref(Spyglass_MaintainerAuthenticationResult) callback)
{
    if (callback == null)
    {
        return;
    }

    Spyglass_MaintainerAuthenticationResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseMaintainerAuthenticationResult(decodedBody, data);
    }

    callback(data);
}

void function SpyglassApi_OnRequestAuthenticationTicketFailed(HttpRequestFailure failure, void functionref(Spyglass_MaintainerAuthenticationResult) callback)
{
    printt(format("[Spyglass] SpyglassApi_RequestAuthenticationTicket() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    if (callback == null)
    {
        return;
    }

    Spyglass_MaintainerAuthenticationResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    callback(data);
}

bool function SpyglassApi_RequestAuthenticationTicket(void functionref(Spyglass_MaintainerAuthenticationResult) callback)
{
    if (callback == null)
    {
        CodeWarning("[Spyglass] Attempted to request authentication ticket with no callback.");
        return false;
    }

    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/authenticate/request", Spyglass_GetApiHostname()));
    request.queryParameters["uniqueId"] <- [NSGetLocalPlayerUID()];

    void functionref(HttpRequestResponse) onSuccess = void function (HttpRequestResponse response) : (callback)
    {
        SpyglassApi_OnRequestAuthenticationTicketSuccessful(response, callback);
    }

    void functionref(HttpRequestFailure) onFailure = void function (HttpRequestFailure failure) : (callback)
    {
        SpyglassApi_OnRequestAuthenticationTicketFailed(failure, callback);
    }

    return SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure, true);
}
#endif

#if SERVER
void function SpyglassApi_OnValidateAuthenticationTokenSuccessful(HttpRequestResponse response, void functionref(Spyglass_MaintainerTicketValidationResult) callback)
{
    if (callback == null)
    {
        return;
    }

    Spyglass_MaintainerTicketValidationResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("API returned a non-200 status code: %i", response.statusCode);

    if (response.statusCode == 200)
    {
        table decodedBody = DecodeJSON(response.body);
        Spyglass_TryParseMaintainerTicketValidationResult(decodedBody, data);
    }

    callback(data);
}

void function SpyglassApi_OnValidateAuthenticationTokenFailed(HttpRequestFailure failure, void functionref(Spyglass_MaintainerTicketValidationResult) callback)
{
    printt(format("[Spyglass] SpyglassApi_ValidateAuthenticationToken() failed with error code %i: %s", failure.errorCode, failure.errorMessage));
    
    if (callback == null)
    {
        return;
    }

    Spyglass_MaintainerTicketValidationResult data;
    data.ApiResult.Success = false;
    data.ApiResult.Error = format("(%i) %s", failure.errorCode, failure.errorMessage);

    callback(data);
}

bool function SpyglassApi_ValidateAuthenticationToken(string uniqueId, string token, void functionref(Spyglass_MaintainerTicketValidationResult) callback)
{
    if (callback == null)
    {
        CodeWarning("[Spyglass] Attempted to validate authentication token with no callback.");
        return false;
    }

    HttpRequest request;
    request.method = HttpRequestMethod.GET;
    request.url = Spyglass_SanitizeUrl(format("%s/authenticate/validate", Spyglass_GetApiHostname()));
    request.queryParameters["uniqueId"] <- [uniqueId];
    request.queryParameters["token"] <- [token];

    void functionref(HttpRequestResponse) onSuccess = void function (HttpRequestResponse response) : (callback)
    {
        SpyglassApi_OnValidateAuthenticationTokenSuccessful(response, callback);
    }

    void functionref(HttpRequestFailure) onFailure = void function (HttpRequestFailure failure) : (callback)
    {
        SpyglassApi_OnValidateAuthenticationTokenFailed(failure, callback);
    }

    return SpyglassApi_MakeHttpRequest(request, onSuccess, onFailure, true);
}
#endif