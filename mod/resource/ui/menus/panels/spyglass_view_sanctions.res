"resource/ui/menus/panels/spyglass_view_sanctions.res"
{
    ButtonRowAnchor
    {
        ControlName Label
        labelText "VIEW SANCTIONS"

        xpos 0
        ypos 0
        auto_wide_tocontents 1
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
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
    }
}