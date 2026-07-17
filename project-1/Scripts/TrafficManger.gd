@tool
class_name TrafficManager
extends Node

#@onready var zone_controller : ZoneController = $ZoneController
@onready var job_manager: JobManager = $"../JobManager"

func request_move(vehicle: Vehicle, current:TrackNode, target: TrackNode) -> bool:
	if target == null:
		return false
	if target.is_free():
		target.reserve(vehicle)
		
		# Handle waiting queue
		if target.node_type == TrackNode.NodeType.WAIT:
			if current.node_type == TrackNode.NodeType.QUEUE:
					return job_manager.can_queue_release()
		return true
	return false

func arrived(vehicle: Vehicle, previous: TrackNode)->void:
	if previous:
		previous.release()
		
	# Queue controll
	#if next.zone_type == TrackNode.ZoneType.MEASUREMENT:
		#if zone_controller.is_zone_busy(next.node_id):
			#print("Busy true")
			#wait_for(next)
			#return


#func notify_MeasurementZone_Entry()->void:
	#if current_node.zone_type == TrackNode.ZoneType.MEASUREMENT \
	#and previous_node.zone_type != TrackNode.ZoneType.MEASUREMENT:
		#zone_controller.enter_zone(current_node.zone_id)
		#
#func notify_MeasurementZone_Exit()->void:
	#if previous_node.zone_type == TrackNode.ZoneType.MEASUREMENT \
	#and current_node.zone_type != TrackNode.ZoneType.MEASUREMENT:
		#zone_controller.exit_zone(previous_node.zone_id)
