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
	CROSSING
}

enum ZoneType
{
	LOADING,
	GRINDING,
	WASHING,
	QUEUE,
	MEASUREMENT,
	#MEASUREMENT_300,
	#MEASUREMENT_360T,
	PHOTOBOOTH,
	DUNNAGE_GOOD,
	DUNNAGE_BAD,
	NONE
}

@export var zone_type := ZoneType.NONE
@export var node_id := 0
@export var node_type := NodeType.NORMAL
@export var next_nodes: Array[TrackNode]

var occupied_by: Vehicle = null

func is_free() -> bool:
	return occupied_by == null

func reserve(vehicle: Vehicle) -> bool:
	if occupied_by != null and occupied_by != vehicle:
		return false
	occupied_by = vehicle
	return true

func release()-> void:
	print("Release : ", self.name)
	occupied_by = null
	
func updated()-> bool:
	return false
	 
