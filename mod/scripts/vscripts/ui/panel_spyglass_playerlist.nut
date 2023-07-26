untyped //Hud_GetPos has forced my hand

global function Spyglass_PlayerList_Init
global function Spyglass_RefreshPlayerList
global function Spyglass_RefreshSanctions

const int SCROLLBAR_BUTTON_SCROLL_DISTANCE = 5
const int SCROLLBAR_MEMBER_HEIGHT = 50

const int BACKGROUND_DEFAULT_R = 30
const int BACKGROUND_DEFAULT_G = 35
const int BACKGROUND_DEFAULT_B = 35
const int BACKGROUND_DEFAULT_A = 75

const int BACKGROUND_FOCUS_R = 210
const int BACKGROUND_FOCUS_G = 210
const int BACKGROUND_FOCUS_B = 210
const int BACKGROUND_FOCUS_A = 200

const int NAME_DEFAULT_R = 255
const int NAME_DEFAULT_G = 255
const int NAME_DEFAULT_B = 255
const int NAME_DEFAULT_A = 255

const int NAME_SELECTED_R = 255
const int NAME_SELECTED_G = 255
const int NAME_SELECTED_B = 150
const int NAME_SELECTED_A = 255

struct PlayerListStruct
{
    var menu

    var listFrame
    var playerList
    var playerListScrollTop
    var playerListScrollBar
    var playerListScrollBottom
    var playerListScrollCapture

    // y positions
    int scrollMin
    int scrollMax

    int scrollbarScrollScale = 1
    int scrollbarMaxHeight
    int scrollbarMinHeight

    int scrollbarTotalContentsHeight = 0

    // table< uid, name >
    table< string, string > playerIdentities

    table< string, string > functionref() getIdentitiesCallback 

    // used to convert an index (int) into a uid (string) for indexing into playerIdentities
    array<string> uids = []
}

struct
{
    table< string, PlayerListStruct > lists

} file


void function Spyglass_PlayerList_Init( string id, var playerListFrame, table< string, string > functionref() getIdentitiesCallback )
{
    if (id in file.lists)
        return

    PlayerListStruct list
    
    list.menu = GetParentMenu( playerListFrame )
    list.listFrame = playerListFrame
    list.playerList = Hud_GetChild( playerListFrame, "PlayerList" )
    list.playerListScrollTop = Hud_GetChild( playerListFrame, "ScrollTop" )
    list.playerListScrollBar = Hud_GetChild( playerListFrame, "ScrollBar" )
    list.playerListScrollBottom = Hud_GetChild( playerListFrame, "ScrollBottom" )
    list.playerListScrollCapture = Hud_GetChild( playerListFrame, "ScrollCapture" )
    list.scrollMin = Hud_GetAbsY( list.playerListScrollCapture )
    list.scrollMax = list.scrollMin + Hud_GetHeight( list.playerListScrollCapture )
    list.scrollbarMaxHeight = Hud_GetHeight( list.playerListScrollBar )
    list.scrollbarMinHeight = 86 // this seems reasonable

    list.getIdentitiesCallback = getIdentitiesCallback

    // simulate mouse movements, arbitrary values for now
    Hud_AddEventHandler( list.playerListScrollTop, UIE_CLICK, void function(var button) : (id)
    {
        PlayerList_MouseMovementHandler(id, 0, -SCROLLBAR_BUTTON_SCROLL_DISTANCE)
    } )
    Hud_AddEventHandler( list.playerListScrollBottom, UIE_CLICK, void function(var button) : (id)
    {
        PlayerList_MouseMovementHandler(id, 0, SCROLLBAR_BUTTON_SCROLL_DISTANCE)
    } )

    // event handlers to deal with weird capture handler bullshit
    Hud_AddEventHandler( list.playerListScrollBar, UIE_GET_FOCUS, void function(var button) : (list)
    {
        Hud_SetVisible( list.playerListScrollCapture, true )
    } )
    Hud_AddEventHandler( list.playerListScrollBar, UIE_LOSE_FOCUS, void function(var button) : (list)
    {
        Hud_SetVisible( list.playerListScrollCapture, false )
    } )
    
    //array<var> function GetChildElementsByClassname( var parentElem, string classname )
    foreach ( var button in GetChildElementsByClassname(list.playerList, "Button") )
    {
        Hud_AddEventHandler( button, UIE_GET_FOCUS, void function(var button) : (id)
        {
            Spyglass_PlayerListButton_OnGetFocus(id, button)
        } )

        Hud_AddEventHandler( button, UIE_LOSE_FOCUS, void function(var button) : (id)
        {
            Spyglass_PlayerListButton_OnLoseFocus(id, button)
        } )

        Hud_AddEventHandler( button, UIE_CLICK, void function(var button) : (id)
        {
            Spyglass_PlayerListButton_OnClick(id, button)
        } )
    }

    AddMouseMovementCaptureHandler( list.playerListScrollCapture, void function(int deltaX, int deltaY) : (id)
    {
        PlayerList_MouseMovementHandler(id, deltaX, deltaY)
    } )

    file.lists[id] <- list
}

