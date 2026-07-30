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
@onready var queue_manager: QueueManager = $"../../QueueManager"
@onready var factory_manager: Factory = $"../../../Environment"

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
var retry_time:float = 1
var retry_counter:float = 0.0

func _process(delta: float)-> void:	
	if waiting:
		if current_node.zone_type == TrackNode.ZoneType.QUEUE:
			return
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
	
	previous_node = current_node
	current_node = target_node
	target_node = null
	
	moving = false
	state = State.IDLE
	
	traffic.arrived(self, current_node, previous_node)	

	# Trigger Robot
	if current_node.node_type == TrackNode.NodeType.MACHINE:
		match current_node.zone_type:
			TrackNode.ZoneType.LOADING: await robot_manager._run_robot(self, 1)
			TrackNode.ZoneType.GRINDING: await robot_manager._run_robot(self, 2)
			TrackNode.ZoneType.DUNNAGE_BAD: await robot_manager._run_robot(self, 9)
			TrackNode.ZoneType.DUNNAGE_GOOD: await robot_manager._run_robot(self, 10)
			TrackNode.ZoneType.MEASUREMENT: 
				match current_node.node_id:
					14: await robot_manager._run_robot(self, 6)
					24: await robot_manager._run_robot(self, 8)
					_ : print("Invalid operation")
		


	if previous_node != null:
		if previous_node.zone_type == TrackNode.ZoneType.QUEUE \
		and current_node.zone_type != TrackNode.ZoneType.QUEUE:
			#queue_manager.queue_vehicle_left(self)
			queue_manager.shift_after_release()
	
	# Vehicles inside the queue do NOT move by themselves.
	if current_node.zone_type == TrackNode.ZoneType.QUEUE:
		return
		
	go_next()
	
func go_next()->void:		
	if current_node.next_nodes.is_empty():
		return
	
	# Pause at loading station
	if current_node.zone_type == TrackNode.ZoneType.LOADING:
		#while !route_finder.is_Good:
		while !factory_manager.StartLoading:
			state = State.WAITING
			await get_tree().create_timer(0.2).timeout
	
	var next:TrackNode = route_finder.get_next_node(self,current_node)
	move_to(next)
	
func move_to(node: TrackNode)-> void:
	if moving:
		return

	#if waiting and waiting_for_node == node:
		#return
		
	if target_node == node:
		return
	
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
		
func leave_queue()->void:
	var next := route_finder.get_next_node(self,current_node)
	move_to(next)
