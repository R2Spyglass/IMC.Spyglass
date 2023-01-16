untyped

global function AddSpyglassAdminMenu
global function Spyglass_TryOpenAdminMenu
global function AddSpyglassFooterButton
global function Spyglass_SetSelectedPlayer
global function Spyglass_UpdateInfractionCache
global function Spyglass_GetInfractionsForUID

global function Spyglass_AddCallback_OnSelectedPlayerChanged

struct
{
    var menu
    var panel
    bool hasCancelledAuth

    // holds the selected uid from the playerlist
    string selectedUID = ""
    string selectedName = ""
    array< void functionref( string uid, string name ) > onSelectedPlayerChangedCallbacks = []

    array<var> tabPanels = []

    table< string, array<Spyglass_PlayerInfraction> > cachedInfractions = {}

    var playerListFrame

    var searchPlayerListFrame
    var searchBar
    var searchButton
    var searchSpinner
    var searchSpinnerLabel
    table< string, string > cachedSearchResult = {}
} file

// Adds the menu to the UI
void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
    file.menu = GetMenu( "SpyglassAdminMenu" )
}

// adds the menu footer button to various menus, used to access the menu
// this is in an "After" callback to add it to the end of the footer list instead of being the first one added
void function AddSpyglassFooterButton()
{
    // add footer button to in game pause menu
    AddMenuFooterOption( GetMenu( "InGameMPMenu" ), BUTTON_BACK, "#SPYGLASS_START_BUTTON_ADMIN_MENU", "#SPYGLASS_ADMIN_MENU", Spyglass_TryOpenAdminMenu )

    // add footer button to private lobby menu
    AddMenuFooterOption( GetMenu( "PrivateLobbyMenu" ), BUTTON_BACK, "#SPYGLASS_START_BUTTON_ADMIN_MENU", "#SPYGLASS_ADMIN_MENU", Spyglass_TryOpenAdminMenu )
}

// various initialisation things for the main admin menu
void function InitSpyglassAdminMenu()
{
    // initialise the various UI members
    file.playerListFrame = Hud_GetChild( file.menu, "PlayerListFrame" )
    file.searchPlayerListFrame = Hud_GetChild( file.menu, "SearchPlayerListFrame" )
    Spyglass_PlayerList_Init( "currentPlayers", file.playerListFrame, SpyglassUI_GetPlayerIdentities )
    Spyglass_PlayerList_Init( "searchedPlayers", file.searchPlayerListFrame, Spyglass_GetSearchedPlayersCache )

    file.searchBar = Hud_GetChild( file.menu, "SearchBar" )
    file.searchButton = Hud_GetChild( file.menu, "SearchButton" )
    file.searchSpinner = Hud_GetChild( file.menu, "SearchAnimation" )
    file.searchSpinnerLabel = Hud_GetChild( file.menu, "SearchLabel" )

    RegisterButtonPressedCallback( KEY_ENTER, OnEnterPressed )

    // add footer buttons to the admin menu
    AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
    AddMenuFooterOption( file.menu, BUTTON_Y, "#SPYGLASS_Y_BUTTON_REFRESH_PLAYERS", "#SPYGLASS_REFRESH_PLAYERS", Spyglass_RefreshPlayerList )
    AddMenuFooterOption( file.menu, BUTTON_X, "#SPYGLASS_X_BUTTON_REFRESH_SANCTIONS", "#SPYGLASS_REFRESH_SANCTIONS", Spyglass_RefreshSanctions )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, Spyglass_OnAdminMenuOpened )

    Hud_AddEventHandler( file.searchButton, UIE_CLICK, Spyglass_SearchButton_OnClick )
    
    // handles tab button presses
    AddEventHandlerToButtonClass( file.menu, "TabButton", UIE_CLICK, ShowTabPanelFromButton )

    // ADD SANCTION PANEL TAB THINGS
    AddPanel( file.menu, "AddSanctionPanel", Spyglass_InitAddSanctionPanel )
    file.tabPanels.append( GetPanel("AddSanctionPanel") )
    var rui = Hud_GetRui( Hud_GetChild(file.menu, "Tab0") )
	RuiSetString( rui, "buttonText", "#SPYGLASS_ADD_SANCTION" )

    // VIEW SANCTIONS PANEL TAB THINGS
    AddPanel( file.menu, "ViewSanctionsPanel", Spyglass_InitViewSanctionsPanel )
    file.tabPanels.append( GetPanel("ViewSanctionsPanel") )
    rui = Hud_GetRui( Hud_GetChild(file.menu, "Tab1") )
	RuiSetString( rui, "buttonText", "#SPYGLASS_VIEW_SANCTIONS" )
}

// uses a button's scriptID to show the correct panel, bit hacky but it works
void function ShowTabPanelFromButton(var button)
{
    SetSelectedTab(button)
    int index = int( Hud_GetScriptID(button) )
    
    // hide all of the panels
    foreach ( var elem in GetElementsByClassname( file.menu, "SpyglassAdminMenuTabPanel" ) )
    {
        HidePanel(elem)
    }

    var newPanel = file.tabPanels[index]
    printt( "SHOWING NEW PANEL: " + Hud_GetHudName(newPanel) )
    ShowPanel(newPanel)
}

