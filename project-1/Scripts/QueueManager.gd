@tool
class_name QueueManager
extends Node

@onready var traffic : TrafficManager = $"../TrafficManager"
@onready var job_manager: JobManager = $"../JobManager"

@onready var q6 : TrackNode = %Q6
@onready var q5 : TrackNode = %Q5
@onready var q4 : TrackNode = %Q4
@onready var q3 : TrackNode = %Q3
@onready var q2 : TrackNode = %Q2
@onready var q1 : TrackNode = %Q1

var queue_nodes : Array[TrackNode]
var queue_moving := false

func _ready()-> void:
	queue_nodes = [q6, q5, q4, q3, q2, q1]

func _process(delta: float) -> void:
	if queue_moving: return
	if job_manager.parts_measured:
		release_queue()


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
		
		
func release_queue()->void:
	if queue_moving:
		return
	if !job_manager.parts_measured:
		return
	while true:
		if !job_manager.parts_measured:
			break
		if !can_release_front():
			break
		release_front()
		print("Q1 occupied:", q1.occupied_by)
		await shift_queue()
		await get_tree().create_timer(0.3).timeout
	queue_moving = false


func can_release_front() -> bool:

	if q1.occupied_by == null:
		return false

	var vehicle : Vehicle = q1.occupied_by

	return job_manager.can_queue_release(vehicle)


func release_front() -> void:

	var vehicle : Vehicle = q1.occupied_by

	if vehicle == null:
		return

	print("Release ", vehicle.name)

	vehicle.leave_queue()
	
	
func shift_queue() -> void:
	await shift_after_release()
	
#func release_all() -> void:
#
	#while true:
#
		#var front := q1
#
		#if front.occupied_by == null:
			#break
#
		#var vehicle : Vehicle = front.occupied_by
#
		#if !job_manager.can_queue_release(vehicle):
			#break
#
		#print("Release ", vehicle.name)
#
		#await vehicle.leave_queue()
#
		#await shift_after_release()
#
		## Small delay so movement looks like conveyor indexing
		#await get_tree().create_timer(0.1).timeout
#
	#print("Queue Empty")


func shift_after_release()->void:

	print("SHIFT QUEUE AFTER RELEASE")

	for i in range(queue_nodes.size()-1):

		var from := queue_nodes[i]
		var to := queue_nodes[i+1]
		
		print("from ", from.name, " to ", to.name)

		if from.occupied_by == null:
			continue

		if !to.is_free():
			continue

		var vehicle: Vehicle = from.occupied_by

		print(
			"QUEUE SHIFT ",
			vehicle.name,
			" ",
			from.name,
			" -> ",
			to.name
		)

		await move_vehicle(vehicle,to)
