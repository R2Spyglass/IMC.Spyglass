"resource/ui/menus/panels/spyglass_playerlist.res"
{
    ButtonRowAnchor
    {
        ControlName Label
        labelText ""

        xpos 0
        ypos 0
    }


    //////////////////////////////////////////////////////////

    Background0
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT

        classname "Background Player0"
    }
    PlayerName0
    {
        ControlName Label
        
        labelText "testname0"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT


        classname "Name Player0"
    }
    Button0
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 0
        
        pin_to_sibling ButtonRowAnchor
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT
        classname "Button Player0"
    }

    //////////////////////////////////////////////////////////

    Background1
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background0
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player1"
    }
    PlayerName1
    {
        ControlName Label
        
        labelText "testname1"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName0
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player1"
    }
    Button1
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 1
        
        pin_to_sibling Button0
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player1"
    }

    //////////////////////////////////////////////////////////

    Background2
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background1
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player2"
    }
    PlayerName2
    {
        ControlName Label
        
        labelText "testname2"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName1
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player2"
    }
    Button2
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 2
        
        pin_to_sibling Button1
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player2"
    }

    //////////////////////////////////////////////////////////

    Background3
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background2
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player3"
    }
    PlayerName3
    {
        ControlName Label
        
        labelText "testname3"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName2
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player3"
    }
    Button3
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 3
        
        pin_to_sibling Button2
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player3"
    }

    //////////////////////////////////////////////////////////

    Background4
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background3
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player4"
    }
    PlayerName4
    {
        ControlName Label
        
        labelText "testname4"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName3
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player4"
    }
    Button4
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 4
        
        pin_to_sibling Button3
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player4"
    }

    //////////////////////////////////////////////////////////

    Background5
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background4
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player5"
    }
    PlayerName5
    {
        ControlName Label
        
        labelText "testname5"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName4
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player5"
    }
    Button5
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 5
        
        pin_to_sibling Button4
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player5"
    }

    //////////////////////////////////////////////////////////

    Background6
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background5
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player6"
    }
    PlayerName6
    {
        ControlName Label
        
        labelText "testname6"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName5
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player6"
    }
    Button6
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 6
        
        pin_to_sibling Button5
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player6"
    }

    //////////////////////////////////////////////////////////

    Background7
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background6
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player7"
    }
    PlayerName7
    {
        ControlName Label
        
        labelText "testname7"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName6
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player7"
    }
    Button7
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 7
        
        pin_to_sibling Button6
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player7"
    }

    //////////////////////////////////////////////////////////

    Background8
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background7
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player8"
    }
    PlayerName8
    {
        ControlName Label
        
        labelText "testname8"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName7
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player8"
    }
    Button8
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 8
        
        pin_to_sibling Button7
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player8"
    }

    //////////////////////////////////////////////////////////

    Background9
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background8
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player9"
    }
    PlayerName9
    {
        ControlName Label
        
        labelText "testname9"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName8
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player9"
    }
    Button9
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 9
        
        pin_to_sibling Button8
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player9"
    }

    //////////////////////////////////////////////////////////

    Background10
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background9
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player10"
    }
    PlayerName10
    {
        ControlName Label
        
        labelText "testname10"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName9
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player10"
    }
    Button10
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 10
        
        pin_to_sibling Button9
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player10"
    }

    //////////////////////////////////////////////////////////

    Background11
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background10
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player11"
    }
    PlayerName11
    {
        ControlName Label
        
        labelText "testname11"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName10
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player11"
    }
    Button11
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 11
        
        pin_to_sibling Button10
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player11"
    }

    //////////////////////////////////////////////////////////

    Background12
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background11
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player12"
    }
    PlayerName12
    {
        ControlName Label
        
        labelText "testname12"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName11
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player12"
    }
    Button12
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 12
        
        pin_to_sibling Button11
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player12"
    }

    //////////////////////////////////////////////////////////

    Background13
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background12
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player13"
    }
    PlayerName13
    {
        ControlName Label
        
        labelText "testname13"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName12
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player13"
    }
    Button13
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 13
        
        pin_to_sibling Button12
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player13"
    }

    //////////////////////////////////////////////////////////

    Background14
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background13
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player14"
    }
    PlayerName14
    {
        ControlName Label
        
        labelText "testname14"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName13
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player4"
    }
    Button14
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 14
        
        pin_to_sibling Button13
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player14"
    }

    //////////////////////////////////////////////////////////

    Background15
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background14
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player15"
    }
    PlayerName15
    {
        ControlName Label
        
        labelText "testname15"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName14
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player15"
    }
    Button15
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 15
        
        pin_to_sibling Button14
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player15"
    }

    //////////////////////////////////////////////////////////

    Background16
    {
        ControlName ImagePanel
        xpos					0
        ypos					0
        wide					500
        tall					50
        image 					"vgui/hud/white"
        visible					1
        scaleImage				1
        drawColor "30 35 35 75"

        pin_to_sibling Background15
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player16"
    }
    PlayerName16
    {
        ControlName Label
        
        labelText "testname16"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName15
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player16"
    }
    Button16
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button15
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player16"
    }
}