#tag Class
Protected Class DSFlexResult
	#tag Note, Name = About
		Output of DSFlexEngine.Arrange (Clinic DS spec §8.4): local rectangles in item order.
	#tag EndNote

	#tag Property, Flags = &h0
		Heights() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Lefts() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Overflow As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Tops() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		UsedMain As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Widths() As Integer
	#tag EndProperty

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
