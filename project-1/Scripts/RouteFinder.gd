@tool
class_name RouteFinder
extends Node


func get_next_node(vehicle: Vehicle, current: TrackNode) -> TrackNode:
	if current.next_nodes.is_empty():
		return null
	if current.node_type != TrackNode.NodeType.JUNCTION:
		return current.next_nodes[0]
	return choose_branch(vehicle, current)
	
func choose_branch(vehicle: Vehicle, junction: TrackNode) -> TrackNode:
	match vehicle.destination:
		Vehicle.Destination.QUEUE:
			return junction.next_nodes[0]
		Vehicle.Destination.MEASUREMENT:
			return junction.next_nodes[1]
	return junction.next_nodes[0]
