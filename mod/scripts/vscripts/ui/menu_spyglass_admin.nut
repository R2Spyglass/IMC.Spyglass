global function AddSpyglassAdminMenu

struct
{
    var menu
} file

void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
}

void function InitSpyglassAdminMenu()
{
    file.menu = GetMenu( "SpyglassAdminMenu" )

    // add footer buttons
    AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}
