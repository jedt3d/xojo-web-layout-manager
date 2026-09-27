#tag Class
Protected Class DSFlexConfig
	#tag Note, Name = About
		Input of DSFlexEngine.Arrange (Clinic DS spec §8.4). Sizes in pixels.
	#tag EndNote

	#tag Property, Flags = &h0
		CrossAxisAlignment As DSLayout.CrossAxisAlignment = DSLayout.CrossAxisAlignment.Center
	#tag EndProperty

	#tag Property, Flags = &h0
		Direction As DSLayout.Direction = DSLayout.Direction.Horizontal
	#tag EndProperty

	#tag Property, Flags = &h0
		Height As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MainAxisAlignment As DSLayout.MainAxisAlignment = DSLayout.MainAxisAlignment.Start
	#tag EndProperty

	#tag Property, Flags = &h0
		PadBottom As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PadLeft As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PadRight As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PadTop As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Spacing As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Width As Integer
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
