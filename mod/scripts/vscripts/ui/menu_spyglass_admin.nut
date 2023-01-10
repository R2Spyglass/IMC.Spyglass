global function AddSpyglassAdminMenu
global function Spyglass_TryOpenAdminMenu
global function AddSpyglassFooterButton
global function Spyglass_SetSelectedPlayer

global function Spyglass_AddCallback_OnSelectedPlayerChanged

struct
{
    var menu
    var panel
    bool hasCancelledAuth

    // holds the selected uid from the playerlist
    string selectedUID = ""
    array<void functionref(string uid, string name)> onSelectedPlayerChangedCallbacks = []

    array<var> tabPanels = []



    var playerListFrame
    var playerList
    var playerListScrollTop
    var playerListScrollBar
    var playerListScrollBottom
    var playerListScrollCapture
    int scrollMin
    int scrollMax
    int scrollbarMaxHeight
    int scrollbarMinHeight
} file

// CALLBACKS FROM MOD.JSON AND INITIALISATION STUFF
void function AddSpyglassAdminMenu()
{
    
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
    
    file.menu = GetMenu( "SpyglassAdminMenu" )
}

// this is in an "After" callback to hopefully add it to the end of the list instead of being the first one added
void function AddSpyglassFooterButton()
{
    // add footer button to in game pause menu
    AddMenuFooterOption( GetMenu( "InGameMPMenu" ), BUTTON_BACK, "#SPYGLASS_START_BUTTON_ADMIN_MENU", "#SPYGLASS_ADMIN_MENU", Spyglass_TryOpenAdminMenu )

    // add footer button to private lobby menu
    AddMenuFooterOption( GetMenu( "PrivateLobbyMenu" ), BUTTON_BACK, "#SPYGLASS_START_BUTTON_ADMIN_MENU", "#SPYGLASS_ADMIN_MENU", Spyglass_TryOpenAdminMenu )
}

void function InitSpyglassAdminMenu()
{
    // initialise the various UI members
    
    file.playerListFrame = Hud_GetChild( file.menu, "PlayerListFrame" )
    Spyglass_PlayerList_Init( file.playerListFrame )

    // add footer buttons
    AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
    AddMenuFooterOption( file.menu, BUTTON_Y, "#SPYGLASS_Y_BUTTON_REFRESH_PLAYERS", "#SPYGLASS_REFRESH_PLAYERS", Spyglass_RefreshPlayerList)
    AddMenuFooterOption( file.menu, BUTTON_X, "#SPYGLASS_X_BUTTON_REFRESH_SANCTIONS", "#SPYGLASS_REFRESH_SANCTIONS", void function(var button){ ClientCommand("spyglass_refreshsanctions true")})
    
    //AddMenuFooterOption( file.menu, BUTTON_X, "KICK PLAYER", "KICK PLAYER", void function(var button){ ClientCommand("spyglass_kickplayer " + file.selectedUID)})

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, Spyglass_OnAdminMenuOpened )
    
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
    foreach ( var elem in GetElementsByClassname(file.menu, "SpyglassAdminMenuTabPanel") )
    {
        HidePanel(elem)
    }

    var newPanel = file.tabPanels[index]
    printt("SHOWING NEW PANEL: " + Hud_GetHudName(newPanel))
    ShowPanel(newPanel)
}

void function SetSelectedTab(var button)
{
    foreach ( var elem in GetElementsByClassname(file.menu, "TabButton") )
    {
        Hud_SetSelected( elem, false )
    }
    Hud_SetSelected( button, true )
}

// AUTHENTICATION AND OPENING MENU CHECKS HERE

void function Spyglass_TryOpenAdminMenu(var button)
{
    // clear dialogs to avoid weirdness
    CloseAllDialogs()
    if ( !SpyglassUI_IsAuthenticated() ) // TODO - dialog for not authed
    {
        ShowAuthenticationDialogue()
        return
    }
    AdvanceMenu( file.menu )
}

void function ShowAuthenticationDialogue()
{
    DialogData dialogData
    EmitUISound( "blackmarket_purchase_fail" )
    dialogData.header = Localize( "#SPYGLASS_NOT_AUTHED" )
	dialogData.message = Localize( "#SPYGLASS_NOT_AUTHED_BODY" )
    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#SPYGLASS_TRY_AUTH", Spyglass_TryAuthAndOpenAdminMenu )
    AddDialogButton( dialogData, "#CANCEL" )

    OpenDialog( dialogData )
}

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

void function Spyglass_OnAdminMenuOpened()
{
    // set the UI presentation type for nicer visuals
    UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )
    // dont move ui camera at all
    //UI_SetPresentationType( ePresentationType.INACTIVE )

    // hide all of the panels
    foreach(var elem in GetElementsByClassname(file.menu, "SpyglassAdminMenuTabPanel"))
    {
        HidePanel(elem)
    }

    // show panel 0
    ShowPanel(file.tabPanels[0])

    // select first tab
    SetSelectedTab(GetElementsByClassname(file.menu, "TabButton")[0])
    
    Spyglass_RefreshPlayerList(null)
}

void function Spyglass_AddCallback_OnSelectedPlayerChanged(void functionref(string uid, string name) callback)
{
    file.onSelectedPlayerChangedCallbacks.append(callback)
}

// ACTUAL HANDLING THE MENU ONCE OPENED BELOW HERE

void function Spyglass_SetSelectedPlayer(string uid, string name)
{
    file.selectedUID = uid
    printt("SELECTED PLAYER WITH UID: " + uid)

    // run callbacks
    foreach (callback in file.onSelectedPlayerChangedCallbacks)
    {
        callback(uid, name)
    }
}
