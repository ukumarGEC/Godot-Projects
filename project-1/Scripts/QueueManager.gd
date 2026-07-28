@tool
class_name QueueManager
extends Node

@onready var traffic : TrafficManager = $"../TrafficManager"

@onready var q6 : TrackNode = %Q6
@onready var q5 : TrackNode = %Q5
@onready var q4 : TrackNode = %Q4
@onready var q3 : TrackNode = %Q3
@onready var q2 : TrackNode = %Q2
@onready var q1 : TrackNode = %Q1

var queue_nodes : Array[TrackNode]

func _ready()-> void:

	queue_nodes = [
		q6,
		q5,
		q4,
		q3,
		q2,
		q1
	]

var queue_moving := false

func vehicle_entered_queue(vehicle:Vehicle)-> void:
	if queue_moving:
		return
	queue_moving = true
	await advance_queue(vehicle)
	queue_moving = false

func advance_queue(entry_vehicle:Vehicle)-> void:

	# Move from back toward front
	for i in range(queue_nodes.size()-1,0,-1):

		var from : TrackNode = queue_nodes[i-1]
		var to   : TrackNode = queue_nodes[i]

		if from.occupied_by == null:
			continue

		if !to.is_free():
			continue

		var vehicle : Vehicle = from.occupied_by

		print(vehicle.name," ",from.name," -> ",to.name)

		await move_vehicle(vehicle,to)
		# Move new vehicle into Q6

	if queue_nodes[0].is_free():

		print(
			"QUEUE ENTRY ",
			entry_vehicle.name,
			" NQ4 -> Q6"
		)


		await move_vehicle(
			entry_vehicle,
			queue_nodes[0]
		)



func move_vehicle(vehicle:Vehicle,target:TrackNode)->void:
	vehicle.move_to(target)
	while vehicle.moving:
		await get_tree().process_frame
