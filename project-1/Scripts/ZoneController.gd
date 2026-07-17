@tool
class_name ZoneController
extends Node

# zone_id -> number of vehicles inside
var active_zones: Dictionary = {}
#
#func can_enter(vehicle: Vehicle, target: TrackNode) -> bool:
	## Normal nodes are always allowed
	#if target.zone_type != TrackNode.ZoneType.MEASUREMENT:
		#return true
	## Is someone already inside this measurement zone?
	#return !active_zones.has(target.zone_id)
#
#
#func enter_zone(zone_id: int) -> void:
	#active_zones[zone_id] = active_zones.get(zone_id, 0) + 1
#
#func exit_zone(zone_id: int) -> void:
	#if !active_zones.has(zone_id):
		#return
	#active_zones[zone_id] -= 1
	#if active_zones[zone_id] <= 0:
		#active_zones.erase(zone_id)
