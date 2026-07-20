@tool
extends Node3D

func _ready()->void:
	
	#Set Building dimension
	$Building.width_sections = 10
	$Building.length_sections = 7
	
	#Start all vehicles
	var vechicles := $Vehicles.get_children()
	vechicles[0].start($TrackNetwork/NL7)
	vechicles[1].start($TrackNetwork/NL6)
	vechicles[2].start($TrackNetwork/NL5)
	vechicles[3].start($TrackNetwork/NL4)
	vechicles[4].start($TrackNetwork/NL3)
	vechicles[5].start($TrackNetwork/NL2)
	vechicles[6].start($TrackNetwork/NL1)
	vechicles[7].start($TrackNetwork/NL0)
	vechicles[8].start($TrackNetwork/NL0)
	vechicles[9].start($TrackNetwork/NL0)
	#$Vehicles/V1.start($TrackNetwork/N1)
