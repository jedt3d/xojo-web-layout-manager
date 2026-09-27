#tag Class
Protected Class DSFlexItem
	#tag Note, Name = About
		One visible child for DSFlexEngine.Arrange (Clinic DS spec §8.4). 0 = none for MinMain / MaxMain; Factor 0 = not flexible.
	#tag EndNote

	#tag Property, Flags = &h0
		Factor As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Fit As DSLayout.FlexFit = DSLayout.FlexFit.Tight
	#tag EndProperty

	#tag Property, Flags = &h0
		IntrinsicCross As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IntrinsicMain As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MaxMain As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MinMain As Integer
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
