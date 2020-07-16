; -----------------------------------------------------------------------------
; IceDesign
; -----------------------------------------------------------------------------
; IceDesign engine base to build a Modern GUI Designer with real Gadgets captured And drawn
; With management and editing of containers, , up To 9 levels, scroll bars and tabs are available   
; Features:
;   Create Gadget by Lasso
;   Select a Gadget With Left Click Or Lasso
;   Multiple Selection by lasso Or With Ctrl+Left Click And grouped movement
;   Group, UnGroup Gadget
;   Align To Left, Right, Bottom, Top. Resize With Same Width, Height
;   Left Doucle Click To Open a Container (Container, Panel And ScrollArea). Up To 9 levels
;   Select directly a Child Gadget from a Container With Left Triple Click
;   Right Doucle Click To Close a Container And go back To the previous level
;   Grid, Grid size And Snap To Grid
;   Up, Down, Left And Right arrows To Move a Gadget
;   Shift + Up, Down, Left And Right To Resize a Gadget
;   Del Key To Delete the Selected Gadget Or Container
; -----------------------------------------------------------------------------
; Author: ChrisR
; -----------------------------------------------------------------------------
; Credit:
; Base Code by FlatEarth:               https://www.purebasic.fr/english/viewtopic.php?f=12&t=68187&start=120
; Inspired by the following topics:
; - Move/Drag Canvas Image by Danilo:   https://www.purebasic.fr/english/viewtopic.php?f=13&t=54098&hilit=drag+move
; - Capture Gadget by Rashad:           https://www.purebasic.fr/english/viewtopic.php?f=5&t=70746&hilit=capture+gadget%3B+64bit%3B
; -----------------------------------------------------------------------------
; Date:       2020-02-06
; PB-Version: 5.72 LTS
; OS:         Windows Only
; -----------------------------------------------------------------------------

EnableExplicit

