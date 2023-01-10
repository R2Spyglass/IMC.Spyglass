global function Spyglass_InitAddSanctionPanel

struct {
    var panel

    // UI MEMBERS AND USEFUL VARS
    var infractionTypeButton
    var sanctionTypeButton
    var reasonTextBox
    var durationTextBox
    var applySanctionButton

    // NEW SANCTION INFORMATION
    // uid of the player being sanctioned, issuer uid will just use NSGetLocalPlayerUID()
    string uid = ""
    string username = ""
    // type of infraction, matches Spyglass_InfractionType
    int infractionType = 0
    // type of sanction, matches Spyglass_SanctionType
    int sanctionType = 0
    // the reason for the sanction
    string reason = ""
    // the time in minutes for the punishment, with 0 being permanent
    int duration = 0
} file

void function Spyglass_InitAddSanctionPanel()
{
    file.panel = GetPanel("AddSanctionPanel")
    AddPanelEventHandler( file.panel, eUIEvent.PANEL_SHOW, OnShowAddSanctionPanel )
    Spyglass_AddCallback_OnSelectedPlayerChanged(OnSelectedPlayerChanged)

    // this matches the Spyglass_InfractionType enum
    var infractionTypeButton = Hud_GetChild( file.panel, "SelectInfraction")
    Hud_DialogList_AddListItem( infractionTypeButton, "Spamming", "0" )
    Hud_DialogList_AddListItem( infractionTypeButton, "Harassment", "1" )
    Hud_DialogList_AddListItem( infractionTypeButton, "Hate Speech", "2" )
    Hud_DialogList_AddListItem( infractionTypeButton, "Griefing", "3" )
    Hud_DialogList_AddListItem( infractionTypeButton, "Exploiting", "4" )
    Hud_DialogList_AddListItem( infractionTypeButton, "Cheating", "5" )
    SetButtonRuiText(infractionTypeButton, "Infraction Type")
    Hud_AddEventHandler( infractionTypeButton, UIE_CLICK, void function(var button)
    {
        file.infractionType = Hud_GetDialogListSelectionValue( button ).tointeger()
        TryUnlockApplySanctionButton()
    } )
    file.infractionTypeButton = infractionTypeButton

    // this matches the Spyglass_SanctionType enum
    var sanctionTypeButton = Hud_GetChild( file.panel, "SelectSanction")
    Hud_DialogList_AddListItem( sanctionTypeButton, "Warning", "0" )
    Hud_DialogList_AddListItem( sanctionTypeButton, "Mute", "1" )
    Hud_DialogList_AddListItem( sanctionTypeButton, "Ban", "2" )
    SetButtonRuiText(sanctionTypeButton, "Sanction Type")
    Hud_AddEventHandler( sanctionTypeButton, UIE_CLICK, void function(var button)
    {
        file.sanctionType = Hud_GetDialogListSelectionValue( button ).tointeger()
        TryUnlockApplySanctionButton()
    } )
    file.sanctionTypeButton = sanctionTypeButton

    // duration box handling
    var durationTextBox = Hud_GetChild( file.panel, "DurationTextBox")
    Hud_SetUTF8Text(durationTextBox, "0")
    AddButtonEventHandler( durationTextBox, UIE_CHANGE, void function(var button)
    {
        file.duration = Hud_GetUTF8Text( button ).tofloat().tointeger()
        TryUnlockApplySanctionButton()
    } )

    // reason box handling
    var reasonTextBox = Hud_GetChild( file.panel, "ReasonTextBox")
    AddButtonEventHandler( reasonTextBox, UIE_CHANGE, void function(var button)
    {
        file.reason = Hud_GetUTF8Text( button )
        TryUnlockApplySanctionButton()
    } )

    // add callback for apply sanction button
    var applySanctionButton = Hud_GetChild( file.panel, "ApplySanction" )
    Hud_AddEventHandler( applySanctionButton, UIE_CLICK, ShowApplySanctionDialogue )
    file.applySanctionButton = applySanctionButton


    TryUnlockApplySanctionButton() // this will basically just lock it at this stage but yeah
}

void function OnShowAddSanctionPanel()
{
    printt("LOCAL UID: " + NSGetLocalPlayerUID())
    TryUnlockApplySanctionButton()
}

void function OnSelectedPlayerChanged(string uid, string name)
{
    file.uid = uid
    file.username = name
    print("SELECTED UID: " + uid)
    TryUnlockApplySanctionButton()
}

// locks/unlocks the button after validating the new sanction information
void function TryUnlockApplySanctionButton()
{
    Hud_SetEnabled( file.applySanctionButton, ValidateSanctionFields() )
}

// validates the new sanction information
bool function ValidateSanctionFields()
{
    // only check for empty uid for now, eventually check for admin and stuff?
    if ( file.uid == "" )
        return false

    // this will need changing if new infraction types are created
    if ( file.infractionType < 0 || file.infractionType > 5 )
        return false

    // this will need changing if new sanction types are created
    if ( file.sanctionType < 0 || file.sanctionType > 2 )
        return false

    // no empty reasons, thanks
    if ( file.reason == "" )
        return false
    
    // duration of 0 means infinite duration, but negative is wrong and bad
    if ( file.duration < 0 )
        return false
    
    return true
}

