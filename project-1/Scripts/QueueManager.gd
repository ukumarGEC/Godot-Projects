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


func advance_queue()-> void:

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

		vehicle.move_to(to)
		while vehicle.moving:
			await get_tree().process_frame