void function PlayerList_MouseMovementHandler( string id, int deltaX, int deltaY )
{
    // get scrollbar struct
    PlayerListStruct list = file.lists[id]
    // fix deltaY to bounds of scroll bar
    int y = Hud_GetAbsY( list.playerListScrollBar ) + deltaY
    //printt( y + " -> " + (y + Hud_GetHeight(list.playerListScrollBar)) )
    if ( y < list.scrollMin ) y = list.scrollMin
    if ( y + Hud_GetHeight(list.playerListScrollBar) > list.scrollMax ) y = list.scrollMax - Hud_GetHeight(list.playerListScrollBar)
    //printt(y)
    deltaY = y - Hud_GetAbsY( list.playerListScrollBar )


    Hud_SetPos( list.playerListScrollBar, 0, Hud_GetPos(list.playerListScrollBar)[1] + deltaY )
    Hud_SetPos( list.playerList, 0, Hud_GetPos(list.playerList)[1] + (deltaY * list.scrollbarScrollScale) )
}

void function Spyglass_RefreshPlayerList( var button )
{

    foreach (string id, PlayerListStruct list in file.lists)
    {
        list.playerIdentities = list.getIdentitiesCallback()
        list.uids = []
        printt("---- " + id + " ----")
        // construct array of uids to use to index into table
        foreach (string uid, string name in list.playerIdentities)
        {
            list.uids.append(uid)
            printt(uid + ": " + name)
        }
        printt("---- " + id + " ----")
        
        UpdatePlayerListButtons(id, null)
    }

    // refresh the sanctions to get the sanctions for any new players
    Spyglass_RefreshSanctions(button)
}

void function Spyglass_RefreshSanctions(var button)
{
    // gather together all of the uids and query them
    array<string> uids = []
    foreach (string id, PlayerListStruct list in file.lists)
    {
        foreach(string uid in list.uids)
        {
            // prevent duplicates
            if (!uids.contains(uid))
                uids.append(uid)
        }
    }
    // query API for the sanctions and cache them
    SpyglassApi_QueryPlayerSanctions( uids, OnSuccessfulSanctionQuery, false, true, true )
    // TODO show a dialog spinner thing here
}

void function OnSuccessfulSanctionQuery(Spyglass_SanctionSearchResult res)
{   
    // TODO hide the dialog spinner thing
    Spyglass_UpdateInfractionCache(res.Matches)
}

