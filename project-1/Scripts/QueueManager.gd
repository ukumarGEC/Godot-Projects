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
var queue_releasing := false

func _ready()-> void:
	queue_nodes = [q6, q5, q4, q3, q2, q1]

#func _process(delta: float) -> void:
	#if queue_releasing: return
	#if job_manager.parts_measured:
		#queue_releasing = true
		#release_queue()
		#queue_releasing = false

func vehicle_entered_queue(vehicle:Vehicle)-> void:
	if queue_moving:
		return
	queue_moving = true
	await advance_queue(vehicle)
	
	if is_queue_full() and job_manager.parts_measured:
		print("Queue full")
		release_queue()
	queue_moving = false

func is_queue_full() -> bool:
	for node in queue_nodes:
		if node.is_free():
			return false
	return true

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
		await move_vehicle(
			entry_vehicle,
			queue_nodes[0]
		)


func move_vehicle(vehicle:Vehicle,target:TrackNode)->void:
	vehicle.move_to(target)
	while vehicle.moving:
		await get_tree().process_frame
		
		
func release_queue()->void:
	#if queue_moving:
		#return
	#if !job_manager.parts_measured:
		#return
	while can_release_front():
		#if !job_manager.parts_measured:
			#break
		#if !can_release_front():
			#break
		release_front()
		await shift_queue()
		await get_tree().create_timer(0.3).timeout
	#queue_moving = false


func can_release_front() -> bool:

	if q1.occupied_by == null:
		return false

	var vehicle : Vehicle = q1.occupied_by

	return job_manager.can_queue_release(vehicle)


func release_front() -> void:

	var vehicle : Vehicle = q1.occupied_by

	if vehicle == null:
		return

	vehicle.leave_queue()
	
	
func shift_queue() -> void:
	await shift_after_release()

func shift_after_release()->void:

	print("SHIFT QUEUE AFTER RELEASE")

	for i in range(queue_nodes.size()-1):

		var from := queue_nodes[i]
		var to := queue_nodes[i+1]
		
		if from.occupied_by == null:
			continue

		if !to.is_free():
			continue

		var vehicle: Vehicle = from.occupied_by
		await move_vehicle(vehicle,to)
