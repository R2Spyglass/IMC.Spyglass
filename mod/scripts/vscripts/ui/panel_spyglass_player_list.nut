global function Spyglass_InitScrollablePlayerList

global struct SpyglassPlayerList
{
    var list
    void functionref(var item) OnItemClicked = null
    array<entity> players = []
}

struct
{
    table< var, SpyglassPlayerList > lists
} file

SpyglassPlayerList function Spyglass_InitScrollablePlayerList( var list )
{
    SpyglassPlayerList ret
    ret.list = list
    // init the player array, do not update this array without updating the UI to match
    //ret.players = GetPlayerArray()

    foreach ( int index, var listItem in GetElementsByClassname( list, "ListItem" ) )
    {
        // add event handler for when the item is clicked
        Hud_AddEventHandler( listItem, UIE_CLICK, OnListItemClicked )
        Hud_SetWidth( listItem, Hud_GetWidth(list) )
        if (index < ret.players.len())
            Hud_SetText( listItem, ret.players[index].GetPlayerName() )
    }

    file.lists[list] <- ret
    return ret
}

void function OnListItemClicked( var button )
{
    // get the list itself and relevant data
    var parentList = Hud_GetParent( button )
    string scriptID = Hud_GetScriptID( button )
    SpyglassPlayerList listStruct = file.lists[listStruct] // this might crash

    // determine which list item index was clicked
}