void function UpdatePlayerListButtons( string id, var button )
{
    // get scrollbar struct
    PlayerListStruct list = file.lists[id]
    // calculate scrollbar things
    list.scrollbarTotalContentsHeight = SCROLLBAR_MEMBER_HEIGHT * list.uids.len()
    // how many pixels we need to scroll to reach the bottom of the list
    int requiredScrollSpace = list.scrollbarTotalContentsHeight - Hud_GetHeight(list.listFrame)
    if (requiredScrollSpace <= 0)
    {
        Hud_SetHeight( list.playerListScrollBar, list.scrollbarMaxHeight )
        list.scrollbarScrollScale = 1
    }
    else if (requiredScrollSpace <= list.scrollbarMaxHeight - list.scrollbarMinHeight)
    {
        Hud_SetHeight( list.playerListScrollBar, list.scrollbarMaxHeight - requiredScrollSpace )
        list.scrollbarScrollScale = 1   
    }
    else
    {
        Hud_SetHeight( list.playerListScrollBar, list.scrollbarMinHeight )
        list.scrollbarScrollScale = requiredScrollSpace / (list.scrollbarMaxHeight - list.scrollbarMinHeight)
    }
    // end of scrollbar calculations

    Spyglass_SetSelectedPlayer("", "") // give an invalid selection until something is clicked

    // hide all of the things
    array<var> elems = GetChildElementsByClassname( list.playerList, "Name" )
    elems.extend(GetChildElementsByClassname( list.playerList, "Button" ))
    elems.extend(GetChildElementsByClassname( list.playerList, "Background" ))
    
    // hide all of them
    foreach (var elem in elems)
    {
        Hud_SetVisible( elem, false )
    }

    // reset colours and text
    foreach (var elem in GetChildElementsByClassname( list.playerList, "Name" ))
    {
        Hud_SetColor( elem, NAME_DEFAULT_R, NAME_DEFAULT_G, NAME_DEFAULT_B, NAME_DEFAULT_A )
        Hud_SetText( elem, "" )
    }
    foreach (var elem in GetChildElementsByClassname( list.playerList, "Background" ))
    {
        Hud_SetColor( elem, BACKGROUND_DEFAULT_R, BACKGROUND_DEFAULT_G, BACKGROUND_DEFAULT_B, BACKGROUND_DEFAULT_A )
    }

    // set names and unhide elements
    int i = 0
    foreach (string uid, string name in list.playerIdentities)
    {
        var label = Hud_GetChild(list.playerList, "PlayerName" + i)
        Hud_SetText( label, name )
        foreach (var elem in GetChildElementsByClassname( list.playerList, "Player" + i ) )
        {
            Hud_SetVisible(elem, true)
        }

        i++
    }
}

array<var> function GetChildElementsByClassname( var parentElem, string classname )
{
    var menu = GetParentMenu(parentElem)
    var elems = GetElementsByClassname( menu, classname )
    array<var> ret = []
    foreach (var elem in elems)
    {
        var cur = elem
        // this would cause an infinite loop if the child is not a child of the menu, but it should always be,
        // unless GetElementsByClassname can return non-child elements of a menu somehow
        while (cur != menu)
        {
            cur = Hud_GetParent(cur)
            if (cur == parentElem)
            {
                ret.append(elem)
                break
            }
        }
    }

    return ret
}

void function Spyglass_PlayerListButton_OnClick( string id, var button )
{
    // get scrollbar struct
    PlayerListStruct list = file.lists[id]

    int index = int( Hud_GetScriptID(button) )

    // reset colours
    foreach (var elem in GetElementsByClassname( list.menu, "Name" ))
    {
        Hud_SetColor( elem, NAME_DEFAULT_R, NAME_DEFAULT_G, NAME_DEFAULT_B, NAME_DEFAULT_A )
    }

    Hud_SetColor( Hud_GetChild(list.playerList, "PlayerName" + index), NAME_SELECTED_R, NAME_SELECTED_G, NAME_SELECTED_B, NAME_SELECTED_A )
    
    string uid = list.uids[index]
    if (uid in list.playerIdentities)
        Spyglass_SetSelectedPlayer(uid, list.playerIdentities[uid])
    else
        Spyglass_SetSelectedPlayer(uid, "UNKNOWN")
}

void function Spyglass_PlayerListButton_OnGetFocus( string id, var button )
{
    // get scrollbar struct
    PlayerListStruct list = file.lists[id]
    //printt("GAIN FOCUS: " + Hud_GetHudName( button ))
    int index = int( Hud_GetScriptID(button) )
    
    // get background colour sibling
    Hud_SetColor( Hud_GetChild(list.playerList, "Background" + index), BACKGROUND_FOCUS_R, BACKGROUND_FOCUS_G, BACKGROUND_FOCUS_B, BACKGROUND_FOCUS_A )
}

void function Spyglass_PlayerListButton_OnLoseFocus( string id, var button )
{
    // get scrollbar struct
    PlayerListStruct list = file.lists[id]
    //printt("LOSE FOCUS: " + Hud_GetHudName( button ))
    int index = int( Hud_GetScriptID(button) )
    
    // get background colour sibling
    Hud_SetColor( Hud_GetChild(list.playerList, "Background" + index), BACKGROUND_DEFAULT_R, BACKGROUND_DEFAULT_G, BACKGROUND_DEFAULT_B, BACKGROUND_DEFAULT_A )
}
