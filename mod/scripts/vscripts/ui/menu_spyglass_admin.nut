global function AddSpyglassAdminMenu
global function Spyglass_TryOpenAdminMenu
global function AddSpyglassFooterButton

struct
{
    var menu
    bool hasCancelledAuth
} file

// CALLBACKS FROM MOD.JSON AND INITIALISATION STUFF
void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
    //AddServerToClientStringCommandCallback("spyglass_authenticated", AddSpyglassFooterButton)
}

void function AddSpyglassFooterButton()
{
    // add footer button to in game pause menu
    // this is in an "After" callback to hopefully add it to the end of the list instead of being the first one added
    AddMenuFooterOption( GetMenu( "InGameMPMenu" ), BUTTON_Y, "#SPYGLASS_Y_BUTTON_ADMIN_MENU", "#SPYGLASS_ADMIN_MENU", Spyglass_TryOpenAdminMenu )
}

void function InitSpyglassAdminMenu()
{
    file.menu = GetMenu( "SpyglassAdminMenu" )

    // add footer buttons
    AddMenuFooterOption( file.menu, BUTTON_B, "#REFRESH_SERVERS", "#REFRESH_SERVERS", Spyglass_RefreshPlayerList )
    AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

    // add open callback
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, Spyglass_OnAdminMenuOpened )
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
    //EmitUISound( "blackmarket_purchase_fail" )
    dialogData.header = Localize( "#SPYGLASS_NOT_AUTHED" )
	dialogData.message = Localize( "#SPYGLASS_NOT_AUTHED_BODY" )
    dialogData.image = $"ui/menu/common/dialog_error"
    dialogData.noChoiceWithNavigateBack = true

    AddDialogButton( dialogData, "#OK" )
    AddDialogButton( dialogData, "#SPYGLASS_TRY_AUTH", Spyglass_TryAuthAndOpenAdminMenu )

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

    Spyglass_InitScrollablePlayerList( Hud_GetChild( file.menu, "PlayerList" ) )
}

// ACTUAL HANDLING THE MENU ONCE OPENED BELOW HERE

void function Spyglass_RefreshPlayerList( var button )
{
    // does nothing
}
