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
		
	#if target_node == null:
		#return
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
		await arrive()
		
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
	
	#current_node.release()
	previous_node = current_node
	current_node = target_node
		
	#current_node.reserve(self)
	target_node = null
	moving = false
	state = State.IDLE
	traffic.arrived(self, previous_node)
	
	# log status
	match current_node.node_type:
		TrackNode.NodeType.MACHINE: print(name, " Reached ", current_node.name)
		TrackNode.NodeType.ENTRY: print(name, " Reached ", current_node.name)
		_: pass
		
	# Trigger Robot
	if current_node.name == "N7":
		await robot_manager._run_robot(2)
	
	job_manager.update_status(self, current_node, previous_node)
	
	go_next()
	
func go_next()->void:
	if current_node.next_nodes.is_empty():
		return
	var next:TrackNode = route_finder.get_next_node(self,current_node)
	move_to(next)
	
func move_to(node: TrackNode)-> void:
	if node == null:
		return
	if traffic.request_move(self, current_node, node):
		target_node = node
		moving = true
		state = State.MOVING
		waiting = false
		waiting_for_node = null
	else:
		waiting = true
		retry_timer = retry_delay
		waiting_for_node = node
		
#func try_move()-> void:
	#if current_node.next_nodes.is_empty():
		#return
	#var next:TrackNode = current_node.next_nodes[0] 
	#if next.is_free():
		#move_to(next)
		
		
#func wait_for(node: TrackNode) -> void:
	#waiting = true
	#moving = false
	#waiting_for_node = node
	#retry_timer = retry_delay
	#state = State.WAITING
