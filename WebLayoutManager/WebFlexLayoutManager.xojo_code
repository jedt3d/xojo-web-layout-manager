#tag Class
Protected Class WebFlexLayoutManager
Inherits WebRectangle
	#tag Event
		Sub Resized()
		  ApplyLayout()
		End Sub
	#tag EndEvent

	#tag Event
		Sub Shown()
		  Me.ExecuteJavaScript("setTimeout(function(){ window.dispatchEvent(new Event('resize')); }, 50);")
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0, Description = 41646473206120636F6E74726F6C2E2067726F77466163746F722030202864656661756C7429206B65657073206974732073697A65206F6E20746865206D61696E20617869733B203E20302074616B65732061207368617265206F6620746865206C6566746F7665722073706163652028313A323A33203D20312F362C20322F362C20332F362920616E6420697473206F776E2077696474682028526F7729206F72206865696768742028436F6C756D6E292069732069676E6F7265642E
		Sub AddControl(c As WebUIControl, growFactor As Double = 0)
		  If c = Nil Then Return

		  System.DebugLog("FlexLayoutManager: Adding control " + c.Name + " with growFactor " + Str(growFactor))

		  ManagedControls.Add(c)
		  FlexGrowMap.Value(c) = growFactor
		  BasisWidthMap.Value(c) = c.Width
		  BasisHeightMap.Value(c) = c.Height

		  ApplyLayout()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ApplyLayout()
		  // Collects the visible managed controls, maps this manager's settings to DSFlexEngine
		  // (the shared layout math, DSCore/DSFlexEngine.xojo_code) and applies the result.
		  // Same engine as DesktopFlexLayoutManager, so Web and Desktop lay out identically.
		  If ManagedControls.LastIndex < 0 Then Return
		  
		  Var visibleControls() As WebUIControl
		  For Each c As WebUIControl In ManagedControls
		    If c.Visible Then visibleControls.Add(c)
		  Next
		  If visibleControls.LastIndex < 0 Then Return
		  
		  Var isRow As Boolean = (Direction = FlexDirection.Row)
		  Var cfg As New DSFlexConfig
		  cfg.Direction = If(isRow, DSLayout.Direction.Horizontal, DSLayout.Direction.Vertical)
		  cfg.Spacing = Gap
		  cfg.PadTop = PaddingTop
		  cfg.PadRight = PaddingRight
		  cfg.PadBottom = PaddingBottom
		  cfg.PadLeft = PaddingLeft
		  cfg.Width = Me.Width
		  cfg.Height = Me.Height
		  
		  Select Case MainAxisAlignment
		  Case JustifyContent.FlexEnd
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.End_
		  Case JustifyContent.Center
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.Center
		  Case JustifyContent.SpaceBetween
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.SpaceBetween
		  Case JustifyContent.SpaceAround
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.SpaceAround
		  Case JustifyContent.SpaceEvenly
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.SpaceEvenly
		  Else // FlexStart, and Stretch (handled below with flex factors)
		    cfg.MainAxisAlignment = DSLayout.MainAxisAlignment.Start
		  End Select
		  
		  Select Case CrossAxisAlignment
		  Case AlignItems.FlexEnd
		    cfg.CrossAxisAlignment = DSLayout.CrossAxisAlignment.End_
		  Case AlignItems.Center
		    cfg.CrossAxisAlignment = DSLayout.CrossAxisAlignment.Center
		  Case AlignItems.Stretch
		    cfg.CrossAxisAlignment = DSLayout.CrossAxisAlignment.Stretch
		  Else
		    cfg.CrossAxisAlignment = DSLayout.CrossAxisAlignment.Start
		  End Select
		  
		  // Intrinsic sizes come from the basis maps (sizes captured by AddControl), never from the
		  // current size: a previous pass may have grown or stretched the control (fix ba2b05e).
		  Var items() As DSFlexItem
		  Var anyGrow As Boolean = False
		  For Each c As WebUIControl In visibleControls
		    Var basisW As Integer = BasisWidthMap.Lookup(c, c.Width).IntegerValue
		    Var basisH As Integer = BasisHeightMap.Lookup(c, c.Height).IntegerValue
		    Var it As New DSFlexItem
		    it.IntrinsicMain = If(isRow, basisW, basisH)
		    it.IntrinsicCross = If(isRow, basisH, basisW)
		    it.Factor = FactorFor(c)
		    If it.Factor > 0 Then anyGrow = True
		    items.Add(it)
		  Next
		  
		  // MainAxisAlignment = Stretch (equal sizes, only when nothing grows) = every item flex 1 Tight.
		  If MainAxisAlignment = JustifyContent.Stretch And Not anyGrow Then
		    For Each it As DSFlexItem In items
		      it.Factor = 1
		    Next
		  End If
		  
		  Var res As DSFlexResult = DSFlexEngine.Arrange(cfg, items)
		  
		  // Web: children of a WebRectangle are positioned relative to it, so the engine's local
		  // results are used as they are. Assign only what changed (each change is sent to the browser).
		  For i As Integer = 0 To visibleControls.LastIndex
		    Var c As WebUIControl = visibleControls(i)
		    If c.Left <> res.Lefts(i) Then c.Left = res.Lefts(i)
		    If c.Top <> res.Tops(i) Then c.Top = res.Tops(i)
		    If c.Width <> res.Widths(i) Then c.Width = res.Widths(i)
		    If c.Height <> res.Heights(i) Then c.Height = res.Heights(i)
		  Next
		  
		  #If DebugBuild Then
		    If res.Overflow Then System.DebugLog("WebFlexLayoutManager " + Me.Name + ": content overflows by " + Str(res.UsedMain - If(isRow, Me.Width - PaddingLeft - PaddingRight, Me.Height - PaddingTop - PaddingBottom)) + " px")
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FactorFor(c As WebUIControl) As Integer
		  // Grow factors are Doubles in this class but Integers in DSFlexEngine. Scaling by 1000
		  // keeps the ratios of fractional factors (0.5 : 1.5 = 500 : 1500), so the space
		  // split is unchanged; the engine only uses the ratios.
		  If Not FlexGrowMap.HasKey(c) Then Return 0
		  Var g As Double = FlexGrowMap.Value(c).DoubleValue
		  If g <= 0 Then Return 0
		  Return Max(1, Floor(g * 1000 + 0.5))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.Constructor

		  FlexGrowMap = New Dictionary
		  BasisWidthMap = New Dictionary
		  BasisHeightMap = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveAllControls()
		  ManagedControls.RemoveAll()
		  FlexGrowMap.Clear()
		  BasisWidthMap.Clear()
		  BasisHeightMap.Clear()
		  ApplyLayout()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 4368616E676573207468652067726F7720666163746F723A2030203D206B656570206F776E2073697A65206F6E20746865206D61696E20617869733B203E2030203D207368617265206F6620746865206C6566746F7665722073706163652E
		Sub SetFlexGrow(c As WebUIControl, growFactor As Double)
		  If c = Nil Then Return
		  
		  If FlexGrowMap.HasKey(c) Then
		    FlexGrowMap.Value(c) = growFactor
		    System.DebugLog("FlexLayoutManager: SetFlexGrow for " + c.Name + " to " + Str(growFactor))
		    ApplyLayout()
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0, Description = 416C69676E6D656E74204143524F53532074686520646972656374696F6E202843535320616C69676E2D6974656D73292E20526F773A20766572746963616C202853747265746368203D2066756C6C20686569676874292E20436F6C756D6E3A20686F72697A6F6E74616C202853747265746368203D2066756C6C207769647468292E
		CrossAxisAlignment As AlignItems = AlignItems.FlexStart
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 446972656374696F6E206F6620746865206D61696E20617869733A20526F77203D206974656D73206C65667420746F2072696768742C20436F6C756D6E203D206974656D7320746F7020746F20626F74746F6D2E204D61696E41786973416C69676E6D656E7420776F726B7320616C6F6E672069742C2043726F737341786973416C69676E6D656E74206163726F73732069742E
		Direction As FlexDirection = FlexDirection.Row
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected BasisHeightMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected BasisWidthMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected FlexGrowMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 537061636520696E20706978656C73206265747765656E206E65696768626F7572696E672076697369626C6520636F6E74726F6C732C20616C6F6E6720746865206D61696E20617869732E
		Gap As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 416C69676E6D656E7420414C4F4E472074686520646972656374696F6E2028435353206A7573746966792D636F6E74656E74292E20526F773A20686F72697A6F6E74616C2E20436F6C756D6E3A20766572746963616C2E204E6F2076697369626C6520656666656374207768656E20657665727920636F6E74726F6C2068617320612067726F7720666163746F72203E20302028746865792074616B6520616C6C2066726565207370616365292E
		MainAxisAlignment As JustifyContent = JustifyContent.FlexStart
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ManagedControls() As WebUIControl
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingBottom As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingLeft As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingRight As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		PaddingTop As Integer = 0
	#tag EndProperty


	#tag Enum, Name = AlignItems, Type = Integer, Flags = &h0
		FlexStart = 0
		  FlexEnd = 1
		  Center = 2
		Stretch = 3
	#tag EndEnum

	#tag Enum, Name = FlexDirection, Type = Integer, Flags = &h0
		Row = 0
		Column = 1
	#tag EndEnum

	#tag Enum, Name = JustifyContent, Type = Integer, Flags = &h0
		FlexStart = 0
		  FlexEnd = 1
		  Center = 2
		  SpaceBetween = 3
		  SpaceAround = 4
		  Stretch = 5
		SpaceEvenly = 6
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mDesignHeight"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mDesignWidth"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000FF"
			Type="ColorGroup"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderThickness"
			Visible=true
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerSize"
			Visible=true
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FillColor"
			Visible=true
			Group="Behavior"
			InitialValue="&cFFFFFF"
			Type="ColorGroup"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasFillColor"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=false
			Group="Visual Controls"
			InitialValue=""
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Visual Controls"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LayoutType"
			Visible=true
			Group="WebView"
			InitialValue="LayoutTypes.Fixed"
			Type="LayoutTypes"
			EditorType="Enum"
			#tag EnumValues
				"0 - Fixed"
				"1 - Flex"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="LayoutDirection"
			Visible=true
			Group="WebView"
			InitialValue="LayoutDirections.LeftToRight"
			Type="LayoutDirections"
			EditorType="Enum"
			#tag EnumValues
				"0 - LeftToRight"
				"1 - RightToLeft"
				"2 - TopToBottom"
				"3 - BottomToTop"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Direction"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="FlexDirection"
			EditorType="Enum"
			#tag EnumValues
				"0 - Row"
				"1 - Column"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="MainAxisAlignment"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="JustifyContent"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart (Row: left / Column: top)"
				"1 - FlexEnd (Row: right / Column: bottom)"
				"2 - Center"
				"3 - SpaceBetween (ends touch, equal gaps)"
				"4 - SpaceAround (equal space around each)"
				"5 - Stretch (equal sizes, no grow)"
				"6 - SpaceEvenly (equal space everywhere)"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CrossAxisAlignment"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="AlignItems"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart (Row: top / Column: left)"
				"1 - FlexEnd (Row: bottom / Column: right)"
				"2 - Center"
				"3 - Stretch (Row: full height / Column: full width)"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Gap"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingLeft"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingTop"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingRight"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PaddingBottom"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
