global function Spyglass_InitViewSanctionsPanel

struct {
    var panel

    var sanctionIDLabel
    var noDataLabel
    var playerUIDLabel
    var issuerUIDLabel
    var issuedAtLabel
    var expiresAtLabel
    var reasonLabel
    var reasonTextBox
    var infractionTypeLabel
    var sanctionTypeLabel

    var sanctionChangeArrows
    var sanctionChangeLabel

    string uid = ""

    int infractionIndex
    array<Spyglass_PlayerInfraction> infractions

} file

// whitespace to add a gap between the two arrows because <> cant fit the number of sanctions between it
const string SANCTION_CHANGE_ARROWS_WHITESPACE = "                        " 

void function Spyglass_InitViewSanctionsPanel()
{
    Spyglass_AddCallback_OnSelectedPlayerChanged(OnSelectedPlayerChanged)

    file.panel = GetPanel("ViewSanctionsPanel")

    file.sanctionIDLabel = Hud_GetChild( file.panel, "SanctionIDLabel" ) 
    file.noDataLabel = Hud_GetChild( file.panel, "NoDataLabel" ) 
    file.playerUIDLabel = Hud_GetChild( file.panel, "PlayerUIDLabel" ) 
    file.issuerUIDLabel = Hud_GetChild( file.panel, "IssuerUIDLabel" ) 
    file.issuedAtLabel = Hud_GetChild( file.panel, "IssuedAtLabel" ) 
    file.expiresAtLabel = Hud_GetChild( file.panel, "ExpiresAtLabel" ) 
    file.reasonLabel = Hud_GetChild( file.panel, "ReasonLabel" ) 
    file.reasonTextBox = Hud_GetChild( file.panel, "ReasonTextBox" ) 
    file.infractionTypeLabel = Hud_GetChild( file.panel, "InfractionTypeLabel" ) 
    file.sanctionTypeLabel = Hud_GetChild( file.panel, "SanctionTypeLabel" ) 

    var sanctionChangeArrows = Hud_GetChild( file.panel, "SanctionChangeArrows") 
    SetButtonRuiText(sanctionChangeArrows, "") // clear the default BUTTON text that we dont need
    // cant add and remove these dynamically, which sucks, so i have to do something a bit more hacky (yoinked from modsettings)
    Hud_DialogList_AddListItem( sanctionChangeArrows, SANCTION_CHANGE_ARROWS_WHITESPACE, "main" )
    Hud_DialogList_AddListItem( sanctionChangeArrows, SANCTION_CHANGE_ARROWS_WHITESPACE, "next" )
    Hud_DialogList_AddListItem( sanctionChangeArrows, SANCTION_CHANGE_ARROWS_WHITESPACE, "prev" )
    AddButtonEventHandler( sanctionChangeArrows, UIE_CHANGE, OnSanctionSelectionButtonPressed )
    file.sanctionChangeArrows = sanctionChangeArrows

    file.sanctionChangeLabel = Hud_GetChild( file.panel, "SanctionChangeLabel" )
}

void function OnSelectedPlayerChanged(string uid, string name)
{
    file.uid = uid
    // this should just access an already queried cache, which gets invalidated when players are refeshed, and when sanctions are refreshed
    // bool function SpyglassApi_QueryPlayerSanctions(array<string> uids, void functionref(Spyglass_SanctionSearchResult) callback, bool excludeMaintainers = false, bool withExpired = true, bool withPlayerInfo = false)
    file.infractions = Spyglass_GetInfractionsForUID(uid)
    printt("PLAYER WITH UID '" + uid + "' HAS " + file.infractions.len() + " SANCTIONS")

    SetInfractionCount(file.infractions.len())
    if (file.infractions.len() > 0)
        SetVisibleInfraction(file.infractions[0])
    else
        SetVisibleInfraction(null)
}

void function PrintInfraction(Spyglass_PlayerInfraction infraction)
{
    printt( "---------- INFRACTION INFO ----------" )
    printt( "ID:              " + infraction.ID )
    printt( "Player UID:      " + infraction.UniqueId )
    printt( "Issuer UID:      " + infraction.IssuerId )
    printt( "Issued At:       " + infraction.IssuedAtReadable )
    printt( "Expires At:      " + infraction.ExpiresAtReadable )
    printt( "Reason:          " + infraction.Reason )
    printt( "Infraction Type: " + infraction.TypeReadable )
    printt( "Sanction Type:   " + infraction.PunishmentReadable )
    printt( "-------------------------------------" )
}

