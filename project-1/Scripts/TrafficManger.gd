@tool
class_name TrafficManager
extends Node

func request_move(vehicle: Vehicle, target: TrackNode) -> bool:
	if target == null:
		return false
	if target.is_free():
		target.reserve(vehicle)
		return true
	return false

func arrived(vehicle: Vehicle, previous: TrackNode)->void:
	if previous:
		previous.release()
