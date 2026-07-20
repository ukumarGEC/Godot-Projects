@tool
class_name TrackNode

extends Marker3D

enum NodeType {
	NORMAL,
	JUNCTION,
	WAIT,
	MACHINE,
	ENTRY,
	EXIT,
	CROSSING,
	QUEUE
}

enum ZoneType
{
	NONE,
	QUEUE,
	MEASUREMENT,
	STORAGE,
	GRINDING
}

@export var zone_type := ZoneType.NONE
@export var node_id := 0
@export var node_type := NodeType.NORMAL
@export var next_nodes: Array[TrackNode]
@export var queue_zone := false
#@export var edges : Array[TrackEdge]

var occupied_by: Vehicle = null

func is_free() -> bool:
	return occupied_by == null

func reserve(vehicle: Vehicle) -> bool:
	if occupied_by != null and occupied_by != vehicle:
		return false
	occupied_by = vehicle
	return true

func release()-> void:
	occupied_by = null
