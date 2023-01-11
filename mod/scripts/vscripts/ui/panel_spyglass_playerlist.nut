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

struct
{
    var menu

    // table< uid, name >
    table< string, string > playerIdentities
    // used to convert an index (int) into a uid (string) for indexing into playerIdentities
    array<string> uids = []

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

} file


void function Spyglass_PlayerList_Init( var playerListFrame )
{
    file.menu = GetParentMenu( playerListFrame )
    file.listFrame = playerListFrame
    file.playerList = Hud_GetChild( playerListFrame, "PlayerList" )
    file.playerListScrollTop = Hud_GetChild( playerListFrame, "ScrollTop" )
    file.playerListScrollBar = Hud_GetChild( playerListFrame, "ScrollBar" )
    file.playerListScrollBottom = Hud_GetChild( playerListFrame, "ScrollBottom" )
    file.playerListScrollCapture = Hud_GetChild( playerListFrame, "ScrollCapture" )
    file.scrollMin = Hud_GetAbsY( file.playerListScrollCapture )
    file.scrollMax = file.scrollMin + Hud_GetHeight( file.playerListScrollCapture )
    file.scrollbarMaxHeight = Hud_GetHeight( file.playerListScrollBar )
    file.scrollbarMinHeight = 86 // this seems reasonable

    // simulate mouse movements, arbitrary values for now
    Hud_AddEventHandler( file.playerListScrollTop, UIE_CLICK, void function(var button)
    {
        PlayerList_MouseMovementHandler(0, -SCROLLBAR_BUTTON_SCROLL_DISTANCE)
    } )
    Hud_AddEventHandler( file.playerListScrollBottom, UIE_CLICK, void function(var button)
    {
        PlayerList_MouseMovementHandler(0, SCROLLBAR_BUTTON_SCROLL_DISTANCE)
    } )

    // event handlers to deal with weird capture handler bullshit
    Hud_AddEventHandler( file.playerListScrollBar, UIE_GET_FOCUS, void function(var button)
    {
        Hud_SetVisible( file.playerListScrollCapture, true )
    } )
    Hud_AddEventHandler( file.playerListScrollBar, UIE_LOSE_FOCUS, void function(var button)
    {
        Hud_SetVisible( file.playerListScrollCapture, false )
    } )
    
 //AddEventHandlerToButtonClass( var menu, string classname, int event, void functionref( var ) func )
    AddEventHandlerToButtonClass( file.menu, "Button", UIE_GET_FOCUS, Spyglass_PlayerListButton_OnGetFocus )
    AddEventHandlerToButtonClass( file.menu, "Button", UIE_LOSE_FOCUS, Spyglass_PlayerListButton_OnLoseFocus )
    AddEventHandlerToButtonClass( file.menu, "Button", UIE_CLICK, Spyglass_PlayerListButton_OnClick )

    AddMouseMovementCaptureHandler( file.playerListScrollCapture, PlayerList_MouseMovementHandler )
}

void function PlayerList_MouseMovementHandler( int deltaX, int deltaY )
{
    // fix deltaY to bounds of scroll bar
    int y = Hud_GetAbsY( file.playerListScrollBar ) + deltaY
    //printt( y + " -> " + (y + Hud_GetHeight(file.playerListScrollBar)) )
    if ( y < file.scrollMin ) y = file.scrollMin
    if ( y + Hud_GetHeight(file.playerListScrollBar) > file.scrollMax ) y = file.scrollMax - Hud_GetHeight(file.playerListScrollBar)
    //printt(y)
    deltaY = y - Hud_GetAbsY( file.playerListScrollBar )


    Hud_SetPos( file.playerListScrollBar, 0, Hud_GetPos(file.playerListScrollBar)[1] + deltaY )
    Hud_SetPos( file.playerList, 0, Hud_GetPos(file.playerList)[1] + (deltaY * file.scrollbarScrollScale) )
}

void function Spyglass_RefreshPlayerList( var button )
{
    file.playerIdentities = SpyglassUI_GetPlayerIdentities()
    file.uids = []

    // construct array of uids to use to index into table
    foreach (string uid, string name in file.playerIdentities)
    {
        file.uids.append(uid)
        printt(uid + ": " + name)
    }

    
    UpdatePlayerListButtons(null)

    // refresh the sanctions to get the sanctions for any new players
    Spyglass_RefreshSanctions(button)
}

void function Spyglass_RefreshSanctions(var button)
{
    // query API for the sanctions and cache them
    SpyglassApi_QueryPlayerSanctions(file.uids, OnSuccessfulSanctionQuery, false, true, true)
}

