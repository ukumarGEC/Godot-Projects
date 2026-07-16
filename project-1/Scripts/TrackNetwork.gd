@tool
class_name TrackNetwork
extends Node3D

@export var nodes: Array[TrackNode]

func _ready()->void:
	#for node in get_all_nodes():
		#print(node.name)
		#for next in node.next_nodes:
			#print("   -> ", next.name)
			pass

func get_node_by_id(id: int) -> TrackNode:
	for node in nodes:
		if node.node_id == id:
			return node
	return null

func get_all_nodes() -> Array[TrackNode]:
	var result : Array[TrackNode] = []
	for child in get_children():
		if child is TrackNode:
			result.append(child)
	return result
