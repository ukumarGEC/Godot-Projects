@tool
class_name Factory
extends Node3D

@export var StartLoading := false
@export var faulty_alert :Sprite3D
@export var techinician :Technician

func _ready()->void:
	
	#Set Building dimension
	$Building.width_sections = 10
	$Building.length_sections = 7
	
	#Reset fault alert
	faulty_alert.visible = false
	
	#Start all vehicles
	var vehicles := $Vehicles.get_children()
	vehicles[0].start($TrackNetwork/LoadingZone/NL7)
	vehicles[1].start($TrackNetwork/LoadingZone/NL6)
	vehicles[2].start($TrackNetwork/LoadingZone/NL5)
	vehicles[3].start($TrackNetwork/LoadingZone/NL4)
	vehicles[4].start($TrackNetwork/LoadingZone/NL3)
	vehicles[5].start($TrackNetwork/LoadingZone/NL2)
	vehicles[6].start($TrackNetwork/LoadingZone/NL1)
	vehicles[7].start($TrackNetwork/LoadingZone/NL0)
	#vechicles[8].start($TrackNetwork/LoadingZone/NL0)
	#vechicles[9].start($TrackNetwork/LoadingZone/NL0)
	#$Vehicles/V1.start($TrackNetwork/N1)
	
	# Hide gear from pallets
	for vehicle in vehicles:
		#vehicle.start($TrackNetwork/NC1)
		if vehicle.name =="Technician":
			continue
		_update_gear(vehicle, false)

func  _process(delta: float) -> void:
	pass

func _update_gear(vehicle: Vehicle, isvisible:bool)-> void:
	var pallet := vehicle.find_child("Pallet")
	var gear :Node3D = pallet.find_child("gear3")
	gear.visible = isvisible
	
func start_Repair()->void:
	if techinician!= null:
		techinician.start($TrackNetwork/NTech1)
	pass
	
