@tool
class_name RouteFinder
extends Node

@export var is_Good:= false

func get_next_node(vehicle: Vehicle, current: TrackNode) -> TrackNode:
	if current.next_nodes.is_empty():
		return null
	if current.node_type != TrackNode.NodeType.JUNCTION \
		&& current.node_type != TrackNode.NodeType.CROSSING:
		return current.next_nodes[0]
	return choose_branch(vehicle, current)
	
func choose_branch(vehicle: Vehicle, junction: TrackNode) -> TrackNode:
	if junction.node_type == TrackNode.NodeType.JUNCTION:
		match vehicle.destination:
			Vehicle.Destination.QUEUE:
				return junction.next_nodes[0]
			Vehicle.Destination.MEASUREMENT:
				return junction.next_nodes[1]
	elif junction.node_type == TrackNode.NodeType.CROSSING:
		match junction.zone_type:
			TrackNode.ZoneType.DUNNAGE_BAD:
				if !is_Good: return junction.next_nodes[0]
				else : return junction.next_nodes[1]
			TrackNode.ZoneType.DUNNAGE_GOOD:
				if is_Good: return junction.next_nodes[0]
				else : return junction.next_nodes[1]
	return junction.next_nodes[0]
	
