"resource/ui/menus/panels/spyglass_add_sanction.res"
{
    ButtonRowAnchor
    {
        ControlName Label
        labelText "ADD SANCTION"

        xpos 0
        ypos 0
        auto_wide_tocontents		1
        visible 0
    }

    BackgroundImage
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					%100
        tall					%100
        image 					"vgui/hud/white"
        visible					0
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
    }

    SelectInfraction
    {
        ControlName RuiButton
        InheritProperties SwitchButton
        zpos 0
        xpos 0
        ypos 0
        

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    SelectSanction
    {
        ControlName RuiButton
        InheritProperties SwitchButton
        zpos 0
        xpos 0
        ypos 0
        

        pin_to_sibling SelectInfraction
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    DurationLabel
    {
        ControlName Label

        xpos -10
        ypos 5

        labelText "Duration: "
        font Default_28
        textAlignment south-west

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling SelectSanction
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    DurationTextBox
    {
        ControlName					TextEntry
        classname					FilterPanelChild

        xpos 5
        wide 100 
        tall 35
        textHidden 0
        editable 1
        font Default_28
        NumericInputOnly 1
        unicode 0
        textAlignment center

        pin_to_sibling DurationLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_RIGHT
    }

    ReasonLabel
    {
        ControlName Label

        labelText "Reason:"
        font Default_28
        textAlignment south-west

        ypos 5

        tall 35
        auto_wide_tocontents 1

        pin_to_sibling DurationLabel
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }

    ReasonTextBox
    {
        ControlName					TextEntry
        classname						FilterPanelChild


        wide 730
        tall 300
        textHidden 0
        editable 1
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

    ApplySanction
    {
        ControlName RuiButton
        InheritProperties RuiSmallButton

        ypos 5

        wide 730

        labelText "APPLY SANCTION"

        enabled 0 // locked by default, unlocked when all fields are valid

        pin_to_sibling ReasonTextBox
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }
}