global function AddSpyglassAdminMenu

void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
}

void function InitSpyglassAdminMenu()
{
    // do nothing for now
}