void function SetVisibleInfraction(Spyglass_PlayerInfraction ornull infraction)
{
    if ( infraction == null )
    {
        // hide all of the sanction information labels and stuff
        Hud_SetVisible( file.sanctionIDLabel, false )
        Hud_SetVisible( file.playerUIDLabel, false )
        Hud_SetVisible( file.issuerUIDLabel, false )
        Hud_SetVisible( file.issuedAtLabel, false )
        Hud_SetVisible( file.expiresAtLabel, false )
        Hud_SetVisible( file.reasonLabel, false )
        Hud_SetVisible( file.reasonTextBox, false )
        Hud_SetVisible( file.infractionTypeLabel, false )
        Hud_SetVisible( file.sanctionTypeLabel, false )

        // show the no data label
        Hud_SetVisible( file.noDataLabel, true )
    }
    else
    {
        // we have checked for null, so now we can expect
        expect Spyglass_PlayerInfraction(infraction)

        // logging is cool
        PrintInfraction(infraction)
        
        // hide the no data label
        Hud_SetVisible( file.noDataLabel, false )

        // populate the label texts
        Hud_SetText( file.sanctionIDLabel, "#" + infraction.ID )
        Hud_SetText( file.playerUIDLabel, "Player UID: " + infraction.UniqueId )
        Hud_SetText( file.issuerUIDLabel, "Issuer UID: " + infraction.IssuerId )
        Hud_SetText( file.issuedAtLabel, "Issued At: " + infraction.IssuedAtReadable )
        Hud_SetText( file.expiresAtLabel, "Expires At: " + infraction.ExpiresAtReadable )
        Hud_SetText( file.reasonTextBox, infraction.Reason )
        Hud_SetText( file.infractionTypeLabel, "Infraction Type: " + infraction.TypeReadable )
        Hud_SetText( file.sanctionTypeLabel, "Sanction Type: " + infraction.PunishmentReadable )

        // show all of the sanction information labels and stuff
        Hud_SetVisible( file.sanctionIDLabel, true )
        Hud_SetVisible( file.playerUIDLabel, true )
        Hud_SetVisible( file.issuerUIDLabel, true )
        Hud_SetVisible( file.issuedAtLabel, true )
        Hud_SetVisible( file.expiresAtLabel, true )
        Hud_SetVisible( file.reasonLabel, true )
        Hud_SetVisible( file.reasonTextBox, true )
        Hud_SetVisible( file.infractionTypeLabel, true )
        Hud_SetVisible( file.sanctionTypeLabel, true )
    }
}

void function SetInfractionCount(int count)
{
    if (count == 0)
        Hud_SetText( file.sanctionChangeLabel, Localize( "#SPYGLASS_SANCTION_NUMBER", 0, 0 ) ) // dont show 1 of 0 for no sanctions
    else
        Hud_SetText( file.sanctionChangeLabel, Localize( "#SPYGLASS_SANCTION_NUMBER", 1, count ) )

    file.infractionIndex = 0
}

void function OnSanctionSelectionButtonPressed( var button )
{
    // dont do anything except reset the selection if we have no infractions, its just easier that way
    if (file.infractions.len() == 0)
    {
        Hud_SetDialogListSelectionValue( button, "main" )
        return
    }

    string selectionVal = Hud_GetDialogListSelectionValue( button )

    // do nothing if they selected the same as it was before somehow
    if ( selectionVal == "main" )
        return
                    
    int enumVal = file.infractionIndex
    if ( selectionVal == "next" ) // enum val += 1
    {
        enumVal = ( enumVal + 1 ) % file.infractions.len()
    }
    else // enum val -= 1
    {
        enumVal--
        if ( enumVal == -1 )
            enumVal = file.infractions.len() - 1
    }
    
    // set the infraction index and use it to show the visible infraction
    file.infractionIndex = enumVal

    // show the infraction in UI
    SetVisibleInfraction(file.infractions[file.infractionIndex])

    // set the "1 of 3" text thing
    Hud_SetText( file.sanctionChangeLabel, Localize( "#SPYGLASS_SANCTION_NUMBER", file.infractionIndex + 1, file.infractions.len() ) )

    // reset the selection ready for next press
	Hud_SetDialogListSelectionValue( button, "main" )
}