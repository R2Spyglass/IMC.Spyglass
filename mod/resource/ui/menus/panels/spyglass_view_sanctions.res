"resource/ui/menus/panels/spyglass_view_sanctions.res"
{
    ButtonRowAnchor
    {
        ControlName Label
        labelText "VIEW SANCTIONS"

        xpos 20
        ypos 20
        auto_wide_tocontents 1
        visible 0
    }

    BackgroundBox
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					1000
        tall					550
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
    }

    SanctionIDLabel
    {
        ControlName Label

        xpos 0
        ypos -5

        visible 0

        labelText "#"
        font Default_43_DropShadow
        textAlignment center

        tall 35
        wide 980

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
    }

    NoDataLabel
    {
        ControlName Label

        xpos 0
        ypos 0

        labelText "NO DATA"
        font Default_28
        textAlignment center

        auto_wide_tocontents 1

        visible 1

        pin_to_sibling BackgroundBox
        pin_corner_to_sibling CENTER
        pin_to_sibling_corner CENTER
    }

    PlayerUIDLabel
    {
        ControlName Label

        xpos -10
        ypos 5

        visible 0

        labelText "Player UID: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling SanctionIDLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    IssuerUIDLabel
    {
        ControlName Label

        xpos 0
        ypos 5

        visible 0

        labelText "Issuer UID: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling PlayerUIDLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    IssuedAtLabel
    {
        ControlName Label

        xpos -365
        ypos 0

        visible 0

        labelText "Issued At: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling PlayerUIDLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
    }

    ExpiresAtLabel
    {
        ControlName Label

        xpos 0
        ypos 5

        visible 0

        labelText "Expires At: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling IssuedAtLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    ReasonLabel
    {
        ControlName Label

        xpos 0
        ypos 5

        visible 0

        labelText "Reason: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling IssuerUIDLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    ReasonTextBox
    {
        ControlName					TextEntry
        classname						FilterPanelChild


        wide 730
        tall 300

        visible 0

        textHidden 0
        editable 0
        multiline 1
        font Default_21
        allowRightClickMenu 1
        allowSpecialCharacters 1
        unicode 0
        textAlignment north-west

        pin_to_sibling ReasonLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    InfractionTypeLabel
    {
        ControlName Label

        xpos 0
        ypos 5

        visible 0

        labelText "Infraction Type: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling ReasonTextBox
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    SanctionTypeLabel
    {
        ControlName Label

        xpos 0
        ypos 5

        visible 0

        labelText "Sanction Type: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling InfractionTypeLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    SanctionChangeArrows
    {
        ControlName RuiButton
        InheritProperties SwitchButton

        wide 228
        xpos -114

        pin_to_sibling BackgroundBox
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM
    }

    SanctionChangeLabel
    {
        ControlName Label

        labelText "0 of 0"
        auto_wide_tocontents 1
        pin_to_sibling SanctionChangeArrows
        pin_corner_to_sibling CENTER
        pin_to_sibling_corner CENTER
    }
}