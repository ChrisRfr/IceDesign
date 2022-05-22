;- Top
; -------------------------------------------------------------------------------------------------
;        Name: PBForm2IceDesign.pbi
; Description: Export an interface from a Purebasic source (*.pbf, *.pb) and convert it to IceDesign format (*.icef)
;              This is done at RunTime (see how to use below) by enumerating all PB Window and Object and building the Container-Child hierarchy.
;              The Attributes, Constants,... are then retrieved (See Inventories below) 
;              And the List is then saved, window by window, to IceDesign format (*.icef)
;              You can now design your interface in IceDesign :)
;      Author: ChrisR
;        Date: 2022-05-16
;  PB-Version: 5.73 x64/x86
;          OS: Windows only
;       Forum: IceDesign topic: https://www.purebasic.fr/english/viewtopic.php?t=74711
;
; -------------------------------------------------------------------------------------------------
;
; Inventories:
;   The Window(s) are recovered with their Sizes, Titles, BackColor, Constants and a Flag if there is a Menu.
;   The Gadget(s) are recovered with their Positions and Sizes.
;   The following attributes are retrieved:
;      The Text of Buttons, CheckBox,... Minimum, Maximum, InnerWidth, InnerHeight, ColumnWidth, ScrollStep And PageLength
;      Status Disabled, Hidden
;      FrontColor, BackColor and ToolTip
;      And a large part of the Constants. See the List below.
; 
;   ToolBar, StatusBar, Fonts and Images are Not recovered.
;
;   The Splitter is listed to browse the hierarchy. 
;      As it is not supported by IceDesign, it is then removed and both child gadgets inherit the splitter's level and parent.
;
; -------------------------------------------------------------------------------------------------
;
; How to use:
;   Include PBForm2IceDesign.pbi at the Beginning of Your Source Code:
;      XIncludeFile "PBForm2IceDesign.pbi"
;
;   After loading the Window(s) With Their Gadgets and Before the Event Loop, Call the Function:
;      PBForm2IceDesign() Or PBForm2IceDesign(#Window)
;
;   Optional, Customize your IceDesign Form with the Following Constants:
;      #UseShortNames      = #True     ; #True: Use Short Name for Controls (ex: #Btn) | #False: Use Long Name for Controls (ex: #Button)
;      #RenameControlNames = #True     ; Auto Rename the Controls Name Using the Caption Name. For Button, CheckBox and Option (ex: #Btn_CaptionName)
;      #SetHiddenFlag      = #False    ; #False: No Gadgets are hidden   | #True: it uses the same status (0/1) as in your Window
;      #SetDisabledFlag    = #False    ; #False: No Gadgets are Disabled | #True: it uses the same status (0/1) as in your Window
;
;   Compile/Run (F5)
;
; Source Example:
;   | EnableExplicit
;   | 
;   | XIncludeFile "PBForm2IceDesign.pbi"   ; <== Include PBForm2IceDesign.pbi source code
;   |  
;   | Enumeration Window
;   |   #Window_0
;   | EndEnumeration
;   | 
;   | Enumeration Gadgets
;   |   #Button_1
;   | EndEnumeration
;   | 
;   | Procedure Open_Window_0(X = 0, Y = 0, Width = 240, Height = 90)
;   |   If OpenWindow(#Window_0, X, Y, Width, Height, "Title", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
;   |     ButtonGadget(#Button_1, 20, 20, 200, 50, "Button_1")
;   |   EndIf
;   | EndProcedure
;   | 
;   | Open_Window_0()
;   | PBForm2IceDesign()     ; <== Call the function PBForm2IceDesign() After Loading the Window(s) and Gadget(s) and Before the Event Loop
;   | 
;   | Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow                                                               
;
; -------------------------------------------------------------------------------------------------
;
; List of Constants recovered or not (requires additional tests):   
;    | #PB_Window_SystemMenu               | OK     |
;    | #PB_Window_MinimizeGadget           | OK     |
;    | #PB_Window_MaximizeGadget           | OK     |
;    | #PB_Window_ScreenCentered           | ~OK    | If Compiled With the DPIaware Option
;    | #PB_Window_SizeGadget               | OK     |
;    | #PB_Window_Invisible                | OK     |
;    | #PB_Window_TitleBar                 | OK     |
;    | #PB_Window_BorderLess               | OK     |
;    | #PB_Window_Maximize                 | OK     |
;    | #PB_Window_Minimize                 | OK     |
;    | #PB_Window_WindowCentered           | ~OK    | If Compiled With the DPIaware Option
;    | #PB_Window_Tool                     | OK     |
;    | #PB_Window_NoActivate               | OK     |
;    | #PB_Button_Right                    | OK     |
;    | #PB_Button_Left                     | OK     |
;    | #PB_Button_Default                  | OK     |
;    | #PB_Button_MultiLine                | OK     |
;    | #PB_Button_Toggle                   | OK     |
;    | #PB_#BS_Bottom                      | OK     |
;    | #PB_#BS_Flat                        | OK     |
;    | #PB_#BS_Top                         | OK     |
;    | #PB_Button_Toggle                   | OK     |
;    | #PB_Calendar_Borderless             | OK     |
;    | #PB_Canvas_Container                | OK     |
;    | #PB_Canvas_Border                   | OK     |
;    | #PB_Canvas_ClipMouse                | Not OK |
;    | #PB_Canvas_Keyboard                 | OK     |
;    | #PB_Canvas_DrawFocus                | Not OK |
;    | #PB_CheckBox_Center                 | OK     |
;    | #PB_CheckBox_Right                  | OK     |
;    | #PB_CheckBox_ThreeState             | OK     |
;    | #PB_#BS_Bottom                      | OK     |
;    | #PB_#BS_LeftText                    | OK     |
;    | #PB_#BS_MultiLine                   | OK     |
;    | #PB_#BS_Top                         | OK     |
;    | #PB_ComboBox_LowerCase              | OK     |
;    | #PB_ComboBox_UpperCase              | OK     |
;    | #PB_ComboBox_Editable               | OK     |
;    | #PB_ComboBox_Editable               | OK     |
;    | #PB_ComboBox_Image                  | OK     |
;    | #PB_ComboBox_Image                  | OK     |
;    | #PB_Container_Flat                  | OK     |
;    | #PB_Container_Raised                | OK     |
;    | #PB_Container_Single                | OK     |
;    | #PB_Container_Double                | OK     |
;    | ;#PB_Container_BorderLess           | Default|
;    | #PB_Date_UpDown                     | OK     |
;    | #PB_Date_CheckBox                   | OK     |
;    | #PB_Editor_ReadOnly                 | OK     |
;    | #PB_Editor_WordWrap                 | Not OK |
;    | #PB_#ES_Center                      | OK     |
;    | #PB_#ES_NoHideSel                   | Not OK |
;    | #PB_#ES_Right                       | OK     |
;    | #PB_Explorer_Editable               | OK     |
;    | #PB_Explorer_DrivesOnly             | Not OK |
;    | #PB_Explorer_NoMyDocuments          | Not OK |
;    | #PB_Explorer_BorderLess             | OK     |
;    | #PB_Explorer_AlwaysShowSelection    | OK     |
;    | #PB_Explorer_MultiSelect            | OK     |
;    | #PB_Explorer_NoFolders              | OK     |
;    | #PB_Explorer_NoSort                 | OK     |
;    | #PB_Explorer_GridLines              | Not OK |
;    | #PB_Explorer_HeaderDragDrop         | Not OK |
;    | #PB_Explorer_FullRowSelect          | Not OK |
;    | #PB_Explorer_NoFiles                | Not OK |
;    | #PB_Explorer_NoParentFolder         | Not OK |
;    | #PB_Explorer_NoDirectoryChange      | Not OK |
;    | #PB_Explorer_NoDriveRequester       | Not OK |
;    | #PB_Explorer_NoMyDocuments          | Not OK |
;    | #PB_Explorer_AutoSort               | Not OK |
;    | #PB_Explorer_HiddenFiles            | Not OK |
;    | #PB_Explorer_BorderLess             | OK     |
;    | #PB_Explorer_AlwaysShowSelection    | OK     |
;    | #PB_Explorer_NoLines                | OK     |
;    | #PB_Explorer_NoButtons              | OK     |
;    | #PB_Explorer_NoFiles                | Not OK |
;    | #PB_Explorer_NoDriveRequester       | Not OK |
;    | #PB_Explorer_NoMyDocuments          | Not OK |
;    | #PB_Explorer_AutoSort               | Not OK |
;    | #PB_Frame_Flat                      | OK     |
;    | #PB_Frame_Single                    | OK     |
;    | #PB_Frame_Double                    | OK     |
;    |  #PB_HyperLink_Underline            | Not OK |
;    | #PB_Image_Border                    | OK     |
;    | #PB_Image_Raised                    | OK     |
;    | #PB_ListIcon_MultiSelect            | OK     |
;    | #PB_ListIcon_AlwaysShowSelection    | OK     |
;    | #PB_#LVS_NoColumnHeader             | OK     |
;    | #PB_#LVS_NoScroll                   | OK     |
;    | #PB_ListIcon_CheckBoxes             | Not OK |
;    | #PB_ListIcon_ThreeState             | Not OK |
;    | #PB_ListIcon_GridLines              | Not OK |
;    | #PB_ListIcon_FullRowSelect          | Not OK |
;    | #PB_ListIcon_HeaderDragDrop         | Not OK |
;    | #PB_ListView_ClickSelect            | OK     |
;    | #PB_ListView_MultiSelect            | OK     |
;    | #PB_#LBS_MultiColumn                | OK     |
;    | #PB_OpenGL_Keyboard                 | Not OK |
;    | #PB_OpenGL_NoFlipSynchronization    | Not OK |
;    | #PB_OpenGL_FlipSynchronization      | Not OK |
;    | #PB_OpenGL_NoDepthBuffer            | Not OK |
;    | #PB_OpenGL_16BitDepthBuffer         | Not OK |
;    | #PB_OpenGL_24BitDepthBuffer         | Not OK |
;    | #PB_OpenGL_NoStencilBuffer          | Not OK |
;    | #PB_OpenGL_8BitStencilBuffer        | Not OK |
;    | #PB_OpenGL_NoAccumulationBuffer     | Not OK |
;    | #PB_OpenGL_32BitAccumulationBuffer  | Not OK |
;    | #PB_OpenGL_64BitAccumulationBuffer  | Not OK |
;    | #PB__#BS_Bottom                     | OK     |
;    | #PB__#BS_LeftText                   | OK     |
;    | #PB__#BS_MultiLine                  | OK     |
;    | #PB__#BS_PushLike                   | OK     |
;    | #PB__#BS_Top                        | OK     |
;    | #PB_ProgressBar_Smooth              | OK     |
;    | #PB_ProgressBar_Vertical            | OK     |
;    | #PB_ScrollArea_Raised               | OK     |
;    | #PB_ScrollArea_Flat                 | OK     |
;    | #PB_ScrollArea_Single               | OK     |
;    | #PB_ScrollArea_BorderLess           | OK     |
;    | #PB_ScrollArea_Center               | Not OK |
;    | #PB_ScrollBar_Vertical              | OK     |
;    | #PB_Spin_ReadOnly                   | OK     |
;    | #PB_Spin_Numeric                    | Not OK |
;    | #PB__#ES_Number                     | OK     |
;    | #PB_Splitter_Vertical               | Not OK |
;    | #PB_Splitter_Separator              | Not OK |
;    | #PB_Splitter_FirstFixed             | Not OK |
;    | #PB_Splitter_SecondFixed            | Not OK |
;    | #PB_String_Password                 | OK     |
;    | #PB_String_ReadOnly                 | OK     |
;    | #PB_String_Numeric                  | OK     |
;    | #PB_String_LowerCase                | OK     |
;    | #PB_String_UpperCase                | OK     |
;    | #PB_#ES_Center                      | OK     |
;    | #PB_#ES_MultiLine                   | OK     |
;    | #PB_#ES_NoHideSel                   | OK     |
;    | #PB_#ES_Right                       | OK     |
;    | #PB_String_BorderLess               | OK     |
;    | #PB_Text_Center                     | OK     |
;    | #PB_Text_Right                      | OK     |
;    | #PB_Text_Border                     | OK     |
;    | #PB_#SS_EndEllipsis                 | OK     |
;    | #PB_#SS_PathEllipsis                | OK     |
;    | #PB_#SS_WordEllipsis                | OK     |
;    | #PB_TrackBar_Ticks                  | OK     |
;    | #PB_TrackBar_Vertical               | OK     |
;    | #PB_Tree_AlwaysShowSelection        | OK     |
;    | #PB_Tree_NoLines                    | OK     |
;    | #PB_Tree_NoButtons                  | OK     |
;    | #PB_Tree_CheckBoxes                 | OK     |
;    | #PB_Tree_ThreeState                 | Not OK |
;
; -------------------------------------------------------------------------------------------------

;EnableExplicit                 ; Not required

;- Custom Constants
#UseShortNames      = #True     ; #True: Use Short Name for Controls (ex: #Btn) | #False: Use Long Name for Controls (ex: #Button)
#RenameControlNames = #True     ; Auto Rename the Controls Name Using the Caption Name. For Button, CheckBox and Option (ex: #Btn_CaptionName)
#SetHiddenFlag      = #False    ; #False: No Gadgets are hidden   | #True: it uses the same status (0/1) as in your Window
#SetDisabledFlag    = #False    ; #False: No Gadgets are Disabled | #True: it uses the same status (0/1) as in your Window

#DebugON            = #False    ; #False\#True

;XIncludeFile "Save_JSON.pbi"    ; Little John's module, Save JSON data with object members well-arranged: https://www.purebasic.fr/english/viewtopic.php?t=69100

Structure ModelObjectStruct     ; Structure Model Gadget from Data Section. Loaded in a Map for easy access to models, Key = Str(GadgetType)
  Model.s
  Name.s
  ShortName.s
  Caption.s
  Option1.s
  Option2.s
  Option3.s
  FontText.s
  FrontColor.s
  BackColor.s
  ToolTip.s
  BindGadget.s
  Constants.s
  CountGadget.i
EndStructure

Structure ObjectPBStruct        ; Structure to build the hierarchical list of objects. Starting from PB_Object_Enumerate
  Level.i                       ; If Level = 1, Parent is a Window else a Gadget
  Object.i
  ObjectID.i
  Type.i
  IsContainer.b
  ParentObject.i
  ParentObjectID.i
  GParentObjectID.i             ; Temporary Loaded for ScrollArea and Panel, it is then reset to 0 for the ScrollArea and replaced by the tab number for Panel and GetGadgetItemText()
  X.i
  Y.i
  Width.i
  Height.i
EndStructure

Structure LoadPBStruct          ; Structure for Loading and Saving Gadgets
  Level.i        
  Gadget.i                      ; Gadget 2 Hard Coded for the Window       
  Model.s
  Type.i         
  Name.s         
  Container.b
  ParentGadget.i 
  TabIndex.i     
  X.i            
  Y.i            
  Width.i        
  Height.i
  Group.i
  Caption.s      
  Option1.s   
  Option2.s   
  Option3.s
  FontText.s
  FrontColor.s
  BackColor.s
  Lock.b
  Disable.b   
  Hide.b
  ToolTip.s
  BindGadget.s
  LockLeft.b
  LockRight.b
  LockTop.b
  LockBottom.b
  ProportionalSize.b
  Constants.s
  Key.s
EndStructure

CompilerIf Not(Defined(PB_Globals, #PB_Structure))
  Structure PB_Globals
    CurrentWindow.i
    FirstOptionGadget.i
    DefaultFont.i
    *PanelStack
    PanelStackIndex.l
    PanelStackSize.l
    ToolTipWindow.i
  EndStructure
CompilerEndIf

Global NewMap ModelObject.ModelObjectStruct()
Global NewList ObjectPB.ObjectPBStruct()
Global NewList LoadPB.LoadPBStruct()
Global Dim Window(1, 0)
Global CountWindow, IndexTab

Import ""
  CompilerIf Not(Defined(PB_Object_GetThreadMemory, #PB_Procedure)) : PB_Object_GetThreadMemory(*Mem)                             : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_Count,           #PB_Procedure)) : PB_Object_Count(PB_Gadget_Objects)                          : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateAll,    #PB_Procedure)) : PB_Object_EnumerateAll(Object, *Object, ObjectData)         : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateStart,  #PB_Procedure)) : PB_Object_EnumerateStart(PB_Gadget_Objects)                 : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateNext,   #PB_Procedure)) : PB_Object_EnumerateNext(PB_Gadget_Objects, *Object.Integer) : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateAbort,  #PB_Procedure)) : PB_Object_EnumerateAbort(PB_Gadget_Objects)                 : CompilerEndIf
  CompilerIf Not(Defined(PB_Gadget_Globals, #PB_Variable))          : PB_Gadget_Globals.i                                         : CompilerEndIf
  CompilerIf Not(Defined(PB_Gadget_Objects, #PB_Variable))          : PB_Gadget_Objects.i                                         : CompilerEndIf
  CompilerIf Not(Defined(PB_Window_Objects, #PB_Variable))          : PB_Window_Objects.i                                         : CompilerEndIf
EndImport

Declare   LoadModelObject()
Declare   IsPBContainer(Gadget)
Declare   WindowPBCallBack(Window, *Window, WindowData)
Declare   TabObjectPB(Object)
Declare   ObjectPBCallBack(Object, *Object, ObjectData)
Declare   WinPBHierarchy(ParentObjectID, ParentObject, FirstPassDone = #False)
Declare   LoadObjectPB()
Declare   GetObjectPBFromID(ObjectID)
Declare   GetParentPB(Gadget)
Declare   GetWindowPBRoot(Gadget)
Declare   GetParentPBID(Gadget)
Declare   ParentPBisWindow(Gadget)
Declare   ParentPBisGadget(Gadget)
Declare   CountChildPBGadget(ParentObject, GrandChildren = #False, FirstPassDone = #False)
Declare   EnumWinChildPB(ParentObject, FirstPassDone = #False)
Declare   EnumChildPB(Window = #PB_All)
Declare.s AddWindowPBFlag(Window, Constants.s)
Declare   AddWindowPB(Window)
Declare.s GetToolTipText(Gadget)
Declare.s CheckPBName(Name.s)
Declare.s UniquePBName(BaseName.s, Caption.s)
Declare.s AddGadgetPBFlag(Gadget, Constants.s)
Declare   AddGadgetPB(Gadget)
Declare   AddWinLoadPB(ParentObject, FirstPassDone = #False)
Declare   SaveIceDesignForm(Window)
Declare   AddLoadPB(Window = #PB_All)
Declare   PBForm2IceDesign(Window = #PB_All)

;- ----- Macro -----
Macro _ObjectPB_(pObject, Object, ReturnValue = #False)
  
  PushListPosition(ObjectPB())
  Repeat
    ForEach ObjectPB()
      If ObjectPB()\Object = Object
        pObject = @ObjectPB()
        PopListPosition(ObjectPB())
        Break 2
      EndIf
    Next
    Debug " LoadFromPB Error: Object number Not Found: "  + Str(Object)
    PopListPosition(ObjectPB())
    ProcedureReturn ReturnValue
  Until #True
  
EndMacro

Macro _IsFlag_(StyleFlag, IsFlag)
  Bool((StyleFlag & IsFlag) = IsFlag)
EndMacro

Macro _IsExFlag_(ExStyleFlag, IsFlag)
  Bool((ExStyleFlag & IsFlag) = IsFlag)
EndMacro

Macro _HexColor_(Color)
  "$" + RSet(Hex(Blue(Color)), 2, "0") + RSet(Hex(Green(Color)), 2, "0") + RSet(Hex(Red(Color)), 2, "0")
EndMacro

Macro _ProcedureReturnIf_(Cond, ReturnVal = 0)
  If Cond
    ProcedureReturn ReturnVal
  EndIf
EndMacro

;- ----- Private Model -----

Procedure LoadModelObject()   ;Initializing Gadget Templates
  Protected Buffer.s, CountItem.i, I.i, J.i 
  
  With ModelObject()
    Restore ModelObjectData
    For I = 0 To 999   ; Loop break if Model = "---END---"
      For J=1 To 14
        Read.s Buffer
        Select J
          Case 1
            If Buffer = "99"
              Break 2
            EndIf
            AddMapElement(ModelObject(), Buffer)  ; \Type
          Case 2  : \Model       = Buffer
          Case 3  : \Name        = Buffer
          Case 4  : \ShortName   = Buffer
          Case 5  : \Caption     = Buffer
          Case 6  : \Option1     = Buffer
          Case 7 :  \Option2     = Buffer
          Case 8 :  \Option3     = Buffer
          Case 9 :  \FontText    = Buffer
          Case 10 : \FrontColor  = Buffer
          Case 11 : \BackColor   = Buffer
          Case 12 : \ToolTip     = Buffer
          Case 13 : \BindGadget  = Buffer
          Case 14 : \Constants   = Buffer
        EndSelect
        If I > 0  : \CountGadget = 1 : EndIf
      Next
    Next
  EndWith
  
  ;- DataSection ModelObjectData
  DataSection
    ModelObjectData:
    ;"GadgetType","Model","Name","ShortName","Caption","Option1","Option2","Option3","FontText","FrontColor","BackColor","ToolTip","BindGadgetEvent","Constants"
    Data.s "0","OpenWindow","Window","Window","#Titl:","#Tool:000","#Boun:0|0|0|0","","","#Nooo","","#Nooo","#Nooo","Window_SystemMenu|Window_MinimizeGadget|Window_MaximizeGadget|Window_SizeGadget|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets|Window_NoActivate"
    Data.s "1","ButtonGadget","Button","Btn","#Text:","","","","","#Nooo","#Nooo","","0","Button_Right|Button_Left|Button_Default|Button_MultiLine|Button_Toggle|#BS_Bottom|#BS_Flat|#BS_Top"
    Data.s "19","ButtonImageGadget","ButtonImage","BtnImg","","#Imag:0","","","#Nooo","#Nooo","#Nooo","","0","Button_Toggle"
    Data.s "20","CalendarGadget","Calendar","Calend","","#Date:0","","","","","","","0","Calendar_Borderless"
    ;Data.s "33","CanvasContainerGadget","CanvasContainer","CanvCont","","","","","#Nooo","#Nooo","#Nooo","","0","Canvas_Border|Canvas_ClipMouse|Canvas_Keyboard|Canvas_DrawFocus|Canvas_Container"
    Data.s "33","CanvasGadget","Canvas","Canv","","","","","#Nooo","#Nooo","#Nooo","","0","Canvas_Border|Canvas_ClipMouse|Canvas_Keyboard|Canvas_DrawFocus|Canvas_Container"
    Data.s "4","CheckBoxGadget","CheckBox","Check","#Text:","","","","","#Nooo","#Nooo","","0","CheckBox_Right|CheckBox_Center|CheckBox_ThreeState|#BS_Bottom|#BS_LeftText|#BS_MultiLine|#BS_Top"
    Data.s "8","ComboBoxGadget","Combo","Combo","#Elem:","","","","","#Nooo","#Nooo","","0","ComboBox_Editable|ComboBox_LowerCase|ComboBox_UpperCase|ComboBox_Image"
    Data.s "11","ContainerGadget","Container","Cont","","","","","#Nooo","","","","#Nooo","Container_BorderLess|Container_Flat|Container_Raised|Container_Single|Container_Double"
    Data.s "21","DateGadget","Date","Date","#Date:%yyyy-%mm-%dd","#Date:0","","","","#Nooo","#Nooo","","0","Date_UpDown|Date_CheckBox"
    Data.s "22","EditorGadget","Editor","Edit","","","","","","","","","0","Editor_ReadOnly|Editor_WordWrap|#ES_Center|#ES_NoHideSel|#ES_Right"
    Data.s "25","ExplorerComboGadget","ExplorerCombo","ExpCombo","#Dir$:","","","","","#Nooo","#Nooo","#Nooo","0","Explorer_DrivesOnly|Explorer_Editable|Explorer_NoMyDocuments"
    Data.s "23","ExplorerListGadget","ExplorerList","ExpList","#Dir$:","","","","","","","","0","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_MultiSelect|Explorer_GridLines|Explorer_HeaderDragDrop|Explorer_FullRowSelect|Explorer_NoFiles|Explorer_NoFolders|Explorer_NoParentFolder|Explorer_NoDirectoryChange|Explorer_NoDriveRequester|Explorer_NoSort|Explorer_NoMyDocuments|Explorer_AutoSort|Explorer_HiddenFiles"
    Data.s "24","ExplorerTreeGadget","ExplorerTree","ExpTree","#Dir$:","","","","","","","","0","Explorer_BorderLess|Explorer_AlwaysShowSelection|Explorer_NoLines|Explorer_NoButtons|Explorer_NoFiles|Explorer_NoDriveRequester|Explorer_NoMyDocuments|Explorer_AutoSort"
    Data.s "7","FrameGadget","Frame","Frame","#Text:","","","","","#Nooo","#Nooo","#Nooo","#Nooo","Frame_Single|Frame_Double|Frame_Flat"
    Data.s "10","HyperLinkGadget","HyperLink","Hyper","#Url$:https://www.purebasic.com/","#Hard:RGB(0,0,128)","","","","","","","0","HyperLink_Underline"
    Data.s "9","ImageGadget","Image","Img","","#Imag:0","","","#Nooo","#Nooo","#Nooo","","0","Image_Border|Image_Raised"
    Data.s "13","IPAddressGadget","IPAddress","IPAdd","","","","","","#Nooo","#Nooo","","0",""
    Data.s "12","ListIconGadget","ListIcon","ListIcon","#Text:","","#Widh:120","","","","","","0","ListIcon_CheckBoxes|ListIcon_ThreeState|ListIcon_MultiSelect|ListIcon_GridLines|ListIcon_FullRowSelect|ListIcon_HeaderDragDrop|ListIcon_AlwaysShowSelection|#LVS_NoColumnHeader|#LVS_NoScroll"
    Data.s "6","ListViewGadget","ListView","ListView","","","","","","","","","0","ListView_MultiSelect|ListView_ClickSelect|#LBS_ExtendedSel|#LBS_MultiColumn"
    Data.s "34","OpenGLGadget","OpenGL","OpenGL","","","","","#Nooo","#Nooo","#Nooo","","0","OpenGL_Keyboard|OpenGL_NoFlipSynchronization|OpenGL_FlipSynchronization|OpenGL_NoDepthBuffer|OpenGL_16BitDepthBuffer|OpenGL_24BitDepthBuffer|OpenGL_NoStencilBuffer|OpenGL_8BitStencilBuffer|OpenGL_NoAccumulationBuffer|OpenGL_32BitAccumulationBuffer|OpenGL_64BitAccumulationBuffer"
    Data.s "5","OptionGadget","Option","Opt","#Text:","","","","","#Nooo","#Nooo","","0","_#BS_Bottom|_#BS_LeftText|_#BS_MultiLine|_#BS_PushLike|_#BS_Top"
    Data.s "28","PanelGadget","Panel","Panel","","","","","","#Nooo","#Nooo","","0",""
    Data.s "14","ProgressBarGadget","ProgressBar","Progres","","#Mini:0","#Maxi:100","","#Nooo","","","","#Nooo","ProgressBar_Smooth|ProgressBar_Vertical"
    Data.s "31","ScintillaGadget","Scintilla","Scint","","#Hard:0","","","","#Nooo","#Nooo","#Nooo","0",""
    Data.s "16","ScrollAreaGadget","ScrollArea","ScrlArea","","#InrW:1200","#InrH:800","#Step:10","#Nooo","#Nooo","","#Nooo","0","ScrollArea_Flat|ScrollArea_Raised|ScrollArea_Single|ScrollArea_BorderLess|ScrollArea_Center"
    Data.s "15","ScrollBarGadget","ScrollBar","ScrlBar","","#Mini:0","#Maxi:100","#Step:10","#Nooo","#Nooo","#Nooo","","0","ScrollBar_Vertical"
    Data.s "26","SpinGadget","Spin","Spin","","#Mini:0","#Maxi:100","","","","","","0","Spin_ReadOnly|Spin_Numeric|_#ES_Number"
    Data.s "29","SplitterGadget","Splitter","Splitter","","","","","#Nooo","#Nooo","#Nooo","#Nooo","0","Splitter_Vertical|Splitter_Separator|Splitter_FirstFixed|Splitter_SecondFixed"
    Data.s "2","StringGadget","String","String","#Text:","","","","","","","","0","String_Numeric|String_Password|String_ReadOnly|String_LowerCase|String_UpperCase|String_BorderLess|#ES_Center|#ES_MultiLine|#ES_NoHideSel|#ES_Right"
    Data.s "3","TextGadget","Text","Txt","#Text:","","","","","","","#Nooo","#Nooo","Text_Center|Text_Right|Text_Border|#SS_EndEllipsis|#SS_PathEllipsis|#SS_WordEllipsis"
    Data.s "17","TrackBarGadget","TrackBar","Track","","#Mini:0","#Maxi:100","","#Nooo","#Nooo","#Nooo","","0","TrackBar_Ticks|TrackBar_Vertical"
    Data.s "27","TreeGadget","Tree","Tree","","","","","","","","","0","Tree_AlwaysShowSelection|Tree_NoLines|Tree_NoButtons|Tree_CheckBoxes|Tree_ThreeState"
    Data.s "18","WebGadget","WebView","Web","#Url$:about:blank","","","","","#Nooo","#Nooo","#Nooo","0",""
    Data.s "50","PanelGadget","Tab","Tab","#TabN:","","","","#Nooo","#Nooo","#Nooo","#Nooo","#Nooo",""
    Data.s "99","---END---","","","","","","","#Nooo","#Nooo","#Nooo","#Nooo","0",""
  EndDataSection
EndProcedure

; ----- End Private Model ----- 
;
;- ----- Private GetParentPB -----

Procedure IsPBContainer(Gadget)
  
  ; Procedure IsContainer based on procedure IsCanvasContainer by mk-soft: https://www.purebasic.fr/english/viewtopic.php?t=79002
  Select GadgetType(Gadget)
    Case #PB_GadgetType_Container, #PB_GadgetType_Panel, #PB_GadgetType_ScrollArea, #PB_GadgetType_Splitter
      ProcedureReturn #True
    Case #PB_GadgetType_Canvas
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          If GetWindowLongPtr_(GadgetID(Gadget), #GWL_STYLE) & #WS_CLIPCHILDREN
            ProcedureReturn #True
          EndIf
        CompilerCase #PB_OS_MacOS
          Protected sv, count
          sv    = CocoaMessage(0, GadgetID(Gadget), "subviews")
          count = CocoaMessage(0, sv, "count")
          ProcedureReturn count
        CompilerCase #PB_OS_Linux
          Protected GList, count
          GList = gtk_container_get_children_(GadgetID(Gadget))
          If GList
            count = g_list_length_(GList)
            g_list_free_(GList)
            ProcedureReturn count
          EndIf
      CompilerEndSelect
  EndSelect
  
  ProcedureReturn #False
EndProcedure

Procedure WindowPBCallBack(Window, *Window, WindowData)
  Window(0, CountWindow) = Window
  Window(1, CountWindow) = WindowID(Window)
  CountWindow + 1
  ProcedureReturn #True
EndProcedure

Procedure TabObjectPB(Object)
  Protected *ObjectPB.ObjectPBStruct, TmpGadget, I, NbTab = CountGadgetItems(Object)
  
  For I = 0 To NbTab - 1
    OpenGadgetList(Object, I)
    TmpGadget = ButtonGadget(#PB_Any, 0, 0, 0, 0 , "")
    *ObjectPB = AddElement(ObjectPB())
    With *ObjectPB
      \Object          = 50000 + IndexTab
      IndexTab + 1
      \ObjectID        = GetParent_(GadgetID(TmpGadget))
      \Type            = 50
      \IsContainer     = 1
      \ParentObjectID  = GetParent_(\ObjectID)
      \GParentObjectID = I
    EndWith
    FreeGadget(TmpGadget)
    CloseGadgetList()
  Next
EndProcedure

Procedure ObjectPBCallBack(Object, *Object, ObjectData)
  Protected *ObjectPB.ObjectPBStruct = AddElement(ObjectPB())
  
  If *ObjectPB <> 0
    With *ObjectPB
      \Object          = Object
      \ObjectID        = GadgetID(Object)
      \Type            = GadgetType(Object)
      \IsContainer     = IsPBContainer(Object)
      \ParentObjectID  = GetParent_(\ObjectID)
      \GParentObjectID = GetParent_(\ParentObjectID)
      If \Type = #PB_GadgetType_Panel
        TabObjectPB(Object)
      EndIf
    EndWith
  Else
    MessageRequester("Erreur !", "Impossible d'allouer de la mémoire pour le nouvel élément", #PB_MessageRequester_Ok)
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WinPBHierarchy(ParentObjectID, ParentObject, FirstPassDone = #False)
  Static ParentWindowID, Level
  Protected ObjectType
  
  If FirstPassDone = #False
    Level          = 0
    ParentWindowID = ParentObjectID
    FirstPassDone  = #True
  EndIf
  
  Level + 1
  PushListPosition(ObjectPB())
  ResetList(ObjectPB())
  With ObjectPB()
    While NextElement(ObjectPB())
      If ParentWindowID <> ParentObjectID And IsGadget(ParentObject)  : ObjectType = GadgetType(ParentObject) : Else : ObjectType = 0 : EndIf
      If \GParentObjectID <> #PB_Default And (\ParentObjectID = ParentObjectID Or (\GParentObjectID = ParentObjectID And ObjectType = #PB_GadgetType_ScrollArea))
        \ParentObject = ParentObject
        \Level              = Level
        ; Do Not Change \GParentObjectID For Tabs (\Object >= 50000 And < 60000). It is Used then by GetGadgetItemText to Get the Tab Name
        If \GParentObjectID = ParentObjectID And ObjectType = #PB_GadgetType_ScrollArea
          \X                = GadgetX(\Object)
          \Y                = GadgetY(\Object)
          \Width            = GadgetWidth(\Object)
          \Height           = GadgetHeight(\Object)
          \ParentObjectID   = \GParentObjectID
          \GParentObjectID  = #PB_Default   ; 0
        ElseIf \ParentObjectID = ParentObjectID And ObjectType = #PB_GadgetType_Splitter   ; Specific to Exclude Splitter. The Parent of its Chidren is the Grand Parent (= the Splitter Parent)
          \X                = GadgetX(\Object) + GadgetX(ParentObject)
          \Y                = GadgetY(\Object) + GadgetY(ParentObject)
          \Width            = GadgetWidth(\Object)
          \Height           = GadgetHeight(\Object)
          \ParentObjectID   = \GParentObjectID
          \ParentObject     = GetObjectPBFromID(\ParentObjectID)   ; Or GetDlgCtrlID_(\ParentObjectID)
          \GParentObjectID  = #PB_Default                          ; 0
        ElseIf \Object < 50000 Or \Object > 59999
          \X                = GadgetX(\Object)
          \Y                = GadgetY(\Object)
          \Width            = GadgetWidth(\Object)
          \Height           = GadgetHeight(\Object)
          \GParentObjectID  = #PB_Default   ; 0
        EndIf
        If \IsContainer
          If \Type = #PB_GadgetType_Splitter : \Level = 99 : Level - 1 : EndIf             ; Specific to Exclude Splitter. Keep the current Level for the 2 Splitter chidren
          WinPBHierarchy(\ObjectID, \Object, FirstPassDone)
          If \Type <> #PB_GadgetType_Splitter : Level - 1 : EndIf                          ; Specific to Exclude Splitter. Level - 1 without the Splitter type test
        EndIf
      EndIf
    Wend
  EndWith
  PopListPosition(ObjectPB())
EndProcedure

Procedure LoadObjectPB()
  Protected I
  
  CountWindow = PB_Object_Count(PB_Window_Objects)
  If CountWindow = 0
    MessageRequester("Warning", "No Open Window !" +#CRLF$+#CRLF$+ "PBForm2IceDesign() Function Must be Executed After Opening the Window(s)." +#CRLF$+#CRLF$+ "Continue.", #PB_MessageRequester_Ok | #PB_MessageRequester_Warning)
    ProcedureReturn
  EndIf
  ReDim Window(1, CountWindow - 1)
  CountWindow = 0
  PB_Object_EnumerateAll(PB_Window_Objects, @WindowPBCallBack(), 0)
  PB_Object_EnumerateAll(PB_Gadget_Objects, @ObjectPBCallBack(), 0)
  
  If ListSize(ObjectPB()) > 0
    ; Pass through the hierarchy for each window
    CountWindow = PB_Object_Count(PB_Window_Objects)
    For I = 0 To CountWindow - 1
      WinPBHierarchy(Window(1, I), Window(0, I))
    Next
  Else
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

; ----- End Private GetParentPB -----
;
;- ----- Public GetParentPB -----

Procedure GetObjectPBFromID(ObjectID)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected Object = #PB_Default, I
  
  With ObjectPB()
    PushListPosition(ObjectPB())
    ForEach ObjectPB()
      If \ObjectID = ObjectID
        Object = \Object
        Break
      EndIf
    Next
    PopListPosition(ObjectPB())
  EndWith
  If Object = #PB_Default 
    For I = 0 To CountWindow - 1
      If Window(1, I) = ObjectID
        Object = Window(0, I)
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn Object
EndProcedure

Procedure GetParentPB(Object)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected *ObjectPB.ObjectPBStruct : _ObjectPB_(*ObjectPB, Object, 0)
  
  ProcedureReturn *ObjectPB\ParentObject
EndProcedure

Procedure GetWindowPBRoot(Object)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected *ObjectPB.ObjectPBStruct
  
  PushListPosition(ObjectPB())
  Repeat
    If _ObjectPB_(*ObjectPB, Object, 0)
      Object = *ObjectPB\ParentObject
    Else
      Object = #PB_Default
      Break   ; It should not happen
    EndIf
  Until *ObjectPB\Level = 1
  PopListPosition(ObjectPB())
  
  ProcedureReturn Object
EndProcedure

Procedure GetParentPBID(Object)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected *ObjectPB.ObjectPBStruct : _ObjectPB_(*ObjectPB, Object, 0)
  
  ProcedureReturn *ObjectPB\ParentObjectID
EndProcedure

Procedure ParentPBisWindow(Object)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected *ObjectPB.ObjectPBStruct : _ObjectPB_(*ObjectPB, Object, 0)
  
  If *ObjectPB\Level = 1
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure ParentPBisGadget(Object)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected *ObjectPB.ObjectPBStruct : _ObjectPB_(*ObjectPB, Object, 0)
  
  If *ObjectPB\Level > 1
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure CountChildPBGadget(ParentObject, GrandChildren = #False, FirstPassDone = #False)
  Static Level, Count
  Protected *ObjectPB.ObjectPBStruct, Object, ReturnVal
  
  If FirstPassDone = 0
    _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
    If IsWindow(ParentObject)
      Level = 0
    ElseIf IsGadget(ParentObject)
      Object = ParentObject
      If _ObjectPB_(*ObjectPB, Object, 0)
        If Not(*ObjectPB\IsContainer)
          ProcedureReturn #PB_Default
        EndIf
        Level = *ObjectPB\Level
      Else
        ProcedureReturn #PB_Default
      EndIf
    EndIf
    Count         = 0
    FirstPassDone = #True
  EndIf
  
  Level + 1
  PushListPosition(ObjectPB())
  ResetList(ObjectPB())
  With ObjectPB()
    While NextElement(ObjectPB())
      If \Level = Level And \ParentObject = ParentObject
        Count + 1
        If GrandChildren And \IsContainer
          CountChildPBGadget(ObjectPB()\Object, GrandChildren, FirstPassDone)
          Level - 1
        EndIf
      EndIf
    Wend
  EndWith
  PopListPosition(ObjectPB())
  
  ProcedureReturn Count
EndProcedure

Procedure EnumWinChildPB(ParentObject, FirstPassDone = #False)
  Static Level
  Protected ReturnVal
  
  If FirstPassDone = 0
    _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
    If IsWindow(ParentObject)
      Level     = 0
      Debug "Enum Child Gadget of Window " + LSet(Str(ParentObject), 10) + "| WindowID " + LSet(Str(WindowID(ParentObject)), 10) + "(Level = 0)"
    Else
      ProcedureReturn #PB_Default
    EndIf
    FirstPassDone = #True
  EndIf
  
  Level + 1
  PushListPosition(ObjectPB())
  ResetList(ObjectPB())
  With ObjectPB()
    While NextElement(ObjectPB())
      If \Level = Level And \ParentObject = ParentObject
        If \Object >= 50000 And \Object < 60000
          Debug LSet("", \Level * 4 , " ") + "PanelTab              " + LSet(Str(\Object), 10) + "ParentGadget " + LSet(Str(\ParentObject), 10)  + "| GadgetID " + LSet(Str(\ObjectID), 10) + "ParentGadgetID " + LSet(Str(\ParentObjectID), 10) + "(Level = " + Str(\Level) + ") - Tab: " + GetGadgetItemText(\ParentObject, \GParentObjectID)
        ElseIf \Type = #PB_GadgetType_Canvas And \IsContainer
          Debug LSet("", \Level * 4 , " ") + "CanvasContainerGadget " + LSet(Str(\Object), 10) + "ParentGadget " + LSet(Str(\ParentObject), 10)  + "| GadgetID " + LSet(Str(\ObjectID), 10) + "ParentGadgetID " + LSet(Str(\ParentObjectID), 10) + "(Level = " + Str(\Level) + ") - Tab: " + GetGadgetItemText(\ParentObject, \GParentObjectID)
        Else
          Debug LSet("", \Level * 4 , " ") + LSet(ModelObject(Str(\Type))\Model, 22) + LSet(Str(\Object), 10) + "ParentGadget " + LSet(Str(\ParentObject), 10)  + "| GadgetID " + LSet(Str(\ObjectID), 10) + "ParentGadgetID " + LSet(Str(\ParentObjectID), 10) + "(Level = " + Str(\Level) + ")"
        EndIf
        If \IsContainer
          EnumWinChildPB(ObjectPB()\Object, FirstPassDone)
          Level - 1
        EndIf
      EndIf
    Wend
  EndWith
  PopListPosition(ObjectPB())
EndProcedure

Procedure EnumChildPB(Window = #PB_All)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected I
  
  If Window = #PB_All
    For I = 0 To CountWindow - 1
      EnumWinChildPB(Window(0, I))
      Debug ""
    Next
  Else
    If IsWindow(Window)
      EnumWinChildPB(Window)
    EndIf
  EndIf
EndProcedure

; ----- End Public GetParentPB -----
;
;- ----- Private LoadPB -----

Procedure.s AddWindowPBFlag(Window, Constants.s)
  Protected Handle      = WindowID(Window)
  Protected StyleFlag   = GetWindowLongPtr_(Handle, #GWL_STYLE)
  Protected ExStyleFlag = GetWindowLongPtr_(Handle, #GWL_EXSTYLE)
  Protected DesktopWidth, DesktopHeight, I, Desktop = ExamineDesktops()-1
  
  ; Window_SystemMenu|Window_MinimizeGadget|Window_MaximizeGadget|Window_SizeGadget|Window_Invisible|Window_TitleBar|Window_Tool|Window_BorderLess|Window_ScreenCentered|Window_WindowCentered|Window_Maximize|Window_Minimize|Window_NoGadgets|Window_NoActivate
  If _IsFlag_(StyleFlag, #WS_SYSMENU)
    Constants = ReplaceString(Constants, "Window_SystemMenu", "Window_SystemMenu(x)", #PB_String_NoCase)
  EndIf
  If _IsFlag_(StyleFlag, #WS_MINIMIZEBOX)
    Constants = ReplaceString(Constants, "Window_MinimizeGadget", "Window_MinimizeGadget(x)", #PB_String_NoCase)
  EndIf
  If _IsFlag_(StyleFlag, #WS_MAXIMIZEBOX)
    Constants = ReplaceString(Constants, "Window_MaximizeGadget", "Window_MaximizeGadget(x)", #PB_String_NoCase)
  EndIf
  If _IsFlag_(StyleFlag, #WS_SIZEBOX)
    Constants = ReplaceString(Constants, "Window_SizeGadget", "Window_SizeGadget(x)", #PB_String_NoCase)
  EndIf
  If Not(_IsFlag_(StyleFlag, #WS_VISIBLE))
    Constants = ReplaceString(Constants, "Window_Invisible", "Window_Invisible(x)", #PB_String_NoCase)
  EndIf
  If Not(_IsFlag_(StyleFlag, #WS_BORDER))
    Constants = ReplaceString(Constants, "Window_BorderLess", "Window_BorderLess(x)", #PB_String_NoCase)
    If _IsFlag_(StyleFlag, #WS_CAPTION)
      Constants = ReplaceString(Constants, "Window_TitleBar", "Window_TitleBar(x)", #PB_String_NoCase)
    EndIf
  EndIf
  If _IsFlag_(StyleFlag, #WS_MAXIMIZE)
    Constants = ReplaceString(Constants, "Window_Maximize", "Window_Maximize(x)", #PB_String_NoCase)
  ElseIf _IsFlag_(StyleFlag, #WS_MINIMIZE)
    Constants = ReplaceString(Constants, "Window_Minimize", "Window_Minimize(x)", #PB_String_NoCase)
  EndIf
  ;If _IsFlag_(StyleFlag, #PB_Window_NoGadgets) :Constants = ReplaceString(Constants, "Window_NoGadgets", "Window_NoGadgets(x)", #PB_String_NoCase) : EndIf   ; no sense for importing gadgets
  
  If _IsExFlag_(ExStyleFlag, #WS_EX_TOOLWINDOW)
    Constants = ReplaceString(Constants, "Window_Tool", "Window_Tool(x)", #PB_String_NoCase)
  EndIf
  If _IsExFlag_(ExStyleFlag, #WS_EX_NOACTIVATE)
    Constants = ReplaceString(Constants, "Window_NoActivate", "Window_NoActivate(x)", #PB_String_NoCase)
  EndIf
  
  ; Window_ScreenCentered - If DPIaware
  For i = 0 To Desktop
    DesktopWidth + DesktopWidth(Desktop)
    DesktopHeight + DesktopHeight(Desktop)
  Next
  DesktopWidth = (DesktopWidth - DesktopScaledX(WindowWidth(Window, #PB_Window_FrameCoordinate))) / 2
  DesktopHeight = (DesktopHeight - DesktopScaledY(WindowHeight(Window, #PB_Window_FrameCoordinate))) / 2
  If Abs(DesktopScaledX(WindowX(Window)) - DesktopWidth) < 2  And Abs(DesktopScaledY(WindowY(Window)) - DesktopHeight) < 2   ; 0 or 1 depending on rounding
    Constants = ReplaceString(Constants, "Window_ScreenCentered", "Window_ScreenCentered(x)", #PB_String_NoCase)
    CompilerIf #DebugON : Debug "#PB_Window_ScreenCentered" : CompilerEndIf
  EndIf
  ; Window_WindowCentered - If DPIaware
  Handle = GetProp_(GetParent_(Handle), "PB_WindowID")-1   ; PB Parent Window Number
  If IsWindow(Handle)
    DesktopWidth = (DesktopScaledX(WindowWidth(Handle)) - DesktopScaledX(WindowWidth(Window, #PB_Window_FrameCoordinate))) / 2
    DesktopHeight = (DesktopScaledY(WindowHeight(Handle)) - DesktopScaledY(WindowHeight(Window, #PB_Window_FrameCoordinate))) / 2
    If Abs(DesktopScaledX(WindowX(Window)) - DesktopWidth) < 2  And Abs(DesktopScaledY(WindowY(Window)) - DesktopHeight) < 2   ; 0 or 1 depending on rounding
      Constants = ReplaceString(Constants, "Window_WindowCentered", "Window_WindowCentered(x)", #PB_String_NoCase)
      CompilerIf #DebugON : Debug "#PB_Window_WindowCentered" : CompilerEndIf
    EndIf
  EndIf
  
  ProcedureReturn Constants
EndProcedure

Procedure AddWindowPB(Window)
  Protected *LoadPB.LoadPBStruct, Color 
  
  *LoadPB = AddElement(LoadPB())
  If *LoadPB <> 0
    With *LoadPB
      \Level         = 0      
      \Gadget        = 2
      \Type          = 0
      \Container     = #True
      \ParentGadget  = 0
      \TabIndex      = #PB_Ignore
      \X             = 0        
      \Y             = 0      
      \Width         = WindowWidth(Window)      
      \Height        = WindowHeight(Window)
      \LockLeft      = #True
      \LockTop       = #True
      If FindMapElement(ModelObject(), Str(\Type))
        \Model = ModelObject()\Model
        CompilerIf #UseShortNames
          \Name      = "#" + ModelObject()\ShortName + "_" + Str(ModelObject()\CountGadget)
        CompilerElse
          \Name      = "#" + ModelObject()\Name + "_" + Str(ModelObject()\CountGadget)
        CompilerEndIf
        ModelObject()\CountGadget + 1
        \Caption     = ModelObject()\Caption + GetWindowTitle(Window)
        \Option1     = "#Tool:"   ; "#Tool:000"
        If GetMenu_(WindowID(Window))
          \Option1   = \Option1 + "1"
        Else
          \Option1   = \Option1 + "0"
        EndIf
        \Option1     = \Option1 + "00"   ; ToolBarFlag + StatusBar
        \Option2     = ModelObject()\Option2
        \Option3     = ModelObject()\Option3
        \FontText    = ModelObject()\FontText
        \FrontColor  = ModelObject()\FrontColor
        Color        = GetWindowColor(Window)
        If Color <> #PB_Default
          \BackColor = _HexColor_(Color)
        EndIf
        \ToolTip     = ModelObject()\ToolTip    
        \BindGadget  = ModelObject()\BindGadget
        \Constants   = AddWindowPBFlag(Window, ModelObject()\Constants)
        \Key         = RSet(Str(\Level),2, "0") + RSet(Str(\TabIndex), 6, "0") + RSet(Str(\Y), 5, "0") + RSet(Str(\X), 5, "0")
        
        CompilerIf #DebugON
          Debug " ---> Hierarchical View of Window and Gadgets Using: Object(#Gadget,X,Y,W,H,Capion,Option1,Option2,Option3,Constant(x))"
          Debug \Model + "(" + \Name + ", " + Str(\X) + ", " + Str(\Y) + ", " + Str(\Width) + ", " + Str(\Height) + ", " +
                #DQUOTE$+ Mid(\Caption, 7) +#DQUOTE$+ ", " + \Constants + ")"
          If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> "" : Debug "SetWindowColor(" + \Name + ", " + \BackColor + ")" : EndIf
        CompilerEndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure.s GetToolTipText(Gadget)
  Static *PB_Globals.PB_Globals
  Protected TTinfo.TOOLINFO, Buffer.s
  
  If *PB_Globals  = 0
    *PB_Globals   = PB_Object_GetThreadMemory(PB_Gadget_Globals)
  EndIf
  Buffer          = Space(#MAX_PATH)
  TTinfo\cbSize   = SizeOf(TTinfo)
  TTinfo\uId      = GadgetID(Gadget)
  TTinfo\hwnd     = GetParent_(TTinfo\uId)
  TTinfo\lpszText = @Buffer
  SendMessage_(*PB_Globals\ToolTipWindow, #TTM_GETTEXT, 0, @TTinfo)
  
  ProcedureReturn Trim(Buffer) 
EndProcedure

Procedure.s CheckPBName(Name.s)
  Static CheckNameRegEx.i
  
  Name = ReplaceString(Name, #CRLF$, "_")
  Name = ReplaceString(Name, #DQUOTE$, "_")
  Name = ReplaceString(Name, " ", "_")
  Name = ReplaceString(Name, "__", "_")
  If Left(Name, 1)  = "_" : Name = Right(Name, Len(Name) - 1) : EndIf
  If Right(Name, 1) = "_" : Name = Left(Name, Len(Name) - 1)  : EndIf
  
  If CheckNameRegEx = 0 Or IsRegularExpression(CheckNameRegEx) = 0
    CheckNameRegEx = CreateRegularExpression(#PB_Any, "^[^a-zA-Z_]|\W+")
  EndIf
  If IsRegularExpression(CheckNameRegEx)
    Name = ReplaceRegularExpression(CheckNameRegEx, Name, "")    ; If IsRegularExpression(CheckNameRegEx) : FreeRegularExpression(CheckNameRegEx) : EndIf
  EndIf
  
  ProcedureReturn Name
EndProcedure

Procedure.s UniquePBName(BaseName.s, Caption.s)
  Protected Name.s, NameFound.i, I.i
  
  Caption = CheckPBName(Caption)
  Name = BaseName + "_" + Caption
  PushListPosition(LoadPB())
  For I = 0 To 999
    If I > 0 : Name = BaseName + "_" + Caption + "_" + Str(I) : EndIf
    NameFound = #False
    ForEach LoadPB()
      If LoadPB()\Name = Name 
        NameFound = #True
        Break
      EndIf
    Next
    If NameFound = #False
      Break
    EndIf
  Next
  PopListPosition(LoadPB())
  
  ProcedureReturn Name
EndProcedure

Procedure.s AddGadgetPBFlag(Gadget, Constants.s)
  If Gadget >= 50000 And Gadget < 60000 : ProcedureReturn : EndIf
  Protected Handle      = GadgetID(Gadget)
  Protected StyleFlag   = GetWindowLongPtr_(Handle, #GWL_STYLE)
  Protected ExStyleFlag = GetWindowLongPtr_(Handle, #GWL_EXSTYLE)
  
  Select GadgetType(Gadget)
    Case #PB_GadgetType_Button   ;Ok
      If _IsFlag_(StyleFlag, #BS_RIGHT)   ;Ok
        Constants = ReplaceString(Constants, "Button_Right", "Button_Right(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_LEFT)   ;Ok
        Constants = ReplaceString(Constants, "Button_Left", "Button_Left(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_DEFPUSHBUTTON)   ;Ok
        Constants = ReplaceString(Constants, "Button_Default", "Button_Default(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_MULTILINE)   ;Ok
        Constants = ReplaceString(Constants, "Button_MultiLine", "Button_MultiLine(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_PUSHLIKE | #BS_AUTOCHECKBOX)   ;Ok
        Constants = ReplaceString(Constants, "Button_Toggle", "Button_Toggle(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_BOTTOM)   ;Ok
        Constants = ReplaceString(Constants, "#BS_Bottom", "#BS_Bottom(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_FLAT)   ;Ok
        Constants = ReplaceString(Constants, "#BS_Flat", "#BS_Flat(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_TOP)   ;Ok
        Constants = ReplaceString(Constants, "#BS_Top", "#BS_Top(x)", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ButtonImage   ;Ok
      If _IsFlag_(StyleFlag, #BS_PUSHLIKE | #BS_AUTOCHECKBOX)   ;Ok
        Constants = ReplaceString(Constants, "Button_Toggle", "Button_Toggle(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_Calendar   ;Ok
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE))   ;Ok
        Constants = ReplaceString(Constants, "Calendar_Borderless", "Calendar_Borderless(x))", #PB_String_NoCase)
      EndIf  
      
    Case #PB_GadgetType_Canvas
      If _IsFlag_(StyleFlag, #WS_CLIPCHILDREN)   ;Ok
        Constants = ReplaceString(Constants, "Canvas_Container", "Canvas_Container(x)", #PB_String_NoCase)
      EndIf
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE))   ;Ok
        Constants = ReplaceString(Constants, "Canvas_Border", "Canvas_Border(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Canvas_ClipMouse", "Canvas_ClipMouse(x))", #PB_String_NoCase)
      If _IsFlag_(StyleFlag, #WS_GROUP | #WS_TABSTOP)   ;Ok
        Constants = ReplaceString(Constants, "Canvas_Keyboard", "Canvas_Keyboard(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Canvas_DrawFocus", "Canvas_DrawFocus(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_CheckBox   ;Ok
      If _IsFlag_(StyleFlag, #BS_CENTER)   ;Ok
        Constants = ReplaceString(Constants, "CheckBox_Center", "CheckBox_Center(x))", #PB_String_NoCase)
      Else
        If _IsFlag_(StyleFlag, #BS_RIGHT)   ;Ok
          Constants = ReplaceString(Constants, "CheckBox_Right", "CheckBox_Right(x))", #PB_String_NoCase)
        EndIf
      EndIf
      If _IsFlag_(StyleFlag, #BS_3STATE)   ;Ok
        Constants = ReplaceString(Constants, "CheckBox_ThreeState", "CheckBox_ThreeState(x))"	, #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_BOTTOM)   ;Ok
        Constants = ReplaceString(Constants, "#BS_Bottom", "#BS_Bottom(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_LEFTTEXT)   ;Ok
        Constants = ReplaceString(Constants, "#BS_LeftText", "#BS_LeftText(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_MULTILINE)   ;Ok
        Constants = ReplaceString(Constants, "#BS_MultiLine", "#BS_MultiLine(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_TOP)   ;Ok
        Constants = ReplaceString(Constants, "#BS_Top", "#BS_Top(x)", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ComboBox   ;Ok	
      If _IsFlag_(StyleFlag, #PB_ComboBox_LowerCase)   ;Ok  (#CBS_LowerCase)
        Constants = ReplaceString(Constants, "ComboBox_LowerCase", "ComboBox_LowerCase(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #PB_ComboBox_UpperCase)   ;Ok  (#CBS_UpperCase)
        Constants = ReplaceString(Constants, "ComboBox_UpperCase", "ComboBox_UpperCase(x))", #PB_String_NoCase)
      EndIf
      Protected ChildGadget = GetWindow_(Handle, #GW_CHILD)
      If ChildGadget
        Protected Buffer.s = Space(64)
        If GetClassName_(ChildGadget, @Buffer, 64)
          If Buffer = "Edit"
            Constants = ReplaceString(Constants, "ComboBox_Editable", "ComboBox_Editable(x))", #PB_String_NoCase)   ;Ok
          ElseIf Buffer = "ComboBox"
            ChildGadget = GetWindow_(ChildGadget, #GW_CHILD)
            If ChildGadget
              Buffer = Space(64)
              If GetClassName_(ChildGadget, @Buffer, 64)
                If Buffer = "Edit"
                  Constants = ReplaceString(Constants, "ComboBox_Editable", "ComboBox_Editable(x))", #PB_String_NoCase)   ;Ok
                  Constants = ReplaceString(Constants, "ComboBox_Image", "ComboBox_Image(x))", #PB_String_NoCase)         ;Ok
                EndIf
              EndIf
            Else
              Constants = ReplaceString(Constants, "ComboBox_Image", "ComboBox_Image(x))", #PB_String_NoCase)    ;Ok
            EndIf
          EndIf
        EndIf
      EndIf
      
    Case #PB_GadgetType_Container   ;Ok The order if,elseif is important
      If _IsFlag_(StyleFlag, #WS_BORDER)   ;Ok
        Constants = ReplaceString(Constants, "Container_Flat", "Container_Flat(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_WINDOWEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Container_Raised", "Container_Raised(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_STATICEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Container_Single", "Container_Single(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Container_Double", "Container_Double(x))", #PB_String_NoCase)
      Else
        ;Constants = ReplaceString(Constants, "Container_BorderLess", "Container_BorderLess(x))", #PB_String_NoCase)   ; Default value
      EndIf
      
    Case #PB_GadgetType_Date   ;Ok
      If _IsFlag_(StyleFlag, #DTS_UPDOWN)   ;Ok
        Constants = ReplaceString(Constants, "Date_UpDown", "Date_UpDown(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #DTS_SHOWNONE)   ;Ok
        Constants = ReplaceString(Constants, "Date_CheckBox", "Date_CheckBox(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_Editor
      If _IsFlag_(StyleFlag, #ES_READONLY)   ;Ok
        Constants = ReplaceString(Constants, "Editor_ReadOnly", "Editor_ReadOnly(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Editor_WordWrap", "Editor_WordWrap(x))", #PB_String_NoCase)
      If _IsFlag_(StyleFlag, #ES_CENTER)   ;Ok
        Constants = ReplaceString(Constants, "#ES_Center", "#ES_Center(x)", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "#ES_NoHideSel", "#ES_NoHideSel(x)", #PB_String_NoCase)
      If _IsFlag_(StyleFlag, #ES_RIGHT)   ;Ok
        Constants = ReplaceString(Constants, "#ES_Right", "#ES_Right(x)", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ExplorerCombo
      If Not(_IsFlag_(StyleFlag, #CBS_SIMPLE))
        Constants = ReplaceString(Constants, "Explorer_Editable", "Explorer_Editable(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_DrivesOnly", "Explorer_DrivesOnly(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoMyDocuments", "Explorer_NoMyDocuments(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_ExplorerList
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_BorderLess", "Explorer_BorderLess(x))", #PB_String_NoCase)
      EndIf 
      If _IsFlag_(StyleFlag, #LVS_SHOWSELALWAYS)   ;Ok
        Constants = ReplaceString(Constants, "Explorer_AlwaysShowSelection", "Explorer_AlwaysShowSelection(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #LVS_SINGLESEL))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_MultiSelect", "Explorer_MultiSelect(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #WS_VSCROLL))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_NoFolders", "Explorer_NoFolders(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #LVS_NOSORTHEADER)   ;Ok
        Constants = ReplaceString(Constants, "Explorer_NoSort", "Explorer_NoSort(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_GridLines", "Explorer_GridLines(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_HeaderDragDrop", "Explorer_HeaderDragDrop(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_FullRowSelect", "Explorer_FullRowSelect(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoFiles", "Explorer_NoFiles(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoParentFolder", "Explorer_NoParentFolder(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoDirectoryChange", "Explorer_NoDirectoryChange(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoDriveRequester", "Explorer_NoDriveRequester(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoMyDocuments", "Explorer_NoMyDocuments(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_AutoSort", "Explorer_AutoSort(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_HiddenFiles", "Explorer_HiddenFiles(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_ExplorerTree
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_BorderLess", "Explorer_BorderLess(x))", #PB_String_NoCase)
      EndIf 
      If _IsFlag_(StyleFlag, #TVS_SHOWSELALWAYS)   ;Ok
        Constants = ReplaceString(Constants, "Explorer_AlwaysShowSelection", "Explorer_AlwaysShowSelection(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #TVS_HASLINES))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_NoLines", "Explorer_NoLines(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #TVS_HASBUTTONS))   ;Ok
        Constants = ReplaceString(Constants, "Explorer_NoButtons", "Explorer_NoButtons(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoFiles", "Explorer_NoFiles(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoDriveRequester", "Explorer_NoDriveRequester(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_NoMyDocuments", "Explorer_NoMyDocuments(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Explorer_AutoSort", "Explorer_AutoSort(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_Frame   ;Ok The order if,elseif is important
      If _IsFlag_(StyleFlag, #WS_BORDER)   ;Ok
        Constants = ReplaceString(Constants, "Frame_Flat", "Frame_Flat(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_STATICEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Frame_Single", "Frame_Single(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Frame_Double", "Frame_Double(x))", #PB_String_NoCase)
      EndIf
      
      ; Case #PB_GadgetType_HyperLink   ;Not Ok
      ;Not Ok  Constants = ReplaceString(Constants, "HyperLink_Underline", "HyperLink_Underline(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_Image   ;Ok
      If _IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Image_Border", "Image_Border(x))", #PB_String_NoCase)
      ElseIf _IsExFlag_(ExStyleFlag, #WS_EX_WINDOWEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Image_Raised", "Image_Raised(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ListIcon
      If Not(_IsFlag_(StyleFlag, #LVS_SINGLESEL))   ;Ok
        Constants = ReplaceString(Constants, "ListIcon_MultiSelect", "ListIcon_MultiSelect(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #LVS_SHOWSELALWAYS)   ;Ok
        Constants = ReplaceString(Constants, "ListIcon_AlwaysShowSelection", "ListIcon_AlwaysShowSelection(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #LVS_NOCOLUMNHEADER)
        Constants = ReplaceString(Constants, "#LVS_NoColumnHeader", "#LVS_NoColumnHeader(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #LVS_NOSCROLL)
        Constants = ReplaceString(Constants, "#LVS_NoScroll", "#LVS_NoScroll(x)", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "ListIcon_CheckBoxes", "ListIcon_CheckBoxes(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "ListIcon_ThreeState", "ListIcon_ThreeState(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "ListIcon_GridLines", "ListIcon_GridLines(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "ListIcon_FullRowSelect", "ListIcon_FullRowSelect(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "ListIcon_HeaderDragDrop", "ListIcon_HeaderDragDrop(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_ListView   ;Ok
      If _IsFlag_(StyleFlag, #LBS_MULTIPLESEL)   ;Ok
        Constants = ReplaceString(Constants, "ListView_ClickSelect", "ListView_ClickSelect(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #LBS_EXTENDEDSEL)   ;Ok
        Constants = ReplaceString(Constants, "ListView_MultiSelect", "ListView_MultiSelect(x))", #PB_String_NoCase)
        ;Same Constants = ReplaceString(Constants, "#LBS_ExtendedSel", "#LBS_ExtendedSel(x)", #PB_String_NoCase)
      EndIf   
      If _IsFlag_(StyleFlag, #LBS_MULTICOLUMN)
        Constants = ReplaceString(Constants, "#LBS_MultiColumn", "#LBS_MultiColumn(x)", #PB_String_NoCase)
      EndIf
      
      ; Case #PB_GadgetType_OpenGL   ;Not Ok
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_Keyboard", "OpenGL_Keyboard(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_NoFlipSynchronization", "OpenGL_NoFlipSynchronization(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_FlipSynchronization", "OpenGL_FlipSynchronization(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_NoDepthBuffer", "OpenGL_NoDepthBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_16BitDepthBuffer", "OpenGL_16BitDepthBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_24BitDepthBuffer", "OpenGL_24BitDepthBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_NoStencilBuffer", "OpenGL_NoStencilBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_8BitStencilBuffer", "OpenGL_8BitStencilBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_NoAccumulationBuffer", "OpenGL_NoAccumulationBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_32BitAccumulationBuffer", "OpenGL_32BitAccumulationBuffer(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "OpenGL_64BitAccumulationBuffer", "OpenGL_64BitAccumulationBuffer(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_Option   ;Ok
      If _IsFlag_(StyleFlag, #BS_BOTTOM)   ;Ok
        Constants = ReplaceString(Constants, "_#BS_Bottom", "_#BS_Bottom(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_LEFTTEXT)   ;Ok
        Constants = ReplaceString(Constants, "_#BS_LeftText", "_#BS_LeftText(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_MULTILINE)   ;Ok
        Constants = ReplaceString(Constants, "_#BS_MultiLine", "_#BS_MultiLine(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_PUSHLIKE)   ;Ok
        Constants = ReplaceString(Constants, "_#BS_PushLike", "_#BS_PushLike(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #BS_TOP)   ;Ok
        Constants = ReplaceString(Constants, "_#BS_Top", "_#BS_Top(x)", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ProgressBar   ;Ok
      If _IsFlag_(StyleFlag, #PBS_SMOOTH)   ;Ok
        Constants = ReplaceString(Constants, "ProgressBar_Smooth", "ProgressBar_Smooth(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #PBS_VERTICAL)   ;Ok
        Constants = ReplaceString(Constants, "ProgressBar_Vertical", "ProgressBar_Vertical(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_ScrollArea
      If _IsExFlag_(ExStyleFlag, #WS_EX_WINDOWEDGE)   ;Ok
        Constants = ReplaceString(Constants, "ScrollArea_Raised", "ScrollArea_Raised(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #WS_BORDER)   ;Ok
        Constants = ReplaceString(Constants, "ScrollArea_Flat", "ScrollArea_Flat(x))", #PB_String_NoCase)
      EndIf
      If _IsExFlag_(ExStyleFlag, #WS_EX_STATICEDGE)   ;Ok
        Constants = ReplaceString(Constants, "ScrollArea_Single", "ScrollArea_Single(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE))   ;Ok
        Constants = ReplaceString(Constants, "ScrollArea_BorderLess", "ScrollArea_BorderLess(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "ScrollArea_Center", "ScrollArea_Center(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_ScrollBar   ;Ok
      If _IsFlag_(StyleFlag, #SBS_VERT)   ;Ok
        Constants = ReplaceString(Constants, "ScrollBar_Vertical", "ScrollBar_Vertical(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_Spin
      If _IsFlag_(StyleFlag, #ES_READONLY)   ;Ok
        Constants = ReplaceString(Constants, "Spin_ReadOnly", "Spin_ReadOnly(x))", #PB_String_NoCase)
      EndIf
      ;Not Ok Constants = ReplaceString(Constants, "Spin_Numeric", "Spin_Numeric(x))", #PB_String_NoCase)
      If _IsFlag_(StyleFlag, #ES_NUMBER)
        Constants = ReplaceString(Constants, "_#ES_Number", "_#ES_Number(x)", #PB_String_NoCase)
      EndIf
      
      ; Case #PB_GadgetType_Splitter   ;Not Ok
      ;Not Ok Constants = ReplaceString(Constants, "Splitter_Vertical", "Splitter_Vertical(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Splitter_Separator", "Splitter_Separator(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Splitter_FirstFixed", "Splitter_FirstFixed(x))", #PB_String_NoCase)
      ;Not Ok Constants = ReplaceString(Constants, "Splitter_SecondFixed", "Splitter_SecondFixed(x))", #PB_String_NoCase)
      
    Case #PB_GadgetType_String
      If _IsFlag_(StyleFlag, #ES_PASSWORD)   ;Ok
        Constants = ReplaceString(Constants, "String_Password", "String_Password(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_READONLY)   ;Ok
        Constants = ReplaceString(Constants, "String_ReadOnly", "String_ReadOnly(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_NUMBER)    ;Ok
        Constants = ReplaceString(Constants, "String_Numeric", "String_Numeric(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_LOWERCASE)  ;Ok
        Constants = ReplaceString(Constants, "String_LowerCase", "String_LowerCase(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_UPPERCASE)  ;Ok
        Constants = ReplaceString(Constants, "String_UpperCase", "String_UpperCase(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_CENTER)
        Constants = ReplaceString(Constants, "#ES_Center", "#ES_Center(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_MULTILINE)
        Constants = ReplaceString(Constants, "#ES_MultiLine", "#ES_MultiLine(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_NOHIDESEL)
        Constants = ReplaceString(Constants, "#ES_NoHideSel", "#ES_NoHideSel(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_RIGHT)
        Constants = ReplaceString(Constants, "#ES_Right", "#ES_Right(x)", #PB_String_NoCase)
      EndIf
      If Not(_IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE)) ;Ok
        Constants = ReplaceString(Constants, "String_BorderLess", "String_BorderLess(x))", #PB_String_NoCase)
      EndIf 
      
    Case #PB_GadgetType_Text   ;Ok
      If _IsFlag_(StyleFlag, #ES_CENTER)   ;Ok
        Constants = ReplaceString(Constants, "Text_Center", "Text_Center(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #ES_RIGHT)   ;Ok
        Constants = ReplaceString(Constants, "Text_Right", "Text_Right(x))", #PB_String_NoCase)
      EndIf
      If _IsExFlag_(ExStyleFlag, #WS_EX_CLIENTEDGE)   ;Ok
        Constants = ReplaceString(Constants, "Text_Border", "Text_Border(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #SS_ENDELLIPSIS)
        Constants = ReplaceString(Constants, "#SS_EndEllipsis", "#SS_EndEllipsis(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #SS_PATHELLIPSIS)
        Constants = ReplaceString(Constants, "#SS_PathEllipsis", "#SS_PathEllipsis(x)", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #SS_WORDELLIPSIS)
        Constants = ReplaceString(Constants, "#SS_WordEllipsis", "#SS_WordEllipsis(x)", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_TrackBar   ;Ok
      If _IsFlag_(StyleFlag, #TBS_AUTOTICKS)   ;Ok
        Constants = ReplaceString(Constants, "TrackBar_Ticks", "TrackBar_Ticks(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #TBS_VERT)   ;Ok
        Constants = ReplaceString(Constants, "TrackBar_Vertical", "TrackBar_Vertical(x))", #PB_String_NoCase)
      EndIf
      
    Case #PB_GadgetType_Tree
      If _IsFlag_(StyleFlag, #TVS_SHOWSELALWAYS)   ;Ok
        Constants = ReplaceString(Constants, "Tree_AlwaysShowSelection", "Tree_AlwaysShowSelection(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #TVS_HASLINES))   ;Ok
        Constants = ReplaceString(Constants, "Tree_NoLines", "Tree_NoLines(x))", #PB_String_NoCase)
      EndIf
      If Not(_IsFlag_(StyleFlag, #TVS_HASBUTTONS))   ;Ok
        Constants = ReplaceString(Constants, "Tree_NoButtons", "Tree_NoButtons(x))", #PB_String_NoCase)
      EndIf
      If _IsFlag_(StyleFlag, #TVS_CHECKBOXES)   ;Ok
        Constants = ReplaceString(Constants, "Tree_CheckBoxes", "Tree_CheckBoxes(x))", #PB_String_NoCase)
      EndIf
      ;Not OK Constants = ReplaceString(Constants, "Tree_ThreeState", "Tree_ThreeState(x))", #PB_String_NoCase)
      
  EndSelect
  
  ProcedureReturn Constants
EndProcedure

Procedure AddGadgetPB(Gadget)
  Protected *LoadPB.LoadPBStruct, Color
  _ProcedureReturnIf_(ObjectPB()\Object <> Gadget)
  
  *LoadPB = AddElement(LoadPB())
  If *LoadPB <> 0
    With *LoadPB
      \Level             = ObjectPB()\Level
      ; For Tabs the Gadget number must be between 50000 and 50999
      ; For the others, used the GadgetID to be Unique (Gadget=0, Parent= 2 vs OpenWindow Gadget=2, Parent=0 with an infinite loop in LoadGadget)
      If Gadget >= 50000 And Gadget < 60000
        \Gadget          = Gadget
      Else
        \Gadget          = ObjectPB()\ObjectID
      EndIf
      \Container         = ObjectPB()\IsContainer
      ; If Level = 1, the main level, ParentGadget=2 the Window
      ; If the Parent is a tab, the ParentGadget number must be between 50000 and 50999 Else used the ParentGadgetID to be Unique. The same as for Gadgets but for Parents 
      If \Level = 1
        \ParentGadget  = 2
      ElseIf ObjectPB()\ParentObject >= 50000 And ObjectPB()\ParentObject < 60000
        \ParentGadget    = ObjectPB()\ParentObject
      Else
        \ParentGadget    = ObjectPB()\ParentObjectID
      EndIf
      
      \LockLeft          = #True
      \LockTop           = #True
      
      If FindMapElement(ModelObject(), Str(ObjectPB()\Type))
        If ObjectPB()\Type = #PB_GadgetType_Canvas And ObjectPB()\IsContainer
          \Model = "CanvasContainerGadget"
          CompilerIf #UseShortNames
            \Name        = "#CanvCont_" + Str(ModelObject()\CountGadget)
          CompilerElse
            \Name        = "#CanvasContainer_" + Str(ModelObject()\CountGadget)
          CompilerEndIf
        Else
          \Model = ModelObject()\Model
          CompilerIf #RenameControlNames
            Select ObjectPB()\Type
              Case #PB_GadgetType_Button, #PB_GadgetType_CheckBox, #PB_GadgetType_Option
                CompilerIf #UseShortNames
                  \Name  = UniquePBName("#" + ModelObject()\ShortName, GetGadgetText(Gadget))
                CompilerElse
                  \Name  = UniquePBName("#" + ModelObject()\Name, GetGadgetText(Gadget))
                CompilerEndIf
              Default
                CompilerIf #UseShortNames
                  \Name  = "#" + ModelObject()\ShortName + "_" + Str(ModelObject()\CountGadget)
                CompilerElse
                  \Name  = "#" + ModelObject()\Name + "_" + Str(ModelObject()\CountGadget)
                CompilerEndIf
                ModelObject()\CountGadget + 1
            EndSelect
          CompilerElse
            CompilerIf #UseShortNames
              \Name      = "#" + ModelObject()\ShortName + "_" + Str(ModelObject()\CountGadget)
            CompilerElse
              \Name      = "#" + ModelObject()\Name + "_" + Str(ModelObject()\CountGadget)
            CompilerEndIf
            ModelObject()\CountGadget + 1
          CompilerEndIf
        EndIf
        
        If Gadget >= 50000 And Gadget < 60000
          \Type          = #PB_GadgetType_Panel
          \TabIndex      = Gadget - 50000
        Else
          \Type          = ObjectPB()\Type
          If \ParentGadget >= 50000 And \ParentGadget < 60000
            \TabIndex    = \ParentGadget - 50000
          Else
            \TabIndex    = #PB_Ignore
          EndIf
          \X             = ObjectPB()\X        ;GadgetX(Gadget)        
          \Y             = ObjectPB()\Y        ;GadgetY(Gadget)      
          \Width         = ObjectPB()\Width    ;GadgetWidth(Gadget)      
          \Height        = ObjectPB()\Height   ;GadgetHeight(Gadget)
          CompilerIf #SetDisabledFlag
            \Disable     = IsWindowEnabled_(ObjectPB()\ObjectID) ! 1
          CompilerEndIf
          CompilerIf #SetHiddenFlag
            \Hide        = IsWindowVisible_(ObjectPB()\ObjectID) ! 1
          CompilerEndIf
        EndIf
        
        \Caption         = ModelObject()\Caption
        \Option1         = ModelObject()\Option1
        \Option2         = ModelObject()\Option2
        \Option3         = ModelObject()\Option3
        \FontText        = ModelObject()\FontText
        
        ; --------------------|---------------------|------------|-----------|-------------|
        ; Model               | Caption             | Option1    | Option2   | Option3     |
        ; ButtonGadget        | #Text               |            |           |             |
        ; ButtonImageGadget   |                     | #Imag:0    |           |             |
        ; CalendarGadget      |                     | #Date:0    |           |             |
        ; CheckBoxGadget      | #Text               |            |           |             |
        ; ComboBoxGadget      | #Elem               |            |           |             |
        ; DateGadget          | #Date:%yyyy-%mm-%dd | #Date:0    |           |             |
        ; ExplorerComboGadget | #Dir$               |            |           |             |
        ; ExplorerListGadget  | #Dir$               |            |           |             |
        ; ExplorerTreeGadget  | #Dir$               |            |           |             |
        ; FrameGadget         | #Text               |            |           |             |
        ; HyperLinkGadget     | #Url$:https://www.purebasic.com/ | #Hard:RGB(0,0,128)|  |  |
        ; ImageGadget         |                     | #Imag:0    |           |             |
        ; ListIconGadget      | #Text               |            | #Widh:120 |             |
        ; OptionGadget        | #Text               |            |           |             |
        ; ProgressBarGadget   |                     | #Mini:0    | #Maxi:100 |             |
        ; ScintillaGadget     |                     | #Hard:0    |           |             |
        ; ScrollAreaGadget    |                     | #InrW:1200 | #InrH:800 | #Step:10    |
        ; ScrollBarGadget     |                     | #Mini:0    | #Maxi:100 | #Step:10    |
        ; SpinGadget          |                     | #Mini:0    | #Maxi:100 |             | 
        ; StringGadget        | #Text               |            |           |             |
        ; TextGadget          | #Text               |            |           |             |
        ; TrackBarGadget      |                     | #Mini:0    | #Maxi:100 |             |
        ; WebGadget           | #Url$:about:blank   |            |           |             |
        ; --------------------|---------------------|------------|-----------|-------------|
        
        Select Left(\Caption, 5)
          Case "#Text"             
            Select \Model
              Case "ListIconGadget"
                \Caption = "#Text:" + GetGadgetItemText(Gadget, -1, 0)
              Default   ; For ButtonGadget, CheckBoxGadget, OptionGadget, StringGadget, TextGadget, JellyButton
                \Caption = "#Text:" + GetGadgetText(Gadget)
            EndSelect
          Case "#Date"             ; Default value yet.
          Case "#Dir$"             ; Default value yet. For ExplorerComboGadget, ExplorerListGadget, ExplorerTreeGadget 
          Case "#Url$"             ; Default value yet. For HyperLinkGadget, WebGadget
          Case "#TabN"
            \Caption     = "#TabN:" + GetGadgetItemText(ObjectPB()\ParentObject, ObjectPB()\GParentObjectID)
        EndSelect        
        
        Select Left(\Option1, 5)
          Case "#Mini"
            Select \Model
              Case "ProgressBarGadget"
                \Option1 = "#Mini:" + Str(GetGadgetAttribute(Gadget, #PB_ProgressBar_Minimum))
              Case "ScrollBarGadget"
                \Option1 = "#Mini:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollBar_Minimum))
              Case "SpinGadget"
                \Option1 = "#Mini:" + Str(GetGadgetAttribute(Gadget, #PB_Spin_Minimum))
              Case "TrackBarGadget"
                \Option1 = "#Mini:" + Str(GetGadgetAttribute(Gadget, #PB_TrackBar_Minimum))
            EndSelect
          Case "#InrW"
            \Option1 = "#InrW:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollArea_InnerWidth))
            ;Case "#Hard"   ; Default value yet. To see HyperLinkGadget, ScintillaGadget
            ;Case "#Date"   ; Default value yet. To see CalendarGadget, Date Gadget
            ;Case "#Imag"   ; Default value yet. The images are not retrieved yet. to see ImageGadget, ButtonImageGadget GetGadgetAttribute()
        EndSelect
        
        Select Left(\Option2, 5)
          Case "#Maxi"
            Select \Model
              Case "ProgressBarGadget"
                \Option2 = "#Maxi:" + Str(GetGadgetAttribute(Gadget, #PB_ProgressBar_Maximum))
              Case "ScrollBarGadget"
                \Option2 = "#Maxi:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollBar_Maximum))
              Case "SpinGadget"
                \Option2 = "#Maxi:" + Str(GetGadgetAttribute(Gadget, #PB_Spin_Maximum))
              Case "TrackBarGadget"
                \Option2 = "#Maxi:" + Str(GetGadgetAttribute(Gadget, #PB_TrackBar_Maximum))
            EndSelect
          Case "#InrH"
            \Option2     = "#InrH:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollArea_InnerHeight))
          Case "#Widh"
            \Option2     = "#Widh:" + Str(GetGadgetItemAttribute(Gadget, 0, #PB_ListIcon_ColumnWidth, 0))
        EndSelect
        
        Select Left(\Option3, 5)
          Case "#Step"   ;For ScrollAreaGadget, ScrollBarGadget: Page length
            Select \Model
              Case "ScrollAreaGadget"
                \Option3 = "#Step:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollArea_ScrollStep))
              Case "ScrollBarGadget"
                \Option3 = "#Step:" + Str(GetGadgetAttribute(Gadget, #PB_ScrollBar_PageLength))
            EndSelect
        EndSelect
        
        \FrontColor = ModelObject()\FrontColor
        If \FrontColor <> "#Nooo"
          Color          = GetGadgetColor(Gadget, #PB_Gadget_FrontColor)
          If Color <> #PB_Default
            If (Color = 0 And \Type = #PB_GadgetType_HyperLink) Or (Color = 4294967295 And \Type = #PB_GadgetType_ExplorerTree)
              \FrontColor = ""   ; Specific HyperLink and ExplorerTree Gadget default color (without SetGadgetColor) <> #PB_Default. Is this a bug!
            Else
              \FrontColor = _HexColor_(Color)
            EndIf
          EndIf
        EndIf
        
        \BackColor = ModelObject()\BackColor
        If \BackColor <> "#Nooo"
          Color          = GetGadgetColor(Gadget, #PB_Gadget_BackColor)
          If Color <> #PB_Default
            If Color = #White And \Type = #PB_GadgetType_Tree
              \BackColor = ""   ; Specific Tree Gadget default color (without SetGadgetColor) <> #PB_Default. Is this a bug!
            Else
              \BackColor = _HexColor_(Color)
            EndIf
          EndIf
        EndIf
        
        \ToolTip         = ModelObject()\ToolTip
        If \ToolTip <> "#Nooo"
          \ToolTip = GetToolTipText(Gadget)
        EndIf
        
        \BindGadget      = ModelObject()\BindGadget
        \Constants       = AddGadgetPBFlag(Gadget, ModelObject()\Constants)
        \Key             = RSet(Str(\Level),2, "0") + RSet(Str(\TabIndex), 6, "0") + RSet(Str(\Y), 5, "0") + RSet(Str(\X), 5, "0")
        
        CompilerIf #DebugON
          Debug LSet("", \Level * 4 , " ") + \Model + "(" + \Name + ", " + Str(\X) + ", " + Str(\Y) + ", " + Str(\Width) + ", " + Str(\Height) + ", " +
                #DQUOTE$+ Mid(\Caption, 7) +#DQUOTE$+ ", " + \Option1 + ", " + \Option2 + ", " + \Option3 + ", " + \Constants + ")"
          If Left(\BackColor, 5) <> "#Nooo" And \BackColor <> "" : Debug LSet("", \Level * 4 , " ") + "SetGadgetColor(" + \Name + ", #PB_Gadget_BackColor, " + \BackColor + ")" : EndIf
          If Left(\FrontColor, 5) <> "#Nooo" And \FrontColor <> "" : Debug LSet("", \Level * 4 , " ") + "SetGadgetColor(" + \Name + ", #PB_Gadget_FrontColor, " + \FrontColor + ")" : EndIf
          If Left(\ToolTip, 5) <> "#Nooo" And \ToolTip <> "" : Debug LSet("", \Level * 4 , " ") + "GadgetToolTip(" + \Name + ", " +#DQUOTE$+ \ToolTip +#DQUOTE$+ ")": EndIf
        CompilerEndIf
        
      EndIf
    EndWith
  EndIf   ; If *LoadPB <> 0
  
EndProcedure

Procedure AddWinLoadPB(ParentObject, FirstPassDone = #False)
  Static Level
  Protected *LoadPB.LoadPBStruct, ReturnVal
  
  If FirstPassDone = 0
    _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
    If IsWindow(ParentObject)
      Level     = 0
      AddWindowPB(ParentObject)
    Else
      ProcedureReturn #PB_Default
    EndIf
    FirstPassDone = #True
  EndIf
  
  Level + 1
  PushListPosition(ObjectPB())
  ResetList(ObjectPB())
  While NextElement(ObjectPB())
    If ObjectPB()\Level = Level And ObjectPB()\ParentObject = ParentObject
      AddGadgetPB(ObjectPB()\Object)
      If ObjectPB()\IsContainer
        AddWinLoadPB(ObjectPB()\Object, FirstPassDone)
        Level - 1
      EndIf
    EndIf
  Wend
  PopListPosition(ObjectPB())
  
EndProcedure

Procedure SaveIceDesignForm(Window)
  _ProcedureReturnIf_(IsWindow(Window) = 0)
  _ProcedureReturnIf_(ListSize(LoadPB()) = 0)
  Protected Title.s, FilePath.s, JSONFile, ReturnVal, ReturnRequester = #PB_MessageRequester_Yes
  
  SortStructuredList(LoadPB(), #PB_Sort_Ascending, OffsetOf(LoadPBStruct\Key), TypeOf(LoadPBStruct\Key))
  
  Title = GetWindowTitle(Window)
  If Title
    FilePath = GetCurrentDirectory() + Title + ".icef"
  Else
    FilePath = GetCurrentDirectory() + "PBForm2IceDesign.icef"
  EndIf
  
  FilePath = SaveFileRequester("Save IceDesign Form. Window : " +#DQUOTE$+ Title +#DQUOTE$, FilePath, "IceDesign Form (*.icef)|*.icef", 0)
  If FilePath And GetExtensionPart(FilePath) <> "icef" : FilePath + ".icef" :EndIf
  If FilePath
    If FileSize(FilePath) > 0
      ReturnRequester = MessageRequester("Confirm", #DQUOTE$ + GetFilePart(FilePath) + #DQUOTE$ + " already exists." +#CRLF$+#CRLF$+ "Do you want To replace it ?", #PB_MessageRequester_YesNo)
    EndIf
    If ReturnRequester = #PB_MessageRequester_Yes
      JSONFile = CreateJSON(#PB_Any)
      If JSONFile
        InsertJSONList(JSONValue(JSONFile), LoadPB())
        CompilerIf Defined(JSave::Save, #PB_Procedure)
          JSave::InitObjectStr("", "Level, Gadget, Model, Type, Name, Container, ParentGadget, TabIndex, X, Y, Width, Height, Group, Caption, Option1, Option2, Option3, FontText, FrontColor, BackColor, Lock, Disable, Hide, BindGadget, ToolTip, LockLeft, LockRight, LockTop, LockBottom, ProportionalSize, Constants, Key")
          If Not JSave::Save(JSONFile, FilePath)  
            MessageRequester("Warning", "There was an error saving IceDesign Form GUI (*.icef) file", #PB_MessageRequester_Warning|#PB_MessageRequester_Ok)  
          EndIf
        CompilerElse
          SaveJSON(JSONFile, FilePath, #PB_JSON_PrettyPrint)
        CompilerEndIf
        FreeJSON(JSONFile)
        ReturnVal = #True
      EndIf
    EndIf
  EndIf
  ClearList(LoadPB())
  
  ProcedureReturn ReturnVal
EndProcedure

Procedure AddLoadPB(Window = #PB_All)
  _ProcedureReturnIf_(ListSize(ObjectPB()) = 0, #PB_Default)
  Protected ReturnVal, I
  
  If Window = #PB_All
    For I = 0 To CountWindow - 1
      ResetList(LoadPB())
      AddWinLoadPB(Window(0, I))
      SaveIceDesignForm(Window(0, I))
      CompilerIf #DebugON : Debug "" : CompilerEndIf
    Next
  Else
    For I = 0 To CountWindow - 1
      If Window(0, I) = Window
        AddWinLoadPB(Window)
        SaveIceDesignForm(Window)
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn ReturnVal
EndProcedure

; ----- End Private LoadPB -----
;
;- ----- Public Function -----

Procedure PBForm2IceDesign(Window = #PB_All)
  ClearMap(ModelObject()) : ClearList(ObjectPB()) : ClearList(LoadPB())
  LoadModelObject()
  LoadObjectPB()
  CompilerIf #DebugON : EnumChildPB(Window) : CompilerEndIf
  AddLoadPB(Window)
  ClearMap(ModelObject()) : ClearList(ObjectPB()) : ClearList(LoadPB())
EndProcedure

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; Folding = ----------
; EnableXP