void function OnSuccessfulSanctionQuery(Spyglass_SanctionSearchResult res)
{   
    Spyglass_UpdateSanctionCache(res.Matches)
}

void function UpdatePlayerListButtons( var button )
{
    // calculate scrollbar things
    file.scrollbarTotalContentsHeight = SCROLLBAR_MEMBER_HEIGHT * file.uids.len()
    // how many pixels we need to scroll to reach the bottom of the list
    int requiredScrollSpace = file.scrollbarTotalContentsHeight - Hud_GetHeight(file.listFrame)
    if (requiredScrollSpace <= 0)
    {
        Hud_SetHeight( file.playerListScrollBar, file.scrollbarMaxHeight )
        file.scrollbarScrollScale = 1
    }
    else if (requiredScrollSpace <= file.scrollbarMaxHeight - file.scrollbarMinHeight)
    {
        Hud_SetHeight( file.playerListScrollBar, file.scrollbarMaxHeight - requiredScrollSpace )
        file.scrollbarScrollScale = 1   
    }
    else
    {
        Hud_SetHeight( file.playerListScrollBar, file.scrollbarMinHeight )
        file.scrollbarScrollScale = requiredScrollSpace / (file.scrollbarMaxHeight - file.scrollbarMinHeight)
    }
    // end of scrollbar calculations

    Spyglass_SetSelectedPlayer("", "") // give an invalid selection until something is clicked

    // hide all of the things
    array<var> elems = GetElementsByClassname( file.menu, "Name" )
    elems.extend(GetElementsByClassname( file.menu, "Button" ))
    elems.extend(GetElementsByClassname( file.menu, "Background" ))
    
    // hide all of them
    foreach (var elem in elems)
    {
        Hud_SetVisible( elem, false )
    }

    // reset colours and text
    foreach (var elem in GetElementsByClassname( file.menu, "Name" ))
    {
        Hud_SetColor( elem, NAME_DEFAULT_R, NAME_DEFAULT_G, NAME_DEFAULT_B, NAME_DEFAULT_A )
        Hud_SetText( elem, "" )
    }
    foreach (var elem in GetElementsByClassname( file.menu, "Background" ))
    {
        Hud_SetColor( elem, BACKGROUND_DEFAULT_R, BACKGROUND_DEFAULT_G, BACKGROUND_DEFAULT_B, BACKGROUND_DEFAULT_A )
    }

    // set names and unhide elements
    int i = 0
    foreach (string uid, string name in file.playerIdentities)
    {
        var label = Hud_GetChild(file.playerList, "PlayerName" + i)
        Hud_SetText( label, name )
        foreach (var elem in GetElementsByClassname( file.menu, "Player" + i ) )
        {
            Hud_SetVisible(elem, true)
        }

        i++
    }
}

void function Spyglass_PlayerListButton_OnClick( var button )
{
    int index = int( Hud_GetScriptID(button) )

    // reset colours
    foreach (var elem in GetElementsByClassname( file.menu, "Name" ))
    {
        Hud_SetColor( elem, NAME_DEFAULT_R, NAME_DEFAULT_G, NAME_DEFAULT_B, NAME_DEFAULT_A )
    }

    Hud_SetColor( Hud_GetChild(file.playerList, "PlayerName" + index), NAME_SELECTED_R, NAME_SELECTED_G, NAME_SELECTED_B, NAME_SELECTED_A )
    
    string uid = file.uids[index]
    if (uid in file.playerIdentities)
        Spyglass_SetSelectedPlayer(uid, file.playerIdentities[uid])
    else
        Spyglass_SetSelectedPlayer(uid, "UNKNOWN")
}

void function Spyglass_PlayerListButton_OnGetFocus( var button )
{
    //printt("GAIN FOCUS: " + Hud_GetHudName( button ))
    int index = int( Hud_GetScriptID(button) )
    
    // get background colour sibling
    Hud_SetColor( Hud_GetChild(file.playerList, "Background" + index), BACKGROUND_FOCUS_R, BACKGROUND_FOCUS_G, BACKGROUND_FOCUS_B, BACKGROUND_FOCUS_A )
}

void function Spyglass_PlayerListButton_OnLoseFocus( var button )
{
    //printt("LOSE FOCUS: " + Hud_GetHudName( button ))
    int index = int( Hud_GetScriptID(button) )
    
    // get background colour sibling
    Hud_SetColor( Hud_GetChild(file.playerList, "Background" + index), BACKGROUND_DEFAULT_R, BACKGROUND_DEFAULT_G, BACKGROUND_DEFAULT_B, BACKGROUND_DEFAULT_A )
}
