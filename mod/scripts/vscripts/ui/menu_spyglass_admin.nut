global function AddSpyglassAdminMenu

struct file {
    var menu
}

void function AddSpyglassAdminMenu()
{
    AddMenu( "SpyglassAdminMenu", $"resource/ui/menus/spyglass_admin.menu", InitSpyglassAdminMenu, "#SPYGLASS_ADMIN_MENU_TITLE" )
}

void function InitSpyglassAdminMenu()
{
    file.menu = GetMenu( "SpyglassAdminMenu" )
}
