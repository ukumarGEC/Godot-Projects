@tool
class_name Technician
extends Node3D

@export var speed := 2.0
signal finished 

var current_node: TrackNode
var target_node: TrackNode
var moving := false


func start(node: TrackNode) -> void:
	current_node = node
	target_node = null
	moving = false

	global_position = node.global_position

	go_next()


func _process(delta: float) -> void:
	if current_node!=null && current_node.name == "NTech3":
		await get_tree().create_timer(3).timeout
		finished.emit()
	
	if !moving:
		return

	global_position = global_position.move_toward(
		target_node.global_position,
		speed * delta
	)

	if global_position.distance_to(target_node.global_position) < 0.05:
		arrive()


func arrive() -> void:
	current_node = target_node
	target_node = null
	moving = false

	print("Technician reached ", current_node.name)

	go_next()


func go_next() -> void:
	if current_node.next_nodes.is_empty():
		print("Technician finished.")
		#finished.emit()
		return

	move_to(current_node.next_nodes[0])


func move_to(node: TrackNode) -> void:
	if node == null:
		return

	target_node = node
	moving = true