// DIALOGUE AND HTTP THINGS

void function ShowApplySanctionDialogue(var button)
{
    DialogData dialogData
    dialogData.header = Localize( "#SPYGLASS_ARE_YOU_SURE" )

    // TODO - make it so i can get a string value just from the enum, not only from an actual infraction struct (Spyglass_GetInfractionAsString)
	dialogData.message = Localize( "#SPYGLASS_ARE_YOU_SURE_BODY", 
    file.username,
    file.uid,
    ["Spamming", "Harassment", "Hate Speech", "Griefing", "Exploiting", "Cheating"][file.infractionType],
    ["Warning", "Mute", "Ban"][file.sanctionType],
    (file.duration == 0) ? Localize("#SPYGLASS_DURATION_PERMANENT") : Localize("#SPYGLASS_DURATION_MINUTES", file.duration),
    file.reason)

    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#GENERATION_RESPAWN_CONFIRM_BUTTON_1", SendSanctionRequest )
    AddDialogButton( dialogData, "#CANCEL" )

    OpenDialog( dialogData )
}

void function SendSanctionRequest()
{
    ShowSendingSanctionDialogue()
    HttpRequest request
    request.method = HttpRequestMethod.POST
    request.url = Spyglass_SanitizeUrl(format("%s/sanctions/add_sanction", Spyglass_GetApiHostname()))
    // queryParameters have to be strings, so i cant send integer values
    // which fucking sucks, and means i have to form my json myself with strings
    /*request.queryParameters["uniqueId"] <- [file.uid]
    request.queryParameters["issuerId"] <- [NSGetLocalPlayerUID()]
    request.queryParameters["expiresIn"] <- [file.duration.tostring()]
    request.queryParameters["reason"] <- [file.reason]
    request.queryParameters["type"] <- [file.infractionType.tostring()]
    request.queryParameters["punishmentType"] <- [file.sanctionType.tostring()]*/
    
    // todo, remove this when queryParameters works with non-string values
    request.body = "{\"uniqueId\": \"" + file.uid
    request.body += "\",\"issuerId\": \"" + NSGetLocalPlayerUID()
    request.body += "\",\"expiresIn\": " + file.duration
    request.body += ",\"reason\": \"" + file.reason
    request.body += "\",\"type\": " + file.infractionType
    request.body += ",\"punishmentType\": " + file.sanctionType
    request.body += "}"
    
    SpyglassApi_MakeHttpRequest(request, OnSuccess, OnFailure, true)
}

void function ShowSendingSanctionDialogue()
{
    DialogData dialogData
    dialogData.menu = GetMenu( "ConnectingDialog" )
    dialogData.header = Localize( "#SPYGLASS_SENDING_SANCTION" )
	dialogData.showSpinner = true

    OpenDialog( dialogData )
}

void function OnSuccess(HttpRequestResponse res)
{
    printt("HTTP REQUEST SUCCESS")
    printt("STATUS CODE: " + res.statusCode)
    printt("BODY: " + res.body)
    printt("RAW HEADERS: " + res.rawHeaders)
    table temp = DecodeJSON(res.body)
    Spyglass_SanctionIssueResult parsedRes
    if (Spyglass_TryParseSanctionIssueResult(temp, parsedRes))
    {
        if (parsedRes.ApiResult.Success)
            ShowSanctionSuccessDialogue()
        else
            ShowSanctionFailureDialogue(parsedRes.ApiResult.Error)
    }
    else
    {
        ShowSanctionFailureDialogue("Failed to parse Spyglass_SanctionIssueResult, this is probably a bug")
    }
}

void function OnFailure(HttpRequestFailure res)
{
    ShowSanctionFailureDialogue(res.errorMessage)
}

void function ShowSanctionSuccessDialogue()
{
    // clear dialogs to avoid weirdness
    CloseAllDialogs()
    EmitUISound( "UI_Menu_Item_Purchased_Stinger" )
    DialogData dialogData
    dialogData.header = Localize( "#SPYGLASS_SANCTION_SUCCESS" )
	dialogData.message = Localize( "#SPYGLASS_SANCTION_SUCCESS_BODY" )
    //dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#OK" )

    OpenDialog( dialogData )
}

void function ShowSanctionFailureDialogue(string error)
{
    // clear dialogs to avoid weirdness
    CloseAllDialogs()
    EmitUISound( "blackmarket_purchase_fail" )
    DialogData dialogData
    dialogData.header = Localize( "#SPYGLASS_SANCTION_FAILURE" )
	dialogData.message = Localize( "#SPYGLASS_SANCTION_FAILURE_BODY", error )
    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#OK" )

    OpenDialog( dialogData )
}