// sets the selected tab button, to indicate which menu is currently being selected
void function SetSelectedTab(var button)
{
    // deselect all tab buttons, clear selection
    foreach ( var elem in GetElementsByClassname( file.menu, "TabButton" ) )
    {
        Hud_SetSelected( elem, false )
    }

    // select the chosen tab buttons
    Hud_SetSelected( button, true )
}

// AUTHENTICATION AND OPENING MENU CHECKS HERE

// checks if the user is currently authenticated, and prompts them to authenticate if needed
void function Spyglass_TryOpenAdminMenu(var button)
{
    // clear dialogs to avoid weirdness
    CloseAllDialogs()
    if ( !SpyglassUI_IsAuthenticated() )
    {
        ShowAuthenticationDialogue()
        return
    }
    AdvanceMenu( file.menu )
}

// shows a dialog prompting the user to authenticate
void function ShowAuthenticationDialogue()
{
    DialogData dialogData
    EmitUISound( "blackmarket_purchase_fail" )
    dialogData.header = Localize( "#SPYGLASS_NOT_AUTHED" )
	dialogData.message = Localize( "#SPYGLASS_NOT_AUTHED_BODY" )
    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#SPYGLASS_TRY_AUTH", Spyglass_TryAuthAndOpenAdminMenu )
    AddDialogButton( dialogData, "#SPYGLASS_SKIP_AUTH", void function(){ AdvanceMenu( file.menu ) } )
    AddDialogButton( dialogData, "#CANCEL" )

    OpenDialog( dialogData )
}

// tries to authenticate with spyglass using spyglass_authenticate, before opening the admin menu
void function Spyglass_TryAuthAndOpenAdminMenu()
{
    DialogData dialogData
    dialogData.menu = GetMenu( "ConnectingDialog" )
    dialogData.header = Localize( "#SPYGLASS_AUTHENTICATING" )
	dialogData.showSpinner = true

    AddDialogButton( dialogData, "#CANCEL", void function(){ file.hasCancelledAuth = true } )
    
    ClientCommand("spyglass_authenticate")

    thread Spyglass_TryAuthAndOpenAdminMenu_Threaded()
    OpenDialog( dialogData )
}

// waits for either a cancellation of the authentication attempt, or a response from the server
// before showing the admin menu or another dialog
void function Spyglass_TryAuthAndOpenAdminMenu_Threaded()
{
    while ( !file.hasCancelledAuth && !SpyglassUI_IsAuthenticated() )
    {
        WaitFrame()
    }

    if ( file.hasCancelledAuth )
    {
        // do nothing except reset file.hasCancelledAuth, auth was cancelled
        file.hasCancelledAuth = false 
    }
    else if ( SpyglassUI_IsAuthenticated() )
    {
        // try to open the admin menu (again)
        Spyglass_TryOpenAdminMenu(null) 
    }
    else
    {
        // auth failed and wasn't cancelled
        // currently this doesn't get hit, as server doesn't send anything other than a chat message when auth fails for whatever reason
        ShowAuthenticationDialogue() 
    }
}

// actually handles opening the admin menu, after authentication
void function Spyglass_OnAdminMenuOpened()
{
    // set the UI presentation type for nicer visuals
    UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )
    // dont move ui camera at all
    //UI_SetPresentationType( ePresentationType.INACTIVE )

    // hide all of the panels
    foreach( var elem in GetElementsByClassname( file.menu, "SpyglassAdminMenuTabPanel" ) )
    {
        HidePanel(elem)
    }

    // show panel 0
    ShowPanel(file.tabPanels[0])

    // select first tab
    SetSelectedTab( GetElementsByClassname( file.menu, "TabButton" )[0] )
    
    // refresh the playerlist to get an up to date list
    Spyglass_RefreshPlayerList(null)
}

// callbacks for the different panels
void function Spyglass_AddCallback_OnSelectedPlayerChanged( void functionref( string uid, string name ) callback )
{
    file.onSelectedPlayerChangedCallbacks.append(callback)
}

// sets the selected player, and runs callbacks
void function Spyglass_SetSelectedPlayer( string uid, string name )
{
    file.selectedUID = uid
    file.selectedName = name
    printt("SELECTED PLAYER WITH UID: " + uid)

    // run callbacks
    foreach ( callback in file.onSelectedPlayerChangedCallbacks )
    {
        callback( uid, name )
    }
}

// updates the infraction cache on UI
void function Spyglass_UpdateInfractionCache( table< string, array<Spyglass_PlayerInfraction> > newCache )
{
    printt("UPDATING INFRACTION CACHE")
    file.cachedInfractions = clone newCache
    // simulate a change in selected player to make other UI update nicely
    Spyglass_SetSelectedPlayer( file.selectedUID, file.selectedName )
}

