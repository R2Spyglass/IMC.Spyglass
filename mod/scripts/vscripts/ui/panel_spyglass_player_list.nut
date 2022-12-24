global function Spyglass_InitScrollablePlayerList
global function Spyglass_RefreshScrollablePlayerList

global struct SpyglassPlayerList
{
    var list
    void functionref(var item) OnItemClicked = null
    // a snapshot of the currently tracked players when the list is initialised
    // this table does not update when a player joins/leaves, only when told to refresh specifically
    // this prevents weird problems happening with incorrect indices and all that
    // table key is a UID, value is a username
    table<string, string> players = {}

    // scrolling variables

    // the offset into table indices used for clicking things
    int tableOffset = 0
    // the actual visible offset of the UI element
    float posOffset = 0
}

struct
{
    table< var, SpyglassPlayerList > lists
} file

SpyglassPlayerList function Spyglass_InitScrollablePlayerList( var list )
{
    SpyglassPlayerList ret
    ret.list = list
    // init the player array, clone to avoid ref bullshit
    ret.players = clone SpyglassUI_GetPlayerIdentities()

    // apparently i can only use this on the menu, and then check 
    array< var > menuListItems = GetElementsByClassname( GetParentMenu(list), "ListItem" )
    // use this later instead of the above
    array< var > listItems = []
    foreach ( var listItem in menuListItems )
    {
        if ( Hud_GetParent(listItem) != list )
            continue
        Hud_SetWidth( listItem, Hud_GetWidth(list) )
        Hud_Hide( listItem )
        // add event handler for when the item is clicked
        Hud_AddEventHandler( listItem, UIE_CLICK, OnListItemClicked )
        listItems.append(listItem)
    }
    int index = 0
    // initialises the list items
    foreach ( string uid, string name in ret.players )
    {
        if (index < listItems.len())
        {
            var listItem = listItems[index]
            Hud_SetText( listItem, name )
            Hud_Show( listItem )
        }
        index++
    }

    // initialise the 

    file.lists[list] <- ret
    return ret
}

void function Spyglass_RefreshScrollablePlayerList( var list )
{
    if (!list in file.lists)
        return
    

}

void function OnListItemClicked( var button )
{
    // get the list itself and relevant data
    var parentList = Hud_GetParent( button )
    string scriptID = Hud_GetScriptID( button )
    //SpyglassPlayerList listStruct = file.lists[listStruct] // this might crash

    // determine which list item index was clicked
}