DeclareModule IceDesign
  
  Enumeration #PB_EventType_FirstCustomValue
    ;     #SVD_Gadget_Focus
    ;     #SVD_Gadget_LostFocus
    ;     #SVD_Gadget_Resize
    ;     #SVD_Window_Focus
    ;     #SVD_Window_ReSize
    ;     #SVD_DrawArea_RightClick
    ;     #SVD_DrawArea_Focus
    ;     #SVD_Group
  EndEnumeration
  
  #ScrollDrawArea = 0
  
  Enumeration 100
    #ComboGadget
    #Shortcut_Delete
  EndEnumeration
  
  Structure CaptureGadget
    Gadget.i
    Capture.i
    Type.i
    X.i
    Y.i
    Width.i
    Height.i
    Selected.b
    Group.i
    Level.i
    CurrentTab.i
    ParentGadget.i
    Tab.i
    DrawArea.i
    ParentDrawArea.i
    Lock.b
  EndStructure
  Global NewList Images.CaptureGadget()
  
  Structure STPosDim
    X0.i
    Y0.i
    Width0.i
    Height0.i
  EndStructure
  Global PosDim.STPosDim
  
  Global HandelOnMove = #False
  Global DragSpace.i = 10 , GridSize.i = 10, SnapGrid.b = #True, ShowGrid.b = #True
  Global X, Y, Drag.b, Resize.b
  Global CurrentItemGadget.i, GroupSelectedGadget.b
  
  Declare Align_Left(Gadget.i)
  Declare Align_Right(Gadget.i)
  Declare Align_Top(Gadget.i)
  Declare Align_Bottom(Gadget.i)
  Declare Make_Same_Width(Gadget.i)
  Declare Make_Same_Height(Gadget.i)
  Declare Group_Selected()
  Declare UnGroup_Selected(Gadget.i)
  Declare SetCurrentGadget(Gadget.i, Selection.b=#False)
  Declare DeleteGadget(Gadget.i)
  Declare Init() 
EndDeclareModule

Module IceDesign
  ;#MinSize: Possible improvement, Calculate Minimum Gadget sizes (all OS) by freak: https://www.purebasic.fr/english/viewtopic.php?f=12&t=38349
  Enumeration 1100
    #HandelSize = 8   ;Not 10 because of GridSize default 10
    #MinSize = 10
    #ScrollAreaColor = $A0A0A0
    #GridBackground = $F4F4F4
    #GridColor = $DCDCC8   ;Or Less Contrast with $E1E1CD
    #WinHandleColor= $000084           ;RedDark
    #SelectedHandelColor = $840000
    #SelectedHandelColorGroup = $242484;Red
    #RectSelection = $C00000
  EndEnumeration
  
  Enumeration 1200    
    #ThisPC
  EndEnumeration
  
  Global Geebee2Image.i = LoadImage(#PB_Any, #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp")
  
  Global UserScreen_Width.i = 720, UserScreen_Height.i = 510
  Global MaxSizeX.i, MaxSizeY.i
  Global DrawAreaOffsetX.i, DrawAreaOffsetY.i, CurrentItemOffsetX.i, CurrentItemOffsetY.i
  Global CurrentDrawArea.i, Tab.i, Level.i, ParentGadget.i, ParentDrawArea.i
  Global GroupID.i
  Global OldCallback.i
  
  Global Dim Handle(8)
  
  Declare.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=4096)
  Declare.i Min(ValueA, ValueB)
  Declare.i Max(ValueA, ValueB)
  Declare HideHandle(Hide.b=#False)
  Declare CreateHidenHandle()
  Declare CreateWinHandle()
  Declare HitInside(MinX,MaxX,MinY,MaxY)
  Declare HitOver(X,Y)
  Declare MouseOver(X,Y)
  Declare AddImage(Gadget,Capture,X,Y,NewTab=#PB_Ignore)
  Declare CreateGadget(Model.s, Caption.s="", Width=200, Height=100, X=0, Y=0, Param1=0, Param2=1, Param3=1000, Flag=0)
  Declare CaptureGadget(Gadget)
  Declare DrawGrid(GridArea)
  Declare DrawCanvas(GridArea=#True, HandelOnMove=#True)
  Declare.i GroupGadgetEnabled()
  Declare SelectedGroup(IdGroup.i, GroupSelected.b=#False)
  Declare SelectedGadget(Gadget.i, ControlKeyPressed.b=#False)
  Declare MoveGadgetGroup(Gadget.i, AddX.i, AddY.i)
  Declare MoveGadget(AddX.i, AddY.i)
  Declare MoveGadgetKeyDown()
  Declare ResizeGadgetKeyDown()
  Declare MoveDrawAreaEVENT()
  Declare ResizeHandleEVENT()
  Declare ResizeWinEVENT()
  Declare ChangeDisabledPanelTab()
  Declare ChangePanelTab()
  Declare OpenContainer(Gadget)
  Declare CloseContainer()
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  Procedure.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=4096)
    Value = Round(Value/Grid, #PB_Round_Nearest)*Grid
    If Value < Min
      ProcedureReturn Min
    ElseIf Value > Max
      ProcedureReturn Max
    Else
      ProcedureReturn Value
    EndIf
  EndProcedure
  
  Procedure.i Min(ValueA, ValueB)
    If ValueA < ValueB
      ProcedureReturn ValueA
    Else
      ProcedureReturn ValueB
    EndIf
  EndProcedure
  
  Procedure.i Max(ValueA, ValueB)
    If ValueA > ValueB
      ProcedureReturn ValueA
    Else
      ProcedureReturn ValueB
    EndIf
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure Align_Left(Gadget.i)
    Protected LeftPos.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            LeftPos = \X
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \X = LeftPos
            If \X + \Width > MaxSizeX
              \Width = MaxSizeX - \X
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith  
  EndProcedure
  
  Procedure Align_Right(Gadget.i)
    Protected RightPos.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            RightPos = \X + \Width
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \X = RightPos - \Width
            If \X < 0
              \X = 0
              \Width = RightPos - \X
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith  
  EndProcedure
  
  Procedure Align_Top(Gadget.i)
    Protected TopPos.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            TopPos = \Y
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \Y = TopPos
            If \Y + \Height > MaxSizeY
              \Height = MaxSizeY - \Y
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith  
  EndProcedure
  
  Procedure Align_Bottom(Gadget.i)
    Protected BottomPos.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            BottomPos = \Y + \Height
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \Y = BottomPos - \Height
            If \Y < 0
              \Y = 0
              \Height = BottomPos - \Y
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith    
  EndProcedure
  
  Procedure Make_Same_Width(Gadget.i)
    Protected Width.i
    With Images()  
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            Width = \Width
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \Width = Width
            If \X + \Width > MaxSizeX
              \X = MaxSizeX - \Width
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith  
  EndProcedure
  
  Procedure Make_Same_Height(Gadget.i)
    Protected Height.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            Height = \Height
          EndIf
        Next
        ForEach Images()
          If \Selected = #True And \Lock = #False And \Gadget <> Gadget And \Gadget <> \ParentGadget
            \Height = Height
            If \Y + \Height > MaxSizeY
              \Y = MaxSizeY - \Height
            EndIf
            If IsGadget(\Gadget) 
              ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
              FreeImage(\Capture)
              \Capture = CaptureGadget(\Gadget)
            EndIf
          EndIf
        Next
        SetCurrentGadget(Gadget)
      EndIf
    EndWith    
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure HideHandle(Hide.b=#False)
    Protected I.i
    For I = 1 To 8
      HideGadget(Handle(I),Hide)
    Next
  EndProcedure
  
  Procedure CreateHidenHandle()   ;Called between the Canvas Container (Draw Area) and the CloseGadgetList()
    Protected Mycursors.i, I.i
    ;Delete, Free Previous Handle First if Exist
    For I = 1 To 8
      If Handle(I)
        If IsGadget(Handle(I)) :FreeGadget(Handle(I)) :EndIf
      EndIf
    Next
    ;Create Handle 1 To 8: North, North-East, East, South-East, South, South-West, West, North-West
    Restore Cursors
    Read Mycursors
    For I = 1 To 8
      Handle(I) = CanvasGadget(#PB_Any, 0, 0, #HandelSize, #HandelSize)
      If Handle(I)
        ;SetGadgetData with Selected Images() Done in DrawCanvas 
        HideGadget(Handle(I), #True)
        If StartDrawing(CanvasOutput(Handle(I)))
          DrawingMode(#PB_2DDrawing_Default)
          Box(0, 0, #HandelSize, #HandelSize, #SelectedHandelColor)
          Box(1, 1, #HandelSize-2, #HandelSize-2, #White)
          StopDrawing()
        EndIf
        Read Mycursors
        SetGadgetAttribute(Handle(I), #PB_Canvas_Cursor, Mycursors)
        BindGadgetEvent(Handle(I), @ResizeHandleEVENT())
      EndIf
    Next
    
    DataSection
      Cursors:
      Data.i 0, #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown
      Data.i #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown
    EndDataSection
  EndProcedure
  
  Procedure CreateWinHandle()
    Handle(0) = CanvasGadget(#PB_Any, 0, 0, #HandelSize, #HandelSize)
    If StartDrawing(CanvasOutput(Handle(0)))
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, #HandelSize, #HandelSize, #WinHandleColor)
      Box(1, 1, #HandelSize-2, #HandelSize-2, #White)
      StopDrawing()
    EndIf
    SetGadgetAttribute(Handle(0), #PB_Canvas_Cursor, #PB_Cursor_LeftUpRightDown)
    ResizeGadget(Handle(0), UserScreen_Width, UserScreen_Height, #PB_Ignore, #PB_Ignore)
    BindGadgetEvent(Handle(0), @ResizeWinEVENT())
  EndProcedure   
  
  ;- ----------------------------------------------------------------------------
  Procedure HitInside(MinX,MaxX,MinY,MaxY)
    Protected ObjectID
    CurrentItemGadget = 0
    GroupSelectedGadget = #False
    With Images()
      If MaxX > MinX + 4 And MaxY > MinY + 4
        ForEach Images()   ;The last selected become the CurrentItemGadget (z-Order)
          If \Level = Level And \ParentGadget = ParentGadget And \Tab = Tab  And \Gadget <> \ParentGadget
            If MaxX >= \X And MinX <= \X + \Width And MaxY >= \Y And MinY <= \Y + \Height
              CurrentItemGadget = \Gadget
              \Selected         = #True
              If \Group > 0
                SelectedGroup(\Group, \Selected)
              EndIf
            EndIf
          EndIf
        Next
        If CurrentItemGadget <> 0
          If LastElement(Images())   ;Search now Starting From End (z-Order) and Move CurrentItemGadget as last item on the list (z-Order)
            Repeat
              If \Gadget = CurrentItemGadget And \Gadget <> \ParentGadget
                PosDim\X0 = \X : PosDim\Y0 = \Y
                MoveElement(Images(), #PB_List_Last)
                Break
              EndIf
            Until PreviousElement(Images())=0
          EndIf
          GroupSelectedGadget = GroupGadgetEnabled()
        Else   ;CurrentItemGadget = 0 
          If MaxX > MinX + #MinSize And MaxY > MinY + #MinSize
            If MinX + #MinSize <= MaxSizeX And MinY + #MinSize <= MaxSizeY
              ObjectID = CreateGadget(GetGadgetText(#ComboGadget)+"Gadget", " "+GetGadgetText(#ComboGadget), Max(PosDim\X0,X)-Min(PosDim\X0,X), Max(PosDim\Y0,Y)-Min(PosDim\Y0,Y), Min(PosDim\X0,X), Min(PosDim\Y0,Y))
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
    ProcedureReturn CurrentItemGadget
  EndProcedure
  
  Procedure HitOver(X,Y)
    CurrentItemGadget = 0
    With Images()
      If LastElement(Images())   ;Search for Hit, Starting From End (z-Order)
        Repeat
          If \Level = Level And \ParentGadget = ParentGadget And \Tab = Tab  And \Gadget <> \ParentGadget
            If X >= \X And X < \X + \Width And  Y >= \Y And Y < \Y + \Height
              MoveElement(Images(), #PB_List_Last)
              CurrentItemGadget = \Gadget
              CurrentItemOffsetX = X - Images()\X
              CurrentItemOffsetY = Y - Images()\Y
              PosDim\X0 = \X : PosDim\Y0 = \Y
              ;Specific FrameGadget: Continue the loop to select the gadgets included if there is
              If GadgetType(\Gadget) <> #PB_GadgetType_Frame
                Break
              EndIf
            EndIf
          EndIf
        Until PreviousElement(Images())=0
      EndIf
    EndWith
    ProcedureReturn CurrentItemGadget
  EndProcedure
  
  Procedure MouseOver(X,Y)
    Protected MouseOverGadget = #False
    With Images()
      If LastElement(Images())   ;Search for Hit, Starting From End (z-Order)
        Repeat
          If \Level = Level And \ParentGadget = ParentGadget And \Tab = Tab  And \Gadget <> \ParentGadget
            If X >= \X And X < \X + \Width And  Y >= \Y And Y < \Y + \Height
              MouseOverGadget = #True
              Break
            EndIf
          EndIf
        Until PreviousElement(Images())=0
      EndIf
      If MouseOverGadget
        SetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Cursor,  #PB_Cursor_Arrows)
      Else
        SetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Cursor, #PB_Cursor_Default)
      EndIf 
    EndWith  
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure AddImage(Gadget,Capture,X,Y,NewTab=#PB_Ignore)
    If AddElement(Images())
      With Images()
        \Gadget         = Gadget
        If Gadget = 0
          \Capture        = 0
          \Type           = 0
          \X              = X
          \Y              = Y
          \Width          = MaxSizeX
          \Height         = MaxSizeY
          \CurrentTab     = #PB_Ignore
          \Level          = Level
          \ParentGadget   = Gadget
          \Tab            = #PB_Ignore
          \DrawArea       = CurrentDrawArea
          \ParentDrawArea = ParentDrawArea
          \Selected       = #True
          \Lock           = #False
        Else
          If NewTab = #PB_Ignore
            \Capture        = Capture
            \Type           = GadgetType(Gadget)
            \X              = X
            \Y              = Y
            \Width          = ImageWidth(Capture)
            \Height         = ImageHeight(Capture)
            If \Type = #PB_GadgetType_Panel
              \CurrentTab   = GetGadgetState(Gadget)
            Else  
              \CurrentTab   = #PB_Ignore
            EndIf 
            \Level          = Level
            \ParentGadget   = ParentGadget
            \Tab            = Tab
            \DrawArea       = 0
            \ParentDrawArea = ParentDrawArea
            MoveElement(Images(), #PB_List_Last)   ;Required for Gadgets Creation in a Container
            \Selected       = #True
            \Lock           = #False
          Else
            \Capture        = 0
            \Type           = GadgetType(Gadget)
            \X              = 0
            \Y              = 0
            \Width          = 0
            \Height         = 0
            \CurrentTab     = #PB_Ignore
            \Level          = Level + 1
            \ParentGadget   = Gadget
            \Tab            = NewTab
            \DrawArea       = 0
            \ParentDrawArea = ParentDrawArea
            MoveElement(Images(), #PB_List_First)
            \Selected       = #False
            \Lock           = #False
          EndIf
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure CreateGadget(Model.s, Caption.s="", Width=200, Height=100, X=0, Y=0, Param1=0, Param2=1, Param3=1000, Flag=0)
    Protected ObjectID.i, I.i
    
    X = GridMatch(X, DragSpace, 0, MaxSizeX-#MinSize)
    Y = GridMatch(Y, DragSpace, 0, MaxSizeY-#MinSize)
    Width = GridMatch(Width, DragSpace, #MinSize, MaxSizeX-X) 
    Height = GridMatch(Height, DragSpace, #MinSize, MaxSizeY-Y)
    
    Select Model
        ;Case "OpenWindow"           : ObjectID = OpenWindow          (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "ButtonGadget"          : ObjectID = ButtonGadget        (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "ButtonImageGadget"     : ObjectID = ButtonImageGadget   (#PB_Any, X,Y,Width,Height, ImageID(Geebee2Image), Flag)   ;Caption, Flag)
      Case "CalendarGadget"        : ObjectID = CalendarGadget      (#PB_Any, X,Y,Width,Height, Param1, Flag)  
      Case "CanvasGadget"          : ObjectID = CanvasGadget        (#PB_Any, X,Y,Width,Height, Flag)
        If StartDrawing(CanvasOutput(ObjectID))
          DrawingFont(GetGadgetFont(#PB_Default))
          DrawingMode(#PB_2DDrawing_AllChannels)
          ;Image and Text from Properties. Images()\ImageID, Images()\Text
          DrawImage(ImageID(Geebee2Image), 0, 0, ImageWidth(Geebee2Image), ImageHeight(Geebee2Image))
          ;DrawImage(ImageID(Geebee2Image), 0, 0, OutputWidth(), OutputHeight())
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(5, 5, Caption, #Blue, #White)
          StopDrawing()
        EndIf
      Case "CanvasContainerGadget" : ObjectID = CanvasGadget        (#PB_Any, X,Y,Width,Height, #PB_Canvas_Container)   ;Flag)
        CloseGadgetList()
      Case "CheckBoxGadget"        : ObjectID = CheckBoxGadget      (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "ComboBoxGadget"        : ObjectID = ComboBoxGadget      (#PB_Any, X,Y,Width,Height, Flag)
        For I = 1 To 3
          AddGadgetItem(ObjectID, -1, "Element "+Str(I))
        Next
        SetGadgetState(ObjectID, 0)
      Case "ContainerGadget"       : ObjectID = ContainerGadget     (#PB_Any, X,Y,Width,Height, #PB_Container_Single)  ;Flag)
        CloseGadgetList()
      Case "DateGadget"            : ObjectID = DateGadget          (#PB_Any, X,Y,Width,Height, "", Param1, Flag)   ;Caption, Param1, Flag)
      Case "EditorGadget"          : ObjectID = EditorGadget        (#PB_Any, X,Y,Width,Height, #PB_Editor_ReadOnly)
        ;SetWindowLongPtr_(GadgetID(ObjectID), #GWL_STYLE, GetWindowLongPtr_(GadgetID(ObjectID), #GWL_STYLE) | #WS_BORDER)   ;For Editor...
        For I = 1 To 3
          AddGadgetItem(ObjectID, I, "Editor Line "+Str(I))
        Next
        ;For testing
        ;SetGadgetColor(ObjectID, #PB_Gadget_BackColor, $AAFFEF) : SetGadgetColor(ObjectID, #PB_Gadget_FrontColor, $501400)
      Case "ExplorerComboGadget"   : ObjectID = ExplorerComboGadget (#PB_Any, X,Y,Width,Height, "", Flag)   ;Caption, Flag)        
      Case "ExplorerListGadget"    : ObjectID = ExplorerListGadget  (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "ExplorerTreeGadget"    : ObjectID = ExplorerTreeGadget  (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "FrameGadget"           : ObjectID = FrameGadget         (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "HyperLinkGadget"       : ObjectID = HyperLinkGadget     (#PB_Any, X,Y,Width,Height, Caption, Param1, Flag)
      Case "ImageGadget"           : ObjectID = ImageGadget         (#PB_Any, X,Y,Width,Height, ImageID(Geebee2Image), Flag)   ; Caption, Flag)
      Case "IPAddressGadget"
        ObjectID = IPAddressGadget                                  (#PB_Any, X,Y,Width,Height)
        SetGadgetState(ObjectID, MakeIPAddress(127, 0, 0, 1))
      Case "ListIconGadget"        : ObjectID = ListIconGadget      (#PB_Any, X,Y,Width,Height, Caption, Param1, Flag)
        AddGadgetColumn(ObjectID, 0, "Name", 100)
        AddGadgetColumn(ObjectID, 1, "Replica", 250)
        AddGadgetItem(ObjectID, -1, "Thomson"+Chr(10)+"X33: blablabla")
        AddGadgetItem(ObjectID, -1, "Thompson"+Chr(10)+"X33bis: i would say even more")
      Case "ListViewGadget"        : ObjectID = ListViewGadget      (#PB_Any, X,Y,Width,Height, Flag)
        For I = 1 To 3
          AddGadgetItem (ObjectID, -1, "List Element " + Str(I))
        Next
        SetGadgetState(ObjectID, 9)       
      Case "MDIGadget"         
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          ObjectID = MDIGadget                                      (#PB_Any, X,Y,Width,Height, Param1, Param2, Flag)
        CompilerEndIf
        ;Case "OpenGL"               : ObjectID = OpenGLGadget        (#PB_Any, X,Y,Width,Height)
      Case "OptionGadget"          : ObjectID = OptionGadget        (#PB_Any, X,Y,Width,Height, Caption)
      Case "PanelGadget"           : ObjectID = PanelGadget         (#PB_Any, X,Y,Width,Height)
        AddGadgetItem(ObjectID, -1, "Tab_1")
        AddGadgetItem(ObjectID, -1, "Tab_2")
        AddGadgetItem(ObjectID, -1, "Tab_3")
        SetGadgetState(ObjectID, 0)
        CloseGadgetList()
      Case "ProgressBarGadget"     : ObjectID = ProgressBarGadget   (#PB_Any, X,Y,Width,Height, Param1, Param2*100, Flag)
        SetGadgetState   (ObjectID, 50) 
      Case "ScintillaGadget"
        ;Share Scintilla.dll in current folder or path to Scintilla.dll
        If InitScintilla()
          ObjectID = ScintillaGadget                                (#PB_Any, X,Y,Width,Height, 0)   ;Param1)
          ScintillaSendMessage(ObjectID, #SCI_STYLESETFORE, 0, RGB(0, 0, 255))
          *Texte=UTF8(Caption)
          ScintillaSendMessage(ObjectID, #SCI_SETTEXT, 0, *Texte)
          FreeMemory(*Texte)
        EndIf
      Case "SplitterGadget"     
        If IsGadget(Param1) And IsGadget(Param2)
          ObjectID = SplitterGadget                                 (#PB_Any, X,Y,Width,Height, Param1, Param2, Flag)
        EndIf
      Case "ScrollAreaGadget"
        ;ObjectID = ScrollAreaGadget                                (#PB_Any, X,Y,Width,Height, Param1, Param2, Param3, Flag)
        ObjectID = ScrollAreaGadget                                 (#PB_Any, X,Y,Width,Height, Width*2, Height*2, Param3, Flag)
        CloseGadgetList()
      Case "ScrollBarGadget"       : ObjectID = ScrollBarGadget     (#PB_Any, X,Y,Width,Height, Param1, Param2*100, Param3, Flag) 
      Case "ShortcutGadget"        : ObjectID = ShortcutGadget      (#PB_Any, X,Y,Width,Height, Param1)  
      Case "SpinGadget"            : ObjectID = SpinGadget          (#PB_Any, X,Y,Width,Height, Param1, Param2*100, #PB_Spin_Numeric)
        SetGadgetState (ObjectID, (Param2*100-Param1)*2/3)
      Case "StringGadget"          : ObjectID = StringGadget        (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "StringMultiGadget"     : ObjectID = StringGadget        (#PB_Any, X,Y,Width,Height,Caption + " 1" +#CRLF$+ Caption + " 2", #ES_MULTILINE|#ES_AUTOVSCROLL|#ES_AUTOHSCROLL)
      Case "TextGadget"            : ObjectID = TextGadget          (#PB_Any, X,Y,Width,Height, Caption, Flag)
      Case "TrackBarGadget"        : ObjectID = TrackBarGadget      (#PB_Any, X,Y,Width,Height, Param1, Param2*100, Flag)
        SetGadgetState (ObjectID, (Param2*100-Param1)*2/3)
      Case "TreeGadget"            : ObjectID = TreeGadget          (#PB_Any, X,Y,Width,Height, Flag)
        AddGadgetItem(ObjectID, -1, "Node", 0,  0): AddGadgetItem(ObjectID, -1, "Sub-element", 0,  1): AddGadgetItem(ObjectID, -1, "Element", 0,  0):SetGadgetItemState(ObjectID, 0, #PB_Tree_Expanded)
      Case "WebGadget"             : ObjectID = WebGadget           (#PB_Any, X,Y,Width,Height, Caption)
    EndSelect
    
    If ObjectID   ;0 for ScintillaGadget If InitScintilla()=#False, Scintilla.dll not found in the current folder or in path
      SetWindowLongPtr_(GadgetID(ObjectID), #GWL_STYLE, GetWindowLongPtr_(GadgetID(ObjectID), #GWL_STYLE) | #WS_BORDER)
      HideGadget(ObjectID,#True)
      AddImage(ObjectID, CaptureGadget(ObjectID), GadgetX(ObjectID), GadgetY(ObjectID))
      If Model = "PanelGadget"   ;Tabs can not be the last element: MoveElement(Images(), #PB_List_First)
        For I = 0 To CountGadgetItems(ObjectID)-1
          AddImage(ObjectID, 0, GadgetX(ObjectID), GadgetY(ObjectID), I)
        Next
      EndIf
      CurrentItemGadget = ObjectID
    EndIf
    ProcedureReturn ObjectID
  EndProcedure 
  
  Procedure CaptureGadget(Gadget)
    Protected Img,hDC,SizeTextH
    Protected hSpin,SpinSize.Rect, SpinImg
    Protected TmpImage.i, EditorText.s, Color.i, CountLine, I
    Img = CreateImage(#PB_Any,GadgetWidth(Gadget),GadgetHeight(Gadget))
    If IsGadget(Gadget)
      hDC =  StartDrawing(ImageOutput(Img))
      If hDC
        ;Gadget_BackColor
        Color = GetGadgetColor(Gadget, #PB_Gadget_BackColor)
        If Color = #PB_Default : Color = $FFFFFF : EndIf
        DrawingMode(#PB_2DDrawing_Default)
        Box(0, 0, OutputWidth(), OutputHeight(), Color)
        
        If GadgetType(Gadget) = #PB_GadgetType_Spin   ;Specific SpinGadget (Part1)
          hSpin = FindWindowEx_(GetParent_(GadgetID(Gadget)), GadgetID(Gadget), 0, 0)
          If hSpin
            GetClientRect_(hSpin,SpinSize)
            SendMessage_(hSpin,#WM_PRINT,hDC, #PRF_CHILDREN|#PRF_CLIENT|#PRF_NONCLIENT| #PRF_ERASEBKGND)
            SpinImg = GrabDrawingImage(#PB_Any, 0,0,GadgetWidth(Gadget)+18,GadgetHeight(Gadget)+25)
          EndIf
        EndIf
        
        SendMessage_(GadgetID(Gadget),#WM_PRINT,hDC, #PRF_CHILDREN|#PRF_CLIENT|#PRF_NONCLIENT|#PRF_OWNED|#PRF_ERASEBKGND)
        
        Select GadgetType(Gadget)
          Case #PB_GadgetType_ComboBox   ;Specific ComboBoxGadget
            DrawingFont(GetGadgetFont(Gadget))
            DrawingMode(#PB_2DDrawing_Transparent)
            SizeTextH = TextHeight(" ")
            DrawText(4, (OutputHeight()-SizeTextH)/2, GetGadgetText(Gadget), $000000)
          Case #PB_GadgetType_Editor   ;Specific EditorGadget
            EditorText = GetGadgetText(Gadget)
            If EditorText <> ""
              DrawingFont(GetGadgetFont(Gadget))
              Color = GetGadgetColor(Gadget, #PB_Gadget_FrontColor)
              If Color = #PB_Default : Color = $000000 : EndIf
              DrawingMode(#PB_2DDrawing_Transparent)
              SizeTextH = TextHeight(" ")
              CountLine = CountString(EditorText, #CRLF$)+1
              For I = 1 To CountLine
                DrawText(2, (I-1)*SizeTextH, StringField(EditorText, I, #LF$), Color)
              Next
            EndIf
          Case #PB_GadgetType_ExplorerCombo   ;Specific ExplorerComboGadget
            DrawingFont(GetGadgetFont(Gadget))
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawAlphaImage(ImageID(#ThisPC), 4, (OutputHeight()-ImageHeight(#ThisPC))/2)
            SizeTextH = TextHeight(" ")
            If GetGadgetText(Gadget) = ""
              ;Localized Computer Name: \SOFTWARE\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\LocalizedString,@%SystemRoot%\system32\windows.storage.dll,-9216
              DrawText(8+ImageWidth(#ThisPC), (OutputHeight()-SizeTextH)/2, "This PC", $000000)
            Else
              DrawText(8+ImageWidth(#ThisPC), (OutputHeight()-SizeTextH)/2, GetGadgetText(Gadget), $000000)
            EndIf
          Case #PB_GadgetType_Spin  ;Specific SpinGadget (Part2)
            If IsImage(SpinImg)
              DrawImage(ImageID(SpinImg),ImageWidth(SpinImg)-(SpinSize\right+18),0)
              FreeImage(SpinImg)
            EndIf
          Case 33  ;Specific CanvasGadget
                   ;Image and Text from Properties. Images()\ImageID, Images()\Text
            DrawingMode(#PB_2DDrawing_Default)
            DrawImage(ImageID(Geebee2Image), 0, 0, ImageWidth(Geebee2Image), ImageHeight(Geebee2Image))
            ;DrawImage(ImageID(Geebee2Image), 0, 0, OutputWidth(), OutputHeight())
            DrawingFont(GetGadgetFont(#PB_Default))
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(5, 5, "Canvas", #Blue, #White)
            SetGadgetAttribute(Gadget,#PB_Canvas_Image,ImageID(Geebee2Image))
        EndSelect
        
        StopDrawing()
      EndIf 
    EndIf
    ProcedureReturn Img
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure DrawGrid(GridArea)
    Protected X.i, Y.i
    ;Background for full area and drawing area  
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, OutputWidth(), OutputHeight(), #ScrollAreaColor)
    Box(0, 0, MaxSizeX, MaxSizeY, #GridBackground)
    If GridArea
      ;Draw Grid Lines
      If ShowGrid = #True 
        For X = 0 To MaxSizeX
          For Y = 0 To MaxSizeY
            Line(0,Y,MaxSizeX,1, #GridColor)
            Y+GridSize-1
          Next
          Line(X,0,1,MaxSizeY, #GridColor)
          X+GridSize-1
        Next
      EndIf
    Else
      ;DrawingMode(#PB_2DDrawing_AlphaBlend)
      ;Box(0, 0, MaxSizeX, MaxSizeY, $40C0C0C0)
      Box(0, 0, MaxSizeX, MaxSizeY, $FFFFFF)
    EndIf
    ;Main Window Border Color (CurrentDrawArea=10 Or Level=0)
    If CurrentDrawArea = 10
      DrawingMode(#PB_2DDrawing_Default)
      Line(0, UserScreen_Height, UserScreen_Width+1, 1, #WinHandleColor)
      Line(UserScreen_Width, 0, 1, UserScreen_Height+1, #WinHandleColor)
    EndIf
  EndProcedure
  
  Procedure DrawCanvas(GridArea=#True, HandelOnMove=#True)
    If StartDrawing(CanvasOutput(CurrentDrawArea))
      DrawGrid(GridArea)
      ;Draw All Captured Image in Same Level,Parent,Tab, With z-Order 
      With Images()
        ForEach Images()
          If \Level = Level And \ParentGadget = ParentGadget And \Tab = Tab  And \Gadget <> \ParentGadget
            ;Specific FrameGadget: Draw Border Double with a Transparent image to see the gadgets included and be able to select them
            If GadgetType(\Gadget) = #PB_GadgetType_Frame
              DrawAlphaImage(ImageID(\Capture), \X, \Y, 80)
              DrawingMode(#PB_2DDrawing_Outlined)
              Line(\X+1, \Y+1, 1, \Height-2, $A0A0A0) : Line(\X+2, \Y+2, 1, \Height-4, $696969)
              Line(\X+1, \Y+1, \Width-2, 1, $A0A0A0)  : Line(\X+2, \Y+2, \Width-4, 1, $696969)
              Line(\X+\Width-2, \Y+1, 1, \Height-2, $FFFFFF) : Line(\X+\Width-3, \Y+2, 1, \Height-4, $E3E3E3)
              Line(\X+1, \Y+\Height-2, \Width-2, 1, $FFFFFF) : Line(\X+2, \Y+\Height-3, \Width-4, 1, $E3E3E3)
            Else          
              DrawImage(ImageID(\Capture), \X, \Y)   ; Draw all Images with z-Order
            EndIf
            DrawingMode(#PB_2DDrawing_Outlined)
            If GroupSelectedGadget = #True And \Selected = #True
              Box(\X, \Y, \Width, \Height, #SelectedHandelColorGroup)
            Else  
              Box(\X, \Y, \Width, \Height, $FFA0A0)   ;Set Default Gadgets Border for those who don't have a contour drawn
            EndIf
          EndIf
        Next
        
        If GridArea = #True
          ;Draw Selected Gadget Border
          If CurrentItemGadget
            ;Gadget Contour #Blue
            DrawingMode(#PB_2DDrawing_Outlined)
            If GroupSelectedGadget = #True
              Box(\X, \Y, \Width, \Height, #SelectedHandelColorGroup)
            Else 
              Box(\X, \Y, \Width, \Height, #SelectedHandelColor)
            EndIf
            
            ;Handle: North, North-East, East, South-East, South, South-West, West, North-West
            If HandelOnMove = #True
              HideHandle(#False)
            Else
              HideHandle(#True)
            EndIf
            ResizeGadget(Handle(1), \X+(\Width-#HandelSize)/2, \Y-(#HandelSize/2),         #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(1), Images())
            ResizeGadget(Handle(2), \X+\Width-(#HandelSize/2), \Y-(#HandelSize/2),         #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(2), Images())
            ResizeGadget(Handle(3), \X+\Width-(#HandelSize/2), \Y+(\Height-#HandelSize)/2, #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(3), Images())
            ResizeGadget(Handle(4), \X+\Width-(#HandelSize/2), \Y+\Height-(#HandelSize/2), #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(4), Images())
            ResizeGadget(Handle(5), \X+(\Width-#HandelSize)/2, \Y+\Height-(#HandelSize/2), #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(5), Images())
            ResizeGadget(Handle(6), \X-(#HandelSize/2),        \Y+\Height-(#HandelSize/2), #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(6), Images())
            ResizeGadget(Handle(7), \X-(#HandelSize/2),        \Y+(\Height-#HandelSize)/2, #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(7), Images())
            ResizeGadget(Handle(8), \X-(#HandelSize/2),        \Y-(#HandelSize/2),         #PB_Ignore, #PB_Ignore) : SetGadgetData(Handle(8), Images())
          Else
            If PosDim\X0 <> #PB_Ignore And PosDim\Y0 <> #PB_Ignore
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(PosDim\X0, PosDim\Y0, X-PosDim\X0, Y-PosDim\Y0, #RectSelection)
            EndIf
            ;Shadow: DrawingMode(#PB_2DDrawing_AlphaBlend) : Box(\X+5, \Y+5, \Width, \Height, RGBA($42, $42, $42, $50)) : DrawImage(ImageID(\Capture), \X, \Y, \Width, \Height)
          EndIf
        EndIf
      EndWith  
      StopDrawing()
    EndIf
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure Group_Selected()
    If GroupSelectedGadget = #True
      GroupID + 1
      With Images()
        ForEach Images()
          If \Selected = #True
            \Group = GroupID
          EndIf
        Next
        LastElement(Images())
        If CurrentItemGadget
          AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
        EndIf
        SetActiveGadget(CurrentDrawArea)
      EndWith
    EndIf
  EndProcedure
  
  Procedure UnGroup_Selected(Gadget.i)
    Protected SavGroup.i
    With Images()
      If GroupSelectedGadget = #True
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            If \Group > 0
              SavGroup = \Group
            EndIf
          EndIf
        Next
        If SavGroup > 0
          ForEach Images()
            If \Group = SavGroup
              \Group = 0
              If \Gadget <> Gadget And \Gadget <> \ParentGadget
                \Selected = #False
              EndIf
            EndIf
          Next
          GroupSelectedGadget = GroupGadgetEnabled()
          DrawCanvas(#True)
        EndIf
        LastElement(Images())
        If CurrentItemGadget
          AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
        EndIf
        SetActiveGadget(CurrentDrawArea)
      EndIf
    EndWith
  EndProcedure
  
  Procedure.i GroupGadgetEnabled()
    Protected CountSelectedGadget.i, iReturn.i
    With Images()
      PushListPosition(Images())
      ForEach Images()
        If \Selected = #True
          CountSelectedGadget +1
        EndIf
      Next
      PopListPosition(Images())
    EndWith
    If CountSelectedGadget > 1
      iReturn = #True
    EndIf
    ProcedureReturn iReturn     
  EndProcedure
  
  Procedure SelectedGroup(IdGroup.i, GroupSelected.b=#False)
    With Images()
      PushListPosition(Images())
      ForEach Images()
        If \Type <> 0   ;OpenWindow
          If \Group = IdGroup
            \Selected = GroupSelected
            ;MoveElement(Images(), #PB_List_Last)
          EndIf
        EndIf
      Next
      PopListPosition(Images())
    EndWith
  EndProcedure
  
  Procedure SelectedGadget(Gadget.i, ControlKeyPressed.b=#False)
    Protected SavGroupSelectedGadget.b = GroupSelectedGadget, CountSelectedGadget.i, I.i
    With Images()
      If Gadget = 0
        GroupSelectedGadget = #False
      Else
        If ControlKeyPressed = #False
          ForEach Images()
            If \Gadget = Gadget And \Gadget <> \ParentGadget
              If GroupSelectedGadget = #True And \Selected = #True
                GroupSelectedGadget = #True
              Else
                GroupSelectedGadget = #False
              EndIf
            EndIf
          Next
        Else
          ;the real status is done below (If >1 Gadget selected) via the procedure GroupGadgetEnabled()
          GroupSelectedGadget = #True
        EndIf
      EndIf
      
      If GroupSelectedGadget = #False
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            \Selected = #True
            ;MoveElement(Images(), #PB_List_Last)
          Else
            \Selected = #False
            ;MoveElement(Images(), #PB_List_First)
            ;NextElement(Images()) 
          EndIf
          If \Group > 0
            SelectedGroup(\Group, \Selected)
            GroupSelectedGadget = #True
          EndIf
        Next
      EndIf
      
      If GroupSelectedGadget = #True   ;Not Else GroupSelectedGadget can be updated to #True if Group Selected
        ForEach Images()
          If \Gadget = Gadget And \Gadget <> \ParentGadget
            \Selected = #True
          EndIf
          If \Group > 0
            SelectedGroup(\Group, \Selected)
          EndIf
        Next
        GroupSelectedGadget = GroupGadgetEnabled()
        If GroupSelectedGadget = #True
          ;Sort with the selected gadgets at the end (On Top), the current selected item remains the last one  
          SortStructuredList(Images(), #PB_Sort_Ascending, OffsetOf(CaptureGadget\Selected), TypeOf(CaptureGadget\Selected))
        EndIf
      EndIf
    EndWith
    If SavGroupSelectedGadget <> GroupSelectedGadget
      ;PostEvent(#PB_Event_Gadget, 0, 0, #SVD_Group)
    EndIf  
  EndProcedure
  
  Procedure SetCurrentGadget(Gadget.i, Selection.b=#False)
    With Images()
      If Selection = #True
        If LastElement(Images())   ;Search for Hit, Starting From End (z-Order)
          Repeat
            If \Gadget = Gadget And \Gadget <> \ParentGadget
              MoveElement(Images(), #PB_List_Last)
              CurrentItemGadget = \Gadget
              CurrentDrawArea = \ParentDrawArea
            EndIf
          Until PreviousElement(Images())=0
        EndIf
        If CurrentItemGadget
          SelectedGadget(CurrentItemGadget)
        EndIf
      EndIf
      DrawCanvas(#True)
      If CurrentItemGadget
        AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
      EndIf
      SetActiveGadget(CurrentDrawArea)
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure DeleteGadget(Gadget.i)
    Protected CountSelectedGadget.i, SavContainerGadget.i, Rtn.i
    With Images()
      If Gadget And IsGadget(Gadget)
        ;Are you sure you want to remove the selected gadgets message
        ForEach Images()
          If \Selected = #True
            CountSelectedGadget +1
            If CountSelectedGadget > 1 : Break : EndIf
            Select \Type
              Case #PB_GadgetType_Container, #PB_GadgetType_Panel, #PB_GadgetType_ScrollArea   ;Canvas Container!
                SavContainerGadget = \Gadget
                PushListPosition(Images())
                ForEach Images()
                  If \ParentGadget = SavContainerGadget And \Gadget <> \ParentGadget
                    CountSelectedGadget +1
                    Break
                  EndIf
                Next
                PopListPosition(Images())            
                If CountSelectedGadget > 1 : Break : EndIf
            EndSelect
          EndIf
        Next
        
        If CountSelectedGadget > 1
          Rtn = MessageRequester("Confirm Delete", "Multiple Gadgets will be Deleted." +#CRLF$+#CRLF$+ "Are you Sure you want To Delete the Selected Gadgets ?", #PB_MessageRequester_Info|#PB_MessageRequester_YesNo)
        Else
          Rtn = 6
        EndIf
        ;Rtn = 6 the YES button was chosen (Result=7 for the NO button)
        If Rtn = 6
          ;Deletion done in 2 parts, because children in a container are automatically deleted along with the Container
          ;Debug "*** Delete Gadget " +Str(Gadget) + " Type " + Str(GadgetType(Gadget))
          ForEach Images()
            If \Selected = #True
              FreeGadget(\Gadget)
            EndIf
          Next
          ;Second Part. If Gadget does not exist, delete its captured image and remove the item from the list. 
          ForEach Images()
            If IsGadget(\Gadget) = 0
              If IsImage(\Capture) : FreeImage(\Capture) : EndIf
              ;If ImagePath <> "" : RemoveImage(ImagePath) : EndIf
              ;If TmpFontID <> 0 : RemoveFont(TmpFontID) : EndIf
              DeleteElement(Images())
            EndIf
          Next
          HideHandle(#True)
          RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
          GroupSelectedGadget = #False
          CurrentItemGadget = 0
          PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore   ;To not draw the selection rectangle
          DrawCanvas(#True)
        Else
          SetCurrentGadget(Gadget.i, #True)
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure MoveGadgetGroup(Gadget.i, AddX.i, AddY.i)
    Protected MiniX.i=9999, MaxiX.i, MiniY.i=9999, MaxiY.i, X1.i, Y1.i
    With Images()
      PushListPosition(Images())
      ;Mini and Maxi of the Group
      ForEach Images()
        If \Selected = #True
          If \X < MiniX : MiniX = \X : EndIf
          If \Y < MiniY : MiniY = \Y : EndIf
          If \X + \Width > MaxiX : MaxiX = \X + \Width : EndIf
          If \Y + \Height > MaxiY : MaxiY = \Y + \Height : EndIf
        EndIf
      Next
      
      ;Calculate AddX, AddY following Snap to Grid and mini maxi related to Group  
      ForEach Images()
        If \Gadget = Gadget And \Gadget <> \ParentGadget
          If \Lock = #False
            If AddX <> 0
              X1 = GridMatch(\X+AddX, DragSpace, \X - MiniX, \X + (MaxSizeX-MaxiX))
              AddX = X1 - PosDim\X0
            EndIf
            If AddY <> 0
              Y1 = GridMatch(\Y+AddY, DragSpace, \Y - MiniY, \Y + (MaxSizeY-MaxiY))
              AddY = Y1 - PosDim\Y0 
            EndIf
          EndIf
        EndIf
      Next       
      
      If AddX <> 0 Or AddY <> 0
        ForEach Images()
          If \Selected = #True And \Lock = #False
            \X = \X + AddX : \Y = \Y + AddY
            ResizeGadget(\Gadget, \X, \Y, #PB_Ignore, #PB_Ignore)
            If \Gadget = Gadget
              PosDim\X0 = \X : PosDim\Y0 = \Y
              ;PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)
            EndIf
          EndIf
        Next
        DrawCanvas(#True, HandelOnMove)
      EndIf
      PopListPosition(Images())
    EndWith
  EndProcedure
  
  Procedure MoveGadget(AddX.i, AddY.i)
    Protected X1.i, Y1.i, I.i
    With Images()
      If LastElement(Images())
        ;If \Lock = #False
        X1 = GridMatch(\X+AddX, DragSpace, 0, MaxSizeX-\Width)   ;MaxSizeX
        Y1 = GridMatch(\Y+AddY, DragSpace, 0, MaxSizeY-\Height)  ;MaxSizeY
        If X1 <> PosDim\X0 Or Y1 <> PosDim\Y0
          \X = X1 : \Y = Y1
          ResizeGadget(\Gadget, \X, \Y, #PB_Ignore, #PB_Ignore)
          DrawCanvas(#True, HandelOnMove)
          PosDim\X0 = \X : PosDim\Y0 = \Y
          ;PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @PosDim)
        EndIf
        ;EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure MoveGadgetKeyDown()
    Protected KbdEvent.i
    With Images()
      KbdEvent = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Key)
      If KbdEvent = #PB_Shortcut_Up Or KbdEvent = #PB_Shortcut_Right Or KbdEvent = #PB_Shortcut_Down Or KbdEvent = #PB_Shortcut_Left
        If LastElement(Images())
          PosDim\X0 = \X : PosDim\Y0 = \Y
          If GroupSelectedGadget = #True
            Select KbdEvent
              Case #PB_Shortcut_Up
                MoveGadgetGroup(CurrentItemGadget, 0, -DragSpace)
              Case #PB_Shortcut_Right
                MoveGadgetGroup(CurrentItemGadget, DragSpace, 0)
              Case #PB_Shortcut_Down
                MoveGadgetGroup(CurrentItemGadget, 0, DragSpace)
              Case #PB_Shortcut_Left
                MoveGadgetGroup(CurrentItemGadget, -DragSpace, 0)
            EndSelect
          Else
            Select KbdEvent
              Case #PB_Shortcut_Up
                MoveGadget(0, -DragSpace)
              Case #PB_Shortcut_Right
                MoveGadget(DragSpace, 0)
              Case #PB_Shortcut_Down
                MoveGadget(0, DragSpace)
              Case #PB_Shortcut_Left
                MoveGadget(-DragSpace, 0)
            EndSelect
          EndIf
        EndIf
      EndIf
    EndWith  
  EndProcedure
  
  Procedure ResizeGadgetKeyDown()
    Protected Width1.i, Height1.i, KbdEvent.i
    With Images()
      If LastElement(Images())
        KbdEvent = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Key)
        If KbdEvent = #PB_Shortcut_Up Or KbdEvent = #PB_Shortcut_Right Or KbdEvent = #PB_Shortcut_Down Or KbdEvent = #PB_Shortcut_Left
          PosDim\Width0 = \Width : PosDim\Height0 = \Height
          Width1 = \Width : Height1 = \Height
          Select KbdEvent
            Case #PB_Shortcut_Up
              Height1 = GridMatch(\Height-DragSpace, DragSpace, #MinSize)
            Case #PB_Shortcut_Right
              Width1  = GridMatch(\Width+DragSpace, DragSpace, 0, MaxSizeX-\X)
            Case #PB_Shortcut_Down
              Height1 = GridMatch(\Height+DragSpace, DragSpace, 0, MaxSizeY-\Y)
            Case #PB_Shortcut_Left
              Width1  = GridMatch(\Width-DragSpace, DragSpace, #MinSize)
          EndSelect
          
          If PosDim\Width0 <> Width1 Or PosDim\Height0 <> Height1
            \Width = Width1 : \Height = Height1
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, \Height)
            FreeImage(\Capture)
            \Capture = CaptureGadget(\Gadget)
            DrawCanvas(#True)
            PosDim\Width0 = \Width : PosDim\Height0 = \Height
            ;PostEvent(#PB_Event_Gadget, 0, Gadget, #SVD_Gadget_Resize, @SavPosDim)
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  ;- ------------------------------------
  Procedure MoveDrawAreaEVENT()
    Protected ControlKeyPressed.b, X1.i, Y1.i, I.i
    With PosDim
      Select EventType()
          
        Case #PB_EventType_LostFocus
          RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
          
        Case #PB_EventType_KeyDown
          If CurrentItemGadget
            If GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
              ResizeGadgetKeyDown()
            Else
              MoveGadgetKeyDown()
            EndIf
          EndIf
          
        Case #PB_EventType_KeyUp
          DrawCanvas(#True)
          
        Case #PB_EventType_LeftButtonDown
          X = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseX)
          Y = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseY)
          \X0 = X : \Y0 = Y
          If HitOver(X,Y)
            HideHandle(#False)   ;After DrawCanvas(#True). Handle in (0,0) when entering a container click a button
            AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
          Else
            HideHandle(#True)
            RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
          EndIf
          If GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Control
            ControlKeyPressed = #True
          EndIf
          SelectedGadget(CurrentItemGadget, ControlKeyPressed)
          DrawCanvas(#True)
          Drag = #True
          ;Debug "DrawArea LeftButtonDown. Current Item: " + Str(CurrentItemGadget) + " (" + Str(\X0) + "," + Str(\Y0) + ") Drag: " + Str(Drag)
          
        Case #PB_EventType_LeftButtonUp
          If CurrentItemGadget = 0
            If \X0 <> #PB_Ignore And \Y0 <> #PB_Ignore
              If HitInside(Min(\X0,X),Max(\X0,X),Min(\Y0,Y),Max(\Y0,Y))
                HideHandle(#False)
                AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
              Else
                HideHandle(#True)
                RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
              EndIf
            EndIf
          EndIf
          ;SelectedGadget(CurrentItemGadget)
          X = #PB_Ignore : Y = #PB_Ignore : \X0 = #PB_Ignore : \Y0 = #PB_Ignore 
          DrawCanvas(#True)
          Drag = #False
          ;Debug "DrawArea LeftButtonUp. Current Item: " + Str(CurrentItemGadget) + " Drag: " + Str(Drag)
          
        Case #PB_EventType_MouseMove
          X = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseX)
          Y = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseY)
          If Drag = #True
            If CurrentItemGadget
              If X - CurrentItemOffsetX <> \X0 Or Y - CurrentItemOffsetY <> \Y0
                If GroupSelectedGadget = #True
                  MoveGadgetGroup(CurrentItemGadget, X - CurrentItemOffsetX - \X0, Y - CurrentItemOffsetY - \Y0)
                Else
                  MoveGadget(X - CurrentItemOffsetX - \X0, Y - CurrentItemOffsetY - \Y0)
                EndIf
              EndIf  
            Else
              DrawCanvas(#True)
            EndIf
          Else
            MouseOver(X,Y)
          EndIf
          
        Case #PB_EventType_RightDoubleClick
          If ParentGadget   ;<> 0 Main Canvas
            CloseContainer()
            ;Debug "DrawArea RightDoubleClick. Current Item (Close Container): " + Str(CurrentItemGadget) + " Parent: " + Str(ParentGadget)
          EndIf
          
        Case #PB_EventType_LeftDoubleClick
          X = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseX)
          Y = GetGadgetAttribute(CurrentDrawArea, #PB_Canvas_MouseY)
          If HitOver(X,Y)
            ;If Not Level > 0 To keep one level only without being able to open the Containers. 
            ;Not mandatory, but limited it to 9 levels.
            If Not Level > 8
              Select GadgetType(CurrentItemGadget)
                Case #PB_GadgetType_Container, #PB_GadgetType_Panel, #PB_GadgetType_ScrollArea   ;Canvas Container!
                  OpenContainer(CurrentItemGadget)
                  ;Debug "DrawArea LeftDoubleClick. Current Item (Open Container): " + Str(CurrentItemGadget) + " Parent: " + Str(ParentGadget) 
              EndSelect
            EndIf
          EndIf
          X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore
          Drag = #False
          
      EndSelect
    EndWith
  EndProcedure
  
  Procedure ResizeHandleEVENT()
    Protected *Images.CaptureGadget = GetGadgetData(EventGadget())
    Protected X.i, Y.i, X1.i, Y1.i, Width1.i, Height1.i
    If *Images
      With *Images
        
        Select EventType()
          Case #PB_EventType_LeftButtonDown
            CurrentItemOffsetX = DrawAreaOffsetX + GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX)
            CurrentItemOffsetY = DrawAreaOffsetY + GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
            Select GadgetType(\ParentGadget)
              Case #PB_GadgetType_Panel
                ;Windows 10 size: Panel_TabHeight=22, Panel_ItemWidth=Width-8 (Leftborder=3,Rightborder=5), Panel_ItemHeight=Height-Panel_TabHeight-5 (Topborder=1,Bottomborder=4)
                CurrentItemOffsetY + GetGadgetAttribute(\ParentGadget,#PB_Panel_TabHeight)
              Case #PB_GadgetType_ScrollArea
                CurrentItemOffsetX - GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_X)
                CurrentItemOffsetY - GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_Y)
            EndSelect
            PosDim\X0 = \X : PosDim\Y0 = \Y : PosDim\Width0 = \Width : PosDim\Height0 = \Height
            CurrentItemGadget = \Gadget
            Resize = #True
            ;Debug "Handle LeftButtonDown. Current Item: " + Str(CurrentItemGadget) + " (" + Str(PosDim\X0) + "," + Str(PosDim\Y0) + "," +Str(PosDim\Width0) + "," + Str(PosDim\Height0) + ") Resize: " + Str(Resize)
            
          Case #PB_EventType_LeftButtonUp
            X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
            DrawCanvas(#True)
            Resize = #False
            ;Debug "Handle LeftButtoUp. Current Item: " + Str(CurrentItemGadget) + " Resize: " + Str(Resize)
            
          Case #PB_EventType_MouseMove
            If Resize = #True
              X = WindowMouseX(0) - CurrentItemOffsetX
              Y = WindowMouseY(0) - CurrentItemOffsetY
              If LastElement(Images())
                
                X1 = \X : Y1 = \Y : Width1 = \Width: Height1 = \Height
                Select EventGadget()
                  Case Handle(1)   ;Handle top, middle (N)
                    Height1 = GridMatch((PosDim\Y0 + PosDim\Height0)-(Y+#HandelSize/2), DragSpace, #MinSize, PosDim\Y0 + PosDim\Height0)
                    Y1 = GridMatch(Y+#HandelSize/2, DragSpace, 0, (PosDim\Y0 + PosDim\Height0)-Height1)
                  Case Handle(2)   ;Handle top, right (NE)
                    Width1 = GridMatch(X, DragSpace, PosDim\X0+#MinSize, MaxSizeX)-PosDim\X0
                    Height1 = GridMatch((PosDim\Y0 + PosDim\Height0)-(Y+#HandelSize/2), DragSpace, #MinSize, PosDim\Y0 + PosDim\Height0)
                    Y1 = GridMatch(Y+#HandelSize/2, DragSpace, 0, (PosDim\Y0 + PosDim\Height0)-Height1)
                  Case Handle(3)   ;Handle middle, right (E)
                    Width1 = GridMatch(X, DragSpace, PosDim\X0+#MinSize, MaxSizeX)-PosDim\X0
                  Case Handle(4)   ;Handle bottom, right (SE)
                    Width1 = GridMatch(X, DragSpace, PosDim\X0+#MinSize, MaxSizeX)-PosDim\X0
                    Height1 = GridMatch(Y, DragSpace, PosDim\Y0+#MinSize, MaxSizeY)-PosDim\Y0
                  Case Handle(5)   ;Handle bottom, middle (S)
                    Height1 = GridMatch(Y, DragSpace, PosDim\Y0+#MinSize, MaxSizeY)-PosDim\Y0
                  Case Handle(6)   ;Handle bottom, left (SW)
                    Width1 = GridMatch((PosDim\X0 + PosDim\Width0)-(X+#HandelSize/2), DragSpace, #MinSize, PosDim\X0 + PosDim\Width0)
                    Height1 = GridMatch(Y, DragSpace, PosDim\Y0+#MinSize, MaxSizeY)-PosDim\Y0
                    X1 = GridMatch(X+#HandelSize/2, DragSpace, 0, (PosDim\X0 + PosDim\Width0)-Width1)
                  Case Handle(7)   ;Handle middle, left (W)
                    Width1 = GridMatch((PosDim\X0 + PosDim\Width0)-(X+#HandelSize/2), DragSpace, #MinSize, PosDim\X0 + PosDim\Width0)
                    X1 = GridMatch(X+#HandelSize/2, DragSpace, 0, (PosDim\X0 + PosDim\Width0)-Width1)
                  Case Handle(8)   ;Handle top, left (NW)
                    Width1 = GridMatch((PosDim\X0 + PosDim\Width0)-(X+#HandelSize/2), DragSpace, #MinSize, PosDim\X0 + PosDim\Width0)
                    Height1 = GridMatch((PosDim\Y0 + PosDim\Height0)-(Y+#HandelSize/2), DragSpace, #MinSize, PosDim\Y0 + PosDim\Height0)
                    X1 = GridMatch(X+#HandelSize/2, DragSpace, 0, (PosDim\X0 + PosDim\Width0)-Width1)
                    Y1 = GridMatch(Y+#HandelSize/2, DragSpace, 0, (PosDim\Y0 + PosDim\Height0)-Height1)
                EndSelect
                
                If X1 <> PosDim\X0 Or Y1 <> PosDim\Y0 Or Width1 <> PosDim\Width0 Or Height1 <> PosDim\Height0
                  PosDim\X0 = X1 : PosDim\Y0 = Y1 : PosDim\Width0 = Width1 : PosDim\Height0 = Height1
                  \X = X1 : \Y = Y1 : \Width = Width1 : \Height= Height1
                  ResizeGadget(\Gadget, \X, \Y, \Width, \Height)
                  FreeImage(\Capture)
                  \Capture = CaptureGadget(\Gadget)
                  DrawCanvas(#True)
                EndIf
              EndIf
            EndIf
            
        EndSelect
      EndWith
    EndIf
  EndProcedure
  
  Procedure ResizeWinEVENT()
    Static Selected.b, MiniX.i, MiniY.i
    Protected Width1.i, Height1.i
    
    Select EventType()
      Case #PB_EventType_LeftButtonDown
        Selected = #True
        ;ParentPosDim()
        CurrentItemOffsetX = GadgetX(#ScrollDrawArea) + GetGadgetAttribute(Handle(0), #PB_Canvas_MouseX) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X)
        CurrentItemOffsetY = GadgetY(#ScrollDrawArea) + GetGadgetAttribute(Handle(0), #PB_Canvas_MouseY) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)
        PosDim\X0 = 0 : PosDim\Y0 = 0 : PosDim\Width0 = UserScreen_Width : PosDim\Height0 = UserScreen_Height
        ;Specify the minimum width and height according to the gadgets
        MiniX.i=#MinSize : MiniY.i=#MinSize
        With Images()
          ForEach Images()
            If \Level = 0 And \ParentGadget = 0 And \Gadget <> \ParentGadget
              If \X + \Width > MiniX : MiniX = \X + \Width : EndIf
              If \Y + \Height > MiniY : MiniY = \Y + \Height : EndIf
            EndIf
          Next
        EndWith
        ;CurrentItemGadget = 0
        
      Case #PB_EventType_LeftButtonUp
        Selected = #False
        
      Case #PB_EventType_MouseMove
        If Selected = #True
          Width1 = WindowMouseX(0)-CurrentItemOffsetX-1
          Width1 = GridMatch(Width1, DragSpace, MiniX, GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_InnerWidth) - 10)
          Height1 = WindowMouseY(0)-CurrentItemOffsetY-1
          Height1 = GridMatch(Height1, DragSpace, MiniY, GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_InnerHeight) - 10)
          If PosDim\Width0 <> Width1 Or PosDim\Height0 <> Height1
            UserScreen_Width = Width1 : UserScreen_Height = Height1
            MaxSizeX = UserScreen_Width : MaxSizeY = UserScreen_Height
            ResizeGadget(Handle(0), UserScreen_Width, UserScreen_Height, #PB_Ignore, #PB_Ignore)
            PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore  ;To not draw the selection rectangle
            DrawCanvas(#True)
            PosDim\X0 = 0 : PosDim\Y0 = 0 : PosDim\Width0 = UserScreen_Width : PosDim\Height0 = UserScreen_Height
            ;PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_Window_ReSize, @SavPosDim)   ;Updates the 4 SpinGadget(Width,Height)+UserScreen_Width,UserScreen_Height+Resize(WinHandle)+DrawFullDrawingArea
          EndIf
        EndIf
        
    EndSelect
  EndProcedure
  
  Procedure ChangeDisabledPanelTab()
    ;If a tab is changed on a higher level, the Panel drawing area needs to be redrawn and we have to send a left mouse click to the current drawing area
    With Images()
      ForEach Images()
        If \Gadget = EventGadget() And \Gadget <> \ParentGadget
          SetGadgetState(\Gadget, \CurrentTab)
          RedrawWindow_(GadgetID(\DrawArea), #Null, #Null, #RDW_INVALIDATE|#RDW_ERASE|#RDW_ALLCHILDREN|#RDW_UPDATENOW)
          Break
        EndIf
      Next
    EndWith
    SendMessage_(GadgetID(CurrentDrawArea), #WM_LBUTTONDOWN, #False, 0)
    SendMessage_(GadgetID(CurrentDrawArea), #WM_LBUTTONUP  , #False, 0)
  EndProcedure  
  
  Procedure ChangePanelTab()
    Protected I.i
    With Images()
      ;Debug "Change Panel Gadget: " + Str(EventGadget()) + " Current Tab: " + Str(GetGadgetState(EventGadget()))
      ; -------------------------------------
      ; 1st Part: Close the Container Gadget List, Unbind and disable and hide the Canvas Container we Close
      ;           Open the Panel Gadget List on the new Tab and Create a new Canvas Draw Area and Bind it
      ; -------------------------------------
      ;UnSelect All Gadget
      ForEach Images()
        \Selected = #False
      Next
      GroupSelectedGadget = #False
      
      ; The Gadgets are already Hidden
      ForEach Images()
        If \Gadget = EventGadget() And \Gadget <> \ParentGadget
          
          UnbindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
          ; FreeGadget(CurrentDrawArea)   ;NO? there is a memory issue with BindGadgetEvent, done later ! I don't know why
          DisableGadget(CurrentDrawArea,#True) 
          HideGadget(CurrentDrawArea,#True)
          
          ;Close the current Panel Gadget Tab List
          CloseGadgetList()         
          
          ;Open the Panel Gadget List on the new Tab
          Tab = GetGadgetState(\Gadget)
          OpenGadgetList(\Gadget,Tab)
          \CurrentTab = Tab
          
          ;Create a new Canvas Draw Area
          CurrentDrawArea = CanvasGadget(#PB_Any, 0, 0, MaxSizeX, MaxSizeY, #PB_Canvas_Container | #PB_Canvas_Keyboard)
          ParentDrawArea = CurrentDrawArea
          \DrawArea = CurrentDrawArea
          CreateHidenHandle()
          CloseGadgetList()   ;Close Canvas Gadget List
          
          ;Bind the New Current Draw Area and Make the Container Visible to get access to ScrollBar, Tabs
          BindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
          CurrentItemGadget = 0
          X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
          DrawCanvas(#True)
          Break
        EndIf
      Next
      
      ;Update all the Gadgets in the current tab with the new Current DrawArea
      ForEach Images()
        If \Level = Level And \ParentGadget = EventGadget() And \Gadget <> \ParentGadget
          If \Tab = Tab
            \ParentDrawArea = CurrentDrawArea
          Else
            \ParentDrawArea = 0
          EndIf
        EndIf
      Next
    EndWith
  EndProcedure
  
  Procedure OpenContainer(Gadget)
    With Images()
      ; -------------------------------------
      ; 1st Part: Make Hidden the Gadgets, from the Container that we Open to display them. They are Visible with the Container Hidden
      ;           Unbind and disabled previous (Parent) DrawArea  
      ; -------------------------------------
      ;Make Hidden the Gadgets, from the Container that we Open. UnSelect All Gadget
      ForEach Images()
        If \ParentGadget = Gadget And \Gadget <> \ParentGadget
          ;The image of a button is badly placed when visible and inside a container
          If GadgetType(\Gadget) = #PB_GadgetType_ButtonImage
            SetGadgetAttribute(\Gadget, #PB_Button_Image, ImageID(Geebee2Image))
          EndIf
          HideGadget(\Gadget,#True)
        EndIf
        \Selected = #False
      Next
      GroupSelectedGadget = #False
      HideGadget(Handle(0),#True)
      DrawCanvas(#False)   ;Draw Parent Area in White and without Grid
      
      ForEach Images()
        If \Gadget = Gadget And \Gadget <> \ParentGadget
          ;Unbind and disabled previous (Parent) DrawArea
          UnbindGadgetEvent(\ParentDrawArea,  @MoveDrawAreaEVENT())
          DisableGadget(\ParentDrawArea,#True)   ;HideGadget(\ParentDrawArea,#True)
          If GadgetType(\ParentGadget) = #PB_GadgetType_Panel
            UnbindGadgetEvent(\ParentGadget,  @ChangePanelTab(), #PB_EventType_Change)
            BindGadgetEvent(\ParentGadget,  @ChangeDisabledPanelTab(), #PB_EventType_Change)
          EndIf
          
          ; -------------------------------------
          ; 2nd Part : Calculate Max Size X and Y and Open the new Gadget List
          ;          : Create Canvas Draw Area or used the existing Canvas, previously created 
          ;          : Calculate the OffsetX(Y) of the Container being Opened
          ;          : Save Level and Parent information for future Gadgets Created + the CurrentDrawArea
          ;          : Bind the Canvas Draw Area and Make the Container Visible to get access to ScrollBar, Tabs
          ; -------------------------------------
          ;Debug "OpenContainer: Open Gadget: " + Str(\Gadget) + " Current Tab: " + Str(GetGadgetState(\Gadget))
          
          ;Calculate Max Size X and Y and Open the new Gadget List
          Select GadgetType(\Gadget)
            Case #PB_GadgetType_Panel
              MaxSizeX = GetGadgetAttribute(\Gadget,#PB_Panel_ItemWidth) : MaxSizeY = GetGadgetAttribute(\Gadget,#PB_Panel_ItemHeight)
              OpenGadgetList(\Gadget, GetGadgetState(\Gadget))
            Case #PB_GadgetType_ScrollArea
              MaxSizeX = GetGadgetAttribute(\Gadget, #PB_ScrollArea_InnerWidth) : MaxSizeY = GetGadgetAttribute(\Gadget, #PB_ScrollArea_InnerHeight)
              OpenGadgetList(\Gadget)
            Default   ;11 Container - 33 Canvas Container
              MaxSizeX = \Width : MaxSizeY = \Height
              OpenGadgetList(\Gadget)
          EndSelect
          
          ;Create Canvas Draw Area or used the existing Canvas, previously created
          If \DrawArea = 0
            CurrentDrawArea = CanvasGadget(#PB_Any, 0, 0, MaxSizeX, MaxSizeY, #PB_Canvas_Container | #PB_Canvas_Keyboard)
            \DrawArea = CurrentDrawArea
            CreateHidenHandle()
            CloseGadgetList()   ;Close Canvas Gadget List
          Else
            CurrentDrawArea = \DrawArea
            ResizeGadget(CurrentDrawArea, 0, 0, MaxSizeX, MaxSizeY)
            DisableGadget(CurrentDrawArea,#False)   
            HideGadget(CurrentDrawArea,#False)
            OpenGadgetList(CurrentDrawArea)
            CreateHidenHandle()
            CloseGadgetList()   ;Close Canvas Gadget List
          EndIf
          ;Bind the New Current Draw Area and Make the Container Visible to get access to ScrollBar, Tabs
          BindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
          HideGadget(\Gadget,#False)
          
          ;Calculate the OffsetX(Y) of the Container being Opened
          DrawAreaOffsetX + GadgetX(\Gadget) : DrawAreaOffsetY + GadgetY(\Gadget)
          Select GadgetType(\ParentGadget)
            Case #PB_GadgetType_Panel
              ;Windows 10 size: Panel_TabHeight=22, Panel_ItemWidth=Width-8 (Leftborder=3,Rightborder=5), Panel_ItemHeight=Height-Panel_TabHeight-5 (Topborder=1,Bottomborder=4)
              DrawAreaOffsetX + 3
              DrawAreaOffsetY + GetGadgetAttribute(\ParentGadget,#PB_Panel_TabHeight) + 1
            Case #PB_GadgetType_ScrollArea
              DrawAreaOffsetX - GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_X)
              DrawAreaOffsetY - GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_Y)
          EndSelect
          
          ;Save Level and Parent information for future Gadgets Created + CurrentDrawArea
          Level = \Level + 1
          ParentGadget = \Gadget
          ParentDrawArea = CurrentDrawArea
          If GadgetType(\Gadget) = #PB_GadgetType_Panel
            Level + 1
            Tab = GetGadgetState(\Gadget)
            UnbindGadgetEvent(\Gadget,  @ChangeDisabledPanelTab(), #PB_EventType_Change)
            BindGadgetEvent(\Gadget,  @ChangePanelTab(), #PB_EventType_Change)
          Else
            Tab = #PB_Ignore
          EndIf
          
          CurrentItemGadget = 0
          X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
          DrawCanvas(#True)
          Break
        EndIf
      Next
    EndWith
  EndProcedure
  
  Procedure CloseContainer()
    Protected SavParentGadget = ParentGadget
    With Images()  
      ; -------------------------------------
      ; 1st Part: Make Visible the Gadgets, from the Container that we Close, to display them and 
      ;           Close the Container Gadget List, Unbind and disable and hide the Canvas Container we Close 
      ; -------------------------------------
      ;Make Visible the Gadgets, from the Container that we Close. UnSelect All Gadget
      ForEach Images()
        If \ParentGadget = ParentGadget And \Gadget <> \ParentGadget
          ;The Image of a Button Image is Badly Placed when Visible and Inside a Container that we close (disable). Workaround: Remove Button Image
          If GadgetType(\Gadget) = #PB_GadgetType_ButtonImage
            SetGadgetAttribute(\Gadget, #PB_Button_Image, 0)
          EndIf
          HideGadget(\Gadget,#False)
        EndIf
        \Selected = #False
      Next
      GroupSelectedGadget = #False
      DrawCanvas(#False)   ;Draw Container in White and without Grid
      
      ForEach Images()
        If \Gadget = ParentGadget And \Gadget <> \ParentGadget
          
          UnbindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
          DisableGadget(CurrentDrawArea,#True)
          HideGadget(CurrentDrawArea,#True)
          
          If GadgetType(\Gadget) = #PB_GadgetType_Panel
            UnbindGadgetEvent(\Gadget,  @ChangePanelTab(), #PB_EventType_Change)
            BindGadgetEvent(\Gadget,  @ChangeDisabledPanelTab(), #PB_EventType_Change)
          EndIf
          
          HideGadget(\Gadget,#True)
          CloseGadgetList()   ;Close Container Gadget List
          
          ; -------------------------------------
          ; 2nd Part : Calculate the Offset in the opposite direction of the Container that we Close to obtain the Offset of the parent that we are going to Open
          ;          : Restore Level and Parent information for future Gadgets Created + CurrentDrawArea 
          ;          : Open Parent Gadget List and save New MaxSize X, Y
          ;          : Bind the New Current Draw Area (previous Parent) And Make the Container Visible For ScrollBar, Tabs
          ;          : Give Focus to the Container that has just been closed (MoveElement #PB_List_Last) and Re Capture its image
          ; -------------------------------------
          ;Calculate the Offset in the opposite direction of the Container that we Close to obtain the Offset of the parent that we are going to Open.
          DrawAreaOffsetX - GadgetX(\Gadget) : DrawAreaOffsetY - GadgetY(\Gadget)
          Select GadgetType(\ParentGadget)
            Case #PB_GadgetType_Panel
              ;Windows 10 size: Panel_TabHeight=22, Panel_ItemWidth=Width-8 (Leftborder=3,Rightborder=5), Panel_ItemHeight=Height-Panel_TabHeight-5 (Topborder=1,Bottomborder=4)
              DrawAreaOffsetX - 3
              DrawAreaOffsetY - GetGadgetAttribute(\ParentGadget,#PB_Panel_TabHeight) - 1
            Case #PB_GadgetType_ScrollArea
              DrawAreaOffsetX + GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_X)
              DrawAreaOffsetY + GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_Y)
          EndSelect
          
          ;Restore Level and Parent information for future Gadgets Created + CurrentDrawArea
          Level = \Level
          ParentGadget = \ParentGadget
          CurrentDrawArea = \ParentDrawArea
          ParentDrawArea = \ParentDrawArea
          ;Tab = \Tab
          If GadgetType(ParentGadget) = #PB_GadgetType_Panel
            Tab = GetGadgetState(ParentGadget)
            UnbindGadgetEvent(ParentGadget,  @ChangeDisabledPanelTab(), #PB_EventType_Change)
            BindGadgetEvent(ParentGadget,  @ChangePanelTab(), #PB_EventType_Change)
          Else
            Tab = #PB_Ignore
          EndIf
          
          ;Open Parent Gadget List and save New MaxSize X, Y
          ;Debug "CloseContainer: Open Parent Gadget: " + Str(\ParentGadget) + " Current Tab: " + Str(GetGadgetState(\ParentGadget))
          If ParentGadget = 0
            MaxSizeX = UserScreen_Width : MaxSizeY = UserScreen_Height
          Else
            Select GadgetType(\ParentGadget)
              Case #PB_GadgetType_ScrollArea
                MaxSizeX = GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_InnerWidth) : MaxSizeY = GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_InnerHeight)
              Case #PB_GadgetType_Panel
                MaxSizeX = GetGadgetAttribute(\ParentGadget,#PB_Panel_ItemWidth) : MaxSizeY = GetGadgetAttribute(\ParentGadget,#PB_Panel_ItemHeight)
              Default   ;11 Container - 33 Canvas Container
                MaxSizeX = GadgetWidth(\ParentGadget) : MaxSizeY = GadgetHeight(\ParentGadget)
            EndSelect
          EndIf
          
          ;Bind the New Current Draw Area (previous Parent) And Make the Container Visible For ScrollBar, Tabs
          OpenGadgetList(CurrentDrawArea)
          CreateHidenHandle()
          CloseGadgetList()   ;Close Canvas Gadget List
          BindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
          DisableGadget(CurrentDrawArea,#False)   ;HideGadget(CurrentDrawArea,#False)
          
          ;Give Focus to the Container that has just been closed (MoveElement #PB_List_Last) and Re Capture its image 
          CurrentItemGadget = SavParentGadget
          \Selected = #True
          If \Group > 0
            SelectedGroup(\Group, \Selected)
          EndIf
          MoveElement(Images(), #PB_List_Last)
          FreeImage(\Capture)
          \Capture = CaptureGadget(\Gadget)
          GroupSelectedGadget = GroupGadgetEnabled()
          SetActiveGadget(CurrentDrawArea)
          If CurrentDrawArea = 10
            HideGadget(Handle(0),#False)
          EndIf
          X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
          DrawCanvas(#True)
          HideHandle(#False)
          Break
        EndIf
      Next
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------------
  Procedure Init()
    Protected DrawAreaMaxX.i = 1920, DrawAreaMaxY.i = 1020
    CatchImage(#ThisPC,?ThisPC)
    ;InnerWidth and InnerHeight +10 To keep access to the Win Handle
    ScrollAreaGadget(#ScrollDrawArea, 10, 22, 780, 570, DrawAreaMaxX+10, DrawAreaMaxY+10, 20, #PB_ScrollArea_Single)
    ;Init Global variables
    Level = 0
    CurrentItemGadget = 0
    ParentGadget = 0
    CurrentDrawArea = 10
    ParentDrawArea = 10
    Tab = #PB_Ignore
    
    CanvasGadget(CurrentDrawArea, 0, 0, DrawAreaMaxX, DrawAreaMaxY, #PB_Canvas_Container | #PB_Canvas_Keyboard)
    MaxSizeX.i = UserScreen_Width : MaxSizeY.i = UserScreen_Height
    AddImage(0, 0, 0, 0)
    CreateWinHandle()
    CreateHidenHandle()
    CloseGadgetList()
    DrawAreaOffsetX = GadgetX(#ScrollDrawArea) : DrawAreaOffsetY = GadgetY(#ScrollDrawArea)
    BindGadgetEvent(CurrentDrawArea,  @MoveDrawAreaEVENT())
    DrawCanvas(#True)
    
    DataSection   ; Include Images
      IncludePath "Images"
      ThisPC:           : IncludeBinary "ThisPC.png"
    EndDataSection
  EndProcedure
EndModule

Procedure Exit()
  End
EndProcedure

Enumeration 200
  #ShowGrid
  #GridSize
  #SnapGrid
  ;
  #Group_Button
  #UnGroup_Button
  #Align_Left_Button
  #Align_Right_Button
  #Align_Top_Button
  #Align_Bottom_Button
  #Make_Same_Width_Button
  #Make_Same_Height_Button
  #Img_Group
  #Img_UnGroup
  #Align_Left
  #Align_Right
  #Align_Top
  #Align_Bottom
  #Make_Same_Width
  #Make_Same_Height
  #HandelOnMove
  ;Properties
  #PanelControls
  #ListControls
  #CreateControlsList
EndEnumeration

UseModule IceDesign

;- Main
If OpenWindow(0, 0, 0, 800, 600, "IceDesign", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ComboBoxGadget(#ComboGadget,10,1,120,20)
  ;AddGadgetItem(#ComboGadget, -1, "Window")
  AddGadgetItem(#ComboGadget, -1, "Button")
  AddGadgetItem(#ComboGadget, -1, "ButtonImage")
  AddGadgetItem(#ComboGadget, -1, "Calendar")
  AddGadgetItem(#ComboGadget, -1, "Canvas")
  AddGadgetItem(#ComboGadget, -1, "CheckBox")
  AddGadgetItem(#ComboGadget, -1, "ComboBox")
  AddGadgetItem(#ComboGadget, -1, "Container")
  AddGadgetItem(#ComboGadget, -1, "Date")
  AddGadgetItem(#ComboGadget, -1, "Editor")
  AddGadgetItem(#ComboGadget, -1, "ExplorerCombo")
  AddGadgetItem(#ComboGadget, -1, "ExplorerList")
  AddGadgetItem(#ComboGadget, -1, "ExplorerTree")
  AddGadgetItem(#ComboGadget, -1, "Frame")
  AddGadgetItem(#ComboGadget, -1, "HyperLink")
  AddGadgetItem(#ComboGadget, -1, "Image")
  AddGadgetItem(#ComboGadget, -1, "IPAddress")
  AddGadgetItem(#ComboGadget, -1, "ListIcon")
  AddGadgetItem(#ComboGadget, -1, "ListView")
  AddGadgetItem(#ComboGadget, -1, "Option")
  AddGadgetItem(#ComboGadget, -1, "Panel")
  AddGadgetItem(#ComboGadget, -1, "ProgressBar")
  AddGadgetItem(#ComboGadget, -1, "Scintilla")
  AddGadgetItem(#ComboGadget, -1, "ScrollArea")
  AddGadgetItem(#ComboGadget, -1, "ScrollBar")
  AddGadgetItem(#ComboGadget, -1, "Spin")
  AddGadgetItem(#ComboGadget, -1, "String")
  ;AddGadgetItem(#ComboGadget, -1, "StringMulti")
  AddGadgetItem(#ComboGadget, -1, "Text")
  AddGadgetItem(#ComboGadget, -1, "TrackBar")
  AddGadgetItem(#ComboGadget, -1, "Tree")
  AddGadgetItem(#ComboGadget, -1, "Web")
  ; AddGadgetItem(#ComboGadget, -1, "CanvasContainer")
  ; AddGadgetItem(#ComboGadget, -1, "OpenGL")
  ; AddGadgetItem(#ComboGadget, -1, "Splitter")
  ; CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  ;   AddGadgetItem(#ComboGadget, -1, "MDI")
  ; CompilerEndIf
  ; AddGadgetItem(#ComboGadget, -1, "Shortcut")
  SetGadgetState(#ComboGadget, 0)
  SendMessage_(GadgetID(#ComboGadget), #CB_SETMINVISIBLE, 40, 0)
  
  CheckBoxGadget(#ShowGrid, 160, 1, 45, 20, "Grid") : SetGadgetState(#ShowGrid, ShowGrid)
  SpinGadget(#GridSize, 205, 1, 40, 20, 5, 50, #PB_Spin_Numeric) : SetGadgetState(#GridSize,GridSize)
  CheckBoxGadget(#SnapGrid, 255, 1, 95, 20, "Snap to grid") : SetGadgetState(#SnapGrid,SnapGrid)
  
  CatchImage(#Img_Group,?Img_Group)
  ButtonImageGadget(#Group_Button, 355, 0, 22, 22,ImageID(#Img_Group))
  GadgetToolTip(#Group_Button, "Group the Selected Gadgets")   ; (Ctrl+G)")
  
  CatchImage(#Img_UnGroup,?Img_UnGroup)
  ButtonImageGadget(#UnGroup_Button, 382, 0, 22, 22,ImageID(#Img_UnGroup))
  GadgetToolTip(#UnGroup_Button, "Ungroup All Gadgets Grouped with the Active Gadget")   ; (Ctrl+Shift+G)")
  
  CatchImage(#Align_Left,?Align_Left)
  ButtonImageGadget(#Align_Left_Button, 424, 0, 22, 22,ImageID(#Align_Left))
  GadgetToolTip(#Align_Left_Button, "Align Left")   ; (Ctrl+Left)")
  
  CatchImage(#Align_Right,?Align_Right)
  ButtonImageGadget(#Align_Right_Button, 451, 0, 22, 22,ImageID(#Align_Right))
  GadgetToolTip(#Align_Right_Button, "Align Right")   ; (Ctrl+Right)")
  
  CatchImage(#Align_Top,?Align_Top)
  ButtonImageGadget(#Align_Top_Button, 493, 0, 22, 22,ImageID(#Align_Top))
  GadgetToolTip(#Align_Top_Button, "Align Top")   ; (Ctrl+Top)")
  
  CatchImage(#Align_Bottom,?Align_Bottom)
  ButtonImageGadget(#Align_Bottom_Button, 520, 0, 22, 22,ImageID(#Align_Bottom))
  GadgetToolTip(#Align_Bottom_Button, "Align Bottom")   ; (Ctrl+Bottom)")
  
  CatchImage(#Make_Same_Width,?Make_Same_Width)
  ButtonImageGadget(#Make_Same_Width_Button, 562, 0, 22, 22,ImageID(#Make_Same_Width))
  GadgetToolTip(#Make_Same_Width_Button, "Make Same Width")   ; (Ctrl+W)")
  
  CatchImage(#Make_Same_Height,?Make_Same_Height)
  ButtonImageGadget(#Make_Same_Height_Button, 589, 0, 22, 22,ImageID(#Make_Same_Height))
  GadgetToolTip(#Make_Same_Height_Button, "Make Same Height")   ; (Ctrl+H)")
  
  CheckBoxGadget(#HandelOnMove, 640, 1, 105, 20, "Handle On Move") : SetGadgetState(#HandelOnMove,HandelOnMove)
  
  
  Init()
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Exit()
        
      Case #PB_Event_Menu   ;-> Event Menu
        Select EventMenu()
          Case #Shortcut_Delete
            DeleteGadget(CurrentItemGadget)
            
        EndSelect
        
      Case #PB_Event_Gadget   ;-> Event Gadget
        Select EventGadget()
            
          Case #ShowGrid
            ShowGrid = GetGadgetState(#ShowGrid)
            X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
            SetCurrentGadget(CurrentItemGadget)
            
          Case #GridSize
            GridSize = GetGadgetState(#GridSize)
            If GetGadgetState(#SnapGrid) = #True
              DragSpace = GetGadgetState(#GridSize)
            Else
              DragSpace = 1
            EndIf
            X = #PB_Ignore : Y = #PB_Ignore : PosDim\X0 = #PB_Ignore : PosDim\Y0 = #PB_Ignore : PosDim\Width0 = #PB_Ignore : PosDim\Height0 = #PB_Ignore
            SetCurrentGadget(CurrentItemGadget)
            
          Case #SnapGrid
            SnapGrid = GetGadgetState(#SnapGrid)
            If SnapGrid = #True
              DragSpace = GetGadgetState(#GridSize)
            Else
              DragSpace = 1
            EndIf
            SetCurrentGadget(CurrentItemGadget)
            
          Case #Group_Button
            If GroupSelectedGadget = #True
              Group_Selected()
            EndIf
            
          Case #UnGroup_Button
            If GroupSelectedGadget = #True
              UnGroup_Selected(CurrentItemGadget)
            EndIf
            
          Case #Align_Left_Button
            If GroupSelectedGadget = #True
              Align_Left(CurrentItemGadget)
            EndIf
            
          Case #Align_Right_Button
            If GroupSelectedGadget = #True
              Align_Right(CurrentItemGadget)
            EndIf
            
          Case #Align_Top_Button
            If GroupSelectedGadget = #True
              Align_Top(CurrentItemGadget)
            EndIf
            
          Case #Align_Bottom_Button
            If GroupSelectedGadget = #True
              Align_Bottom(CurrentItemGadget)
            EndIf
            
          Case #Make_Same_Width_Button
            If GroupSelectedGadget = #True
              Make_Same_Width(CurrentItemGadget)
            EndIf
            
          Case #Make_Same_Height_Button
            If GroupSelectedGadget = #True
              Make_Same_Height(CurrentItemGadget)
            EndIf
            
          Case #HandelOnMove
            HandelOnMove = GetGadgetState(#HandelOnMove)
            SetCurrentGadget(CurrentItemGadget)
            
        EndSelect
    EndSelect
  ForEver
EndIf

DataSection   ; Include Images
  IncludePath "Images"
  Img_Group:        : IncludeBinary "Group.png"
  Img_UnGroup:      : IncludeBinary "UnGroup.png"
  Align_Left:       : IncludeBinary "Align_Left.png"
  Align_Right:      : IncludeBinary "Align_Right.png"
  Align_Top:        : IncludeBinary "Align_Top.png"
  Align_Bottom:     : IncludeBinary "Align_Bottom.png"
  Make_Same_Width:  : IncludeBinary "Make_Same_Width.png"
  Make_Same_Height: : IncludeBinary "Make_Same_Height.png"
  ThisPC:           : IncludeBinary "ThisPC.png"
EndDataSection
; IDE Options = PureBasic 5.72 (Windows - x64)
; Folding = --------
; EnableXP
; UseIcon = Images\IceDesign.ico
; Executable = IceDesign_beta3.exe
; Compiler = PureBasic 5.72 (Windows - x64)