// gets cached infractions for a player using their UID
// returns an empty array if the player has no infractions
array<Spyglass_PlayerInfraction> function Spyglass_GetInfractionsForUID(string uid)
{
    if ( !(uid in file.cachedInfractions) )
        return []

    return clone file.cachedInfractions[uid]
}

// gets the cached searched players
table<string, string> function Spyglass_GetSearchedPlayersCache()
{
    return clone file.cachedSearchResult
}

// makes an API call if the search is valid, searching spyglass for players by username
void function Spyglass_SearchButton_OnClick(var button)
{
    // the flow for this is as follows:
    // make API call
    // show spinner thing
    // wait for API call return
    // parse API result
    // set file.cachedSearchResult
    // use Spyglass_RefreshPlayerList to update player lists and sanctions and such

    // dont send with an empty name
    if ( strip(Hud_GetUTF8Text(file.searchBar)).len() == 0 )
        return
    
    // show the spinner while searching
    Hud_SetVisible( file.searchSpinner, true )
    Hud_SetVisible( file.searchSpinnerLabel, true )

    // clear previously searched players
    file.cachedSearchResult = {}
    Spyglass_RefreshPlayerList(null)

    HttpRequest request
    request.method = HttpRequestMethod.GET
    request.url = Spyglass_SanitizeUrl( format( "%s/players/lookup_name", Spyglass_GetApiHostname() ) )
    request.queryParameters["username"] <- [Hud_GetUTF8Text(file.searchBar)]
    
    SpyglassApi_MakeHttpRequest( request, OnSuccess, OnFailure, true )
}

// callback for successfull API call for player search
void function OnSuccess(HttpRequestResponse response)
{
    // hide the spinner, search is complete
    Hud_SetVisible( file.searchSpinner, false )
    Hud_SetVisible( file.searchSpinnerLabel, false )

    printt("HTTP REQUEST SUCCESS")
    printt("STATUS CODE: " + response.statusCode)
    printt("BODY: " + response.body)

    if ( response.statusCode != 200 )
    {
        ShowSearchFailureDialog("Status code was " + response.statusCode + "\nCheck the console for more details.")
        return
    }

    //printt("RAW HEADERS: " + response.rawHeaders)
    table temp = DecodeJSON(response.body)

    table<string, string> tempIdentities = {}

    if ( !("success" in temp && expect bool(temp["success"])) )
    {
        printt("'success' was not present or was false")
        if ("error" in temp && typeof temp["error"] == "string")
        {
            ShowSearchFailureDialog(expect string(temp["error"]))
        }
        else
        {
            ShowSearchFailureDialog("Failed to parse response: 'success' was not present or was false")
        }
        return
    }

    if ( !("matches" in temp) )
    {
        printt("'matches' was not present")
        ShowSearchFailureDialog("Failed to parse response: 'matches' was not present")
        return
    }

    foreach ( var matches in temp["matches"] )
    {
        if ( !("uniqueID" in matches && typeof matches["uniqueID"] == "string") )
        {
            printt("'uniqueID' was not present or wasn't a string")
            ShowSearchFailureDialog("Failed to parse match: 'uniqueID' was not present or wasn't a string")
            return
        }

        if ( !("username" in matches && typeof matches["username"] == "string") )
        {
            printt("'username' was not present or wasn't a string")
            ShowSearchFailureDialog("Failed to parse match: 'username' was not present or wasn't a string")
            return
        }
        tempIdentities[expect string(matches["uniqueID"])] <- expect string(matches["username"])
    }

    foreach ( string uid, string name in tempIdentities )
    {
        printt(uid + ": " + name)
    }

    file.cachedSearchResult = tempIdentities

    Spyglass_RefreshPlayerList(null)
}

// callback for failed API call for player search
void function OnFailure(HttpRequestFailure res)
{
    Hud_SetVisible(file.searchSpinner, false)
    Hud_SetVisible(file.searchSpinnerLabel, false)
    printt("REQUEST FAILURE")
    // show failure dialog

    ShowSearchFailureDialog(res.errorMessage)
}

// shows a dialog, indicating a failed player search
void function ShowSearchFailureDialog(string error)
{
    // clear dialogs to avoid weirdness
    CloseAllDialogs()
    EmitUISound( "blackmarket_purchase_fail" )
    DialogData dialogData
    dialogData.header = Localize( "#SPYGLASS_SEARCH_FAILURE" )
	dialogData.message = Localize( "#SPYGLASS_SEARCH_FAILURE_BODY", error )
    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#OK" )

    OpenDialog( dialogData )
}

// callback for when the enter key is pressed
// simulates a search button press if the text box has focus
// pressing enter is nice for text entry boxes
void function OnEnterPressed(var arg)
{
    if ( GetFocus() == file.searchBar )
    {
        EmitUISound("Menu.Accept")
        Spyglass_SearchButton_OnClick(null)
    }
}


