@tool
extends Node3D

func _ready()->void:
	
	#Set Building dimension
	$Building.width_sections = 10
	$Building.length_sections = 7
	
	#Start all vehicles
	for v in $Vehicles.get_children():
		v.start($TrackNetwork/N1)
