@tool
extends Node3D

@onready var vehicle: Vehicle = $Vehicle
#@onready var vehicle2: Vehicle = $Vehicle2
#@onready var vehicle3: Vehicle = $Vehicle3
#@onready var vehicle4: Vehicle = $Vehicle4
@onready var network: TrackNetwork = $TrackNetwork


func _ready()->void:
	$Building.width_sections = 10
	$Building.length_sections = 7
	#var nodes:Array = network.get_all_nodes()
	#vehicle.start(nodes[0])
	#vehicle.move_to(nodes[1])
	#if !vehicle1.start($TrackNetwork/Entry):
		#print("Vehicle1 couldn't start.")
	#if !vehicle2.start($TrackNetwork/Entry):
		#print("Vehicle2 couldn't start.")
	vehicle.start($TrackNetwork/N1)
	#vehicle2.start($TrackNetwork/Entry)
	#vehicle3.start($TrackNetwork/Entry)
	#vehicle4.start($TrackNetwork/Entry)
