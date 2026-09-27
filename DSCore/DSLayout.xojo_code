#tag Module
Protected Module DSLayout
	#tag Note, Name = About
		Layout enums of Clinic DS spec §8.2 used by DSFlexEngine (values fixed by the spec, R-NAM-02).
		MainAxisSize, SizeMode, TextAlign and SurfaceRole are not included yet (not used by the engine).
	#tag EndNote


	#tag Enum, Name = CrossAxisAlignment, Type = Integer, Flags = &h1
		Start = 0
		  End_ = 1
		  Center = 2
		Stretch = 3
	#tag EndEnum

	#tag Enum, Name = Direction, Type = Integer, Flags = &h1
		Horizontal = 0
		Vertical = 1
	#tag EndEnum

	#tag Enum, Name = FlexFit, Type = Integer, Flags = &h1
		Tight = 0
		Loose = 1
	#tag EndEnum

	#tag Enum, Name = MainAxisAlignment, Type = Integer, Flags = &h1
		Start = 0
		  End_ = 1
		  Center = 2
		  SpaceBetween = 3
		  SpaceAround = 4
		SpaceEvenly = 5
	#tag EndEnum


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
End Module
#tag EndModule
