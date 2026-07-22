@tool
class_name Factory
extends Node3D

func _ready()->void:
	
	#Set Building dimension
	$Building.width_sections = 10
	$Building.length_sections = 7
	
	#Start all vehicles
	var vechicles := $Vehicles.get_children()
	vechicles[0].start($TrackNetwork/LoadingZone/NL7)
	vechicles[1].start($TrackNetwork/LoadingZone/NL6)
	vechicles[2].start($TrackNetwork/LoadingZone/NL5)
	vechicles[3].start($TrackNetwork/LoadingZone/NL4)
	vechicles[4].start($TrackNetwork/LoadingZone/NL3)
	vechicles[5].start($TrackNetwork/LoadingZone/NL2)
	vechicles[6].start($TrackNetwork/LoadingZone/NL1)
	vechicles[7].start($TrackNetwork/LoadingZone/NL0)
	#vechicles[8].start($TrackNetwork/LoadingZone/NL0)
	#vechicles[9].start($TrackNetwork/LoadingZone/NL0)
	#$Vehicles/V1.start($TrackNetwork/N1)
	
	# Hide gear from pallets
	for vehicle in vechicles:
		_update_gear(vehicle, false)

func  _process(delta: float) -> void:
	pass
	

func _update_gear(vehicle: Vehicle, isvisible:bool)-> void:
	var pallet := vehicle.find_child("Pallet")
	var gear :Node3D = pallet.find_child("gear3")
	gear.visible = isvisible
