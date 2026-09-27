#tag Class
Protected Class DSFlexEngine
	#tag Method, Flags = &h0
		Shared Function Arrange(cfg As DSFlexConfig, items() As DSFlexItem) As DSFlexResult
		  // Clinic DS spec §8.5 steps 1 and 3 to 11. Pure math: no controls, no windows.
		  // Reference implementation and test vectors: Clinic UI Design/tools/reference/flex_engine.py, tests/vectors.yaml
		  Var res As New DSFlexResult
		  Var isRow As Boolean = (cfg.Direction = DSLayout.Direction.Horizontal)
		  
		  // Step 1
		  Var contentW As Integer = Max(0, cfg.Width - cfg.PadLeft - cfg.PadRight)
		  Var contentH As Integer = Max(0, cfg.Height - cfg.PadTop - cfg.PadBottom)
		  Var contentMain, contentCross, mainStart, crossStart As Integer
		  If isRow Then
		    contentMain = contentW
		    contentCross = contentH
		    mainStart = cfg.PadLeft
		    crossStart = cfg.PadTop
		  Else
		    contentMain = contentH
		    contentCross = contentW
		    mainStart = cfg.PadTop
		    crossStart = cfg.PadLeft
		  End If
		  Var n As Integer = items.Count
		  
		  // Steps 3 and 4
		  Var intrinsic() As Double
		  Var fixedSum As Double = 0
		  Var totalFlex As Integer = 0
		  For i As Integer = 0 To n - 1
		    Var s As Double = ClampMain(items(i).IntrinsicMain, items(i).MinMain, items(i).MaxMain)
		    intrinsic.Add(s)
		    If items(i).Factor = 0 Then fixedSum = fixedSum + s
		    totalFlex = totalFlex + items(i).Factor
		  Next
		  Var gaps As Integer = cfg.Spacing * Max(n - 1, 0)
		  
		  // Step 5
		  Var remaining As Double = contentMain - fixedSum - gaps
		  Var unit As Double = 0
		  If totalFlex > 0 Then unit = Max(remaining, 0) / totalFlex
		  
		  // Step 6
		  Var sizes() As Double
		  Var used As Double = gaps
		  For i As Integer = 0 To n - 1
		    Var size As Double
		    If items(i).Factor > 0 Then
		      Var allotted As Double = unit * items(i).Factor
		      If items(i).Fit = DSLayout.FlexFit.Tight Then
		        size = allotted
		      Else
		        size = Min(intrinsic(i), allotted)
		      End If
		      size = ClampMain(size, items(i).MinMain, items(i).MaxMain)
		    Else
		      size = intrinsic(i)
		    End If
		    sizes.Add(size)
		    used = used + size
		  Next
		  
		  // Step 7
		  Var free As Double = Max(contentMain - used, 0)
		  res.Overflow = (used - contentMain) > 0.5
		  res.UsedMain = used
		  
		  // Step 8
		  Var lead As Double = 0
		  Var between As Double = cfg.Spacing
		  Select Case cfg.MainAxisAlignment
		  Case DSLayout.MainAxisAlignment.Start
		    lead = 0
		  Case DSLayout.MainAxisAlignment.End_
		    lead = free
		  Case DSLayout.MainAxisAlignment.Center
		    lead = free / 2
		  Case DSLayout.MainAxisAlignment.SpaceBetween
		    lead = 0
		    If n > 1 Then between = cfg.Spacing + free / (n - 1)
		  Case DSLayout.MainAxisAlignment.SpaceAround
		    If n > 0 Then
		      lead = free / (2 * n)
		      between = cfg.Spacing + free / n
		    End If
		  Case DSLayout.MainAxisAlignment.SpaceEvenly
		    lead = free / (n + 1)
		    between = cfg.Spacing + free / (n + 1)
		  End Select
		  
		  // Steps 9, 10 and 11
		  Var pos As Double = mainStart + lead
		  For i As Integer = 0 To n - 1
		    Var startPos As Double = pos
		    Var endPos As Double = pos + sizes(i)
		    Var l As Integer = Floor(startPos + 0.5)
		    Var r As Integer = Floor(endPos + 0.5)
		    Var mainSize As Integer = Max(r - l, 0)
		    pos = endPos + between
		    
		    Var crossSize As Integer
		    If cfg.CrossAxisAlignment = DSLayout.CrossAxisAlignment.Stretch Then
		      crossSize = contentCross
		    Else
		      crossSize = Min(items(i).IntrinsicCross, contentCross)
		    End If
		    Var crossPos As Integer
		    Select Case cfg.CrossAxisAlignment
		    Case DSLayout.CrossAxisAlignment.Start, DSLayout.CrossAxisAlignment.Stretch
		      crossPos = crossStart
		    Case DSLayout.CrossAxisAlignment.End_
		      crossPos = crossStart + contentCross - crossSize
		    Case DSLayout.CrossAxisAlignment.Center
		      crossPos = crossStart + Floor((contentCross - crossSize) / 2 + 0.5)
		    End Select
		    
		    If isRow Then
		      res.Lefts.Add(l)
		      res.Widths.Add(mainSize)
		      res.Tops.Add(crossPos)
		      res.Heights.Add(crossSize)
		    Else
		      res.Tops.Add(l)
		      res.Heights.Add(mainSize)
		      res.Lefts.Add(crossPos)
		      res.Widths.Add(crossSize)
		    End If
		  Next
		  Return res
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ClampMain(size As Double, minMain As Integer, maxMain As Integer) As Double
		  // §8.5 steps 3 and 6: a 0 bound is ignored; the minimum is applied last so it wins.
		  If maxMain > 0 And size > maxMain Then size = maxMain
		  If minMain > 0 And size < minMain Then size = minMain
		  Return size
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function IntrinsicCross(cfg As DSFlexConfig, items() As DSFlexItem) As Integer
		  // §8.7: padding on the cross axis + the largest IntrinsicCross (0 items: padding only).
		  Var pad As Integer
		  If cfg.Direction = DSLayout.Direction.Horizontal Then
		    pad = cfg.PadTop + cfg.PadBottom
		  Else
		    pad = cfg.PadLeft + cfg.PadRight
		  End If
		  Var biggest As Integer = 0
		  For Each it As DSFlexItem In items
		    If it.IntrinsicCross > biggest Then biggest = it.IntrinsicCross
		  Next
		  Return pad + biggest
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function IntrinsicMain(cfg As DSFlexConfig, items() As DSFlexItem) As Integer
		  // §8.7: padding on the main axis + Σ IntrinsicMain (clamped as in step 3) + gaps.
		  Var pad As Integer
		  If cfg.Direction = DSLayout.Direction.Horizontal Then
		    pad = cfg.PadLeft + cfg.PadRight
		  Else
		    pad = cfg.PadTop + cfg.PadBottom
		  End If
		  Var total As Double = 0
		  For Each it As DSFlexItem In items
		    total = total + ClampMain(it.IntrinsicMain, it.MinMain, it.MaxMain)
		  Next
		  Return Ceiling(pad + total + cfg.Spacing * Max(items.Count - 1, 0))
		End Function
	#tag EndMethod


	#tag Note, Name = About
		Pure layout math of Clinic DS (spec §8.4, §8.5, §8.7), shared by DesktopFlexLayoutManager and WebFlexLayoutManager.
		Generated from the Python oracle; the 16 V-LAY vectors are in Clinic UI Design/tests/vectors.yaml.
	#tag EndNote


	#tag ViewBehavior
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
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
