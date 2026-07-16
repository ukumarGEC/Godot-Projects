@tool
class_name TrackNode

extends Marker3D

enum NodeType {
	NORMAL,
	JUNCTION,
	WAIT,
	MACHINE,
	ENTRY,
	EXIT
}

@export var node_id := 0
@export var node_type := NodeType.NORMAL
@export var next_nodes: Array[TrackNode]
#@export var edges : Array[TrackEdge]

var occupied_by: Vehicle = null

func is_free() -> bool:
	return occupied_by == null

func reserve(vehicle: Vehicle) -> bool:
	#print("---")
	#print("Reserve request:", name)
	#print("Current occupant:", occupied_by)
	#print("Request by:", vehicle.name)
	if occupied_by != null:
		return false

	occupied_by = vehicle
	return true

func release()-> void:
	occupied_by = null
	
#func get_neighbors() -> Array[TrackNode]:
	#var result : Array[TrackNode] = []
	#if edges.is_empty():
		#return next_nodes
	#for edge in edges:
		#result.append(edge)
	#return result
