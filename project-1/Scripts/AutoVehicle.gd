@tool
class_name AutoVehicle
extends Node3D

enum VehicleLocation
{
	BadDunage,
	GoodDunnage,
	Loader
}

@export var speed := 2.0

signal finished
var current_node: TrackNode
var target_node: TrackNode
var pick_location: TrackNode
var moving := false


func start(node: TrackNode, pick_point: TrackNode) -> void:
	current_node = node
	pick_location = pick_point
	target_node = null
	moving = false

	global_position = node.global_position
	go_next()
	await finished

func _process(delta: float) -> void:			
	if !moving:
		return
	
	global_position = global_position.move_toward(
		target_node.global_position,
		speed * delta
	)

	# Calculate movement direction
	var direction:Vector3 = (target_node.global_position - global_position).normalized()

	# Face the movement direction
	if direction.length() > 0.001:
		look_at(global_position + direction, Vector3.UP)
		
	if global_position.distance_to(target_node.global_position) < 0.05:
		await arrive()


func arrive() -> void:
	current_node = target_node
	target_node = null
	moving = false
	print("Carrier reached ", current_node.name)
	await go_next()


func go_next() -> void:
	if current_node.next_nodes.is_empty():
		print(current_node.name)
		print("Carrier finished.")
		finished.emit()
		return

	var next:TrackNode
	if current_node.node_type == TrackNode.NodeType.JUNCTION\
	&& pick_location == current_node :
		if current_node!= null:
			match current_node.name:
				"NAV2" : await get_tree().create_timer(10).timeout
				"NAV3" : await get_tree().create_timer(10).timeout
				"NAV4" : await get_tree().create_timer(10).timeout 
		next = current_node.next_nodes[1]
	else:
		next = current_node.next_nodes[0]
	
	move_to(next)


func move_to(node: TrackNode) -> void:
	if node == null:
		return

	target_node = node
	moving = true
