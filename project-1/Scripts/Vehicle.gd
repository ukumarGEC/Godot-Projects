@tool
class_name Vehicle
extends Node3D

enum Destination
{
	QUEUE,
	MEASUREMENT
}

enum AssetType{
	GEAR,
	PINION
}

enum State
{
	IDLE,
	MOVING,
	WAITING,
	PROCESSING
}

var state:State = State.IDLE

@export var destination:Destination = Destination.MEASUREMENT
@export var process_type:AssetType = AssetType.GEAR
@export var speed:float = 2.0
@onready var traffic : TrafficManager = $"../../TrafficManager"
@onready var route_finder : RouteFinder = $"../../RouteFinder"
@onready var robot_manager : RobotManager = $"../../RobotManager"
@onready var job_manager: JobManager = $"../../JobManager"
@export var retry_delay:float = 0.25
@export var processing_time:float = 0.0

var processing_timer:float = 0.0
var processing:bool = false
var retry_timer:float = 0.0
var previous_node: TrackNode
var current_node: TrackNode
var target_node: TrackNode

var moving:bool = false
var waiting:bool = false
var waiting_for_node: TrackNode = null
var retry_time:float = 0.5
var retry_counter:float = 0.0

func _process(delta: float)-> void:
	if waiting:
		retry_timer -= delta
		if retry_timer <= 0:
			retry_timer = retry_delay
			#go_next()
			move_to(waiting_for_node)
		return
		
	if !moving:
		return
		
	# Calculate movement direction
	var direction:Vector3 = (target_node.global_position - global_position).normalized()

	# Face the movement direction
	if direction.length() > 0.001:
		look_at(global_position + direction, Vector3.UP)
		
	# Move
	global_position = global_position.move_toward(
		target_node.global_position,
		speed * delta
	)

	# Arrived?
	if global_position.distance_to(target_node.global_position) < 0.05:
		moving = false
		arrive()
		
func start(node: TrackNode)-> void:
	current_node = node
	global_position = node.global_position
	state = State.WAITING
	if !node.reserve(self):
		waiting = true
		waiting_for_node = node
		#push_error("Node occupied")
		#print("Start failed:", node.name)
		return
	#current_node.reserve(self)
	go_next()

func arrive()-> void:
	
	previous_node = current_node
	current_node = target_node
	target_node = null
	
	moving = false
	state = State.IDLE
	
	# Current node is already reserved
	# Release the old node
	if previous_node:
		previous_node.release()
		
	traffic.arrived(self, current_node, previous_node)	
	
	# Trigger Robot
	if current_node.name == "N1":
		await robot_manager._run_robot(1)
	if current_node.name == "N7":
		await robot_manager._run_robot(2)
	
	go_next()
	
func go_next()->void:
	if current_node.next_nodes.is_empty():
		return
	var next:TrackNode = route_finder.get_next_node(self,current_node)
	move_to(next)
	
func move_to(node: TrackNode)-> void:
	if node == null:
		return
	if traffic.request_move(self, current_node, node, previous_node):
		target_node = node
		moving = true
		state = State.MOVING
		waiting = false
		waiting_for_node = null
	else:
		waiting = true
		state = State.WAITING
		retry_timer = retry_delay
		waiting_for_node = node
