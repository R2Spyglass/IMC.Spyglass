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

    //////////////////////////////////////////////////////////

    Background17
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

        pin_to_sibling Background16
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player17"
    }
    PlayerName17
    {
        ControlName Label
        
        labelText "testname17"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName16
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player17"
    }
    Button17
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 17
        
        pin_to_sibling Button16
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player17"
    }

    //////////////////////////////////////////////////////////

    Background18
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

        pin_to_sibling Background17
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player18"
    }
    PlayerName18
    {
        ControlName Label
        
        labelText "testname18"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName17
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player18"
    }
    Button18
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 18
        
        pin_to_sibling Button17
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player18"
    }

    //////////////////////////////////////////////////////////

    Background19
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

        pin_to_sibling Background18
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player19"
    }
    PlayerName19
    {
        ControlName Label
        
        labelText "testname19"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName18
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player19"
    }
    Button19
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 19
        
        pin_to_sibling Button18
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player19"
    }

    //////////////////////////////////////////////////////////

    Background20
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

        pin_to_sibling Background19
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player20"
    }
    PlayerName20
    {
        ControlName Label
        
        labelText "testname20"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName19
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player20"
    }
    Button20
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button19
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player20"
    }

    //////////////////////////////////////////////////////////

    Background21
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

        pin_to_sibling Background20
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player21"
    }
    PlayerName21
    {
        ControlName Label
        
        labelText "testname21"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName20
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player21"
    }
    Button21
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button20
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player21"
    }

    //////////////////////////////////////////////////////////

    Background22
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

        pin_to_sibling Background21
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player22"
    }
    PlayerName22
    {
        ControlName Label
        
        labelText "testname22"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName21
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player22"
    }
    Button22
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button21
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player22"
    }

    //////////////////////////////////////////////////////////

    Background23
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

        pin_to_sibling Background22
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player23"
    }
    PlayerName23
    {
        ControlName Label
        
        labelText "testname23"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName22
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player23"
    }
    Button23
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button22
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player23"
    }

    //////////////////////////////////////////////////////////

    Background24
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

        pin_to_sibling Background23
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player24"
    }
    PlayerName24
    {
        ControlName Label
        
        labelText "testname24"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName23
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player24"
    }
    Button24
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button23
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player24"
    }

    //////////////////////////////////////////////////////////

    Background25
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

        pin_to_sibling Background24
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player25"
    }
    PlayerName25
    {
        ControlName Label
        
        labelText "testname25"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName24
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player25"
    }
    Button25
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button24
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player25"
    }

    //////////////////////////////////////////////////////////

    Background26
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

        pin_to_sibling Background25
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player26"
    }
    PlayerName26
    {
        ControlName Label
        
        labelText "testname26"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName25
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player26"
    }
    Button26
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 16
        
        pin_to_sibling Button25
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player26"
    }

    //////////////////////////////////////////////////////////

    Background27
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

        pin_to_sibling Background26
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player27"
    }
    PlayerName27
    {
        ControlName Label
        
        labelText "testname27"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName26
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player27"
    }
    Button27
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 27
        
        pin_to_sibling Button26
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player27"
    }

    //////////////////////////////////////////////////////////

    Background28
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

        pin_to_sibling Background27
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player28"
    }
    PlayerName28
    {
        ControlName Label
        
        labelText "testname28"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName27
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player28"
    }
    Button28
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 28
        
        pin_to_sibling Button27
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player28"
    }

    //////////////////////////////////////////////////////////

    Background29
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

        pin_to_sibling Background28
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player29"
    }
    PlayerName29
    {
        ControlName Label
        
        labelText "testname29"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName28
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player29"
    }
    Button29
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 29
        
        pin_to_sibling Button28
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player29"
    }

    //////////////////////////////////////////////////////////

    Background30
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

        pin_to_sibling Background29
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player30"
    }
    PlayerName30
    {
        ControlName Label
        
        labelText "testname30"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName29
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player30"
    }
    Button30
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 30
        
        pin_to_sibling Button29
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player30"
    }

    //////////////////////////////////////////////////////////

    Background31
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

        pin_to_sibling Background30
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT

        classname "Background Player31"
    }
    PlayerName31
    {
        ControlName Label
        
        labelText "testname31"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName30
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT


        classname "Name Player31"
    }
    Button31
    {
        ControlName RuiButton
        labelText ""

        xpos 0
        zpos 2000

        wide 500
        tall					50

        scriptID 31
        
        pin_to_sibling Button30
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
        classname "Button Player31"
    }

//////////////////////////////////////////////////

    Warning
    {
        ControlName Label
        
        labelText "Whoops, no more UI"

        use_proportional_insets 1
		textinsetx 5

        xpos 0

        wide 500
        tall					50
        font                    Default_28
        fgcolor_override        "255 255 255 255"

        pin_to_sibling PlayerName31
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner BOTTOM_LEFT
    }