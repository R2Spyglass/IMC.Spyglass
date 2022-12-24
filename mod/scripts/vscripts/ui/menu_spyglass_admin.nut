global function AddSpyglassAdminMenu
global function Spyglass_TryOpenAdminMenu
global function AddSpyglassFooterButton

void function Spyglass_TryOpenAdminMenu(var button)
{
    printt("OPENING MENU")
    AdvanceMenu( file.menu )
}

struct
{
    var menu
} file

void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
    
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

void function Spyglass_OnAdminMenuOpened()
{
    // set the UI presentation type for nicer visuals
    //UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )
    // dont move ui camera at all
    UI_SetPresentationType( ePresentationType.INACTIVE )

    Spyglass_InitScrollablePlayerList( Hud_GetChild( file.menu, "PlayerList" ) )
}

void function Spyglass_RefreshPlayerList( var button )
{
    // does nothing
}
