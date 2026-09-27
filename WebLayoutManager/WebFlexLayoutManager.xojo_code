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


	#tag Method, Flags = &h0
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
		  
		  Select Case Justify
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
		  
		  Select Case Align
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
		  
		  // JustifyContent.Stretch (equal sizes, only when nothing grows) = every item flex 1 Tight.
		  If Justify = JustifyContent.Stretch And Not anyGrow Then
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

	#tag Method, Flags = &h0
		Sub SetFlexGrow(c As WebUIControl, growFactor As Double)
		  If c = Nil Then Return
		  
		  If FlexGrowMap.HasKey(c) Then
		    FlexGrowMap.Value(c) = growFactor
		    System.DebugLog("FlexLayoutManager: SetFlexGrow for " + c.Name + " to " + Str(growFactor))
		    ApplyLayout()
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Align As AlignItems = AlignItems.FlexStart
	#tag EndProperty

	#tag Property, Flags = &h0
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

	#tag Property, Flags = &h0
		Gap As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Justify As JustifyContent = JustifyContent.FlexStart
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
			Name="Justify"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="JustifyContent"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart"
				"1 - FlexEnd"
				"2 - Center"
				"3 - SpaceBetween"
				"4 - SpaceAround"
				"5 - Stretch"
				"6 - SpaceEvenly"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Align"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="AlignItems"
			EditorType="Enum"
			#tag EnumValues
				"0 - FlexStart"
				"1 - FlexEnd"
				"2 - Center"
				"3 - Stretch"
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
