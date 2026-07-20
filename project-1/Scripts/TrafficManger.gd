@tool
class_name TrafficManager
extends Node

signal MeasurementReady
signal QuarantineCleared
signal QuarantineQueueFull
var quarantine_full_notified := false
var measurement_completed_notified := false

#@onready var zone_controller : ZoneController = $ZoneController
@onready var job_manager: JobManager = $"../JobManager"

func request_move(vehicle: Vehicle, current:TrackNode, target: TrackNode, previous: TrackNode) -> bool:
	if target == null:
		return false
	if target.is_free():
		
		# Handle waiting queue
		if current.node_type == TrackNode.NodeType.WAIT \
			&& target.node_type != TrackNode.NodeType.WAIT:
			match current.zone_type:
				TrackNode.ZoneType.QUEUE: return job_manager.can_queue_release(vehicle)
				TrackNode.ZoneType.MEASUREMENT: return job_manager.can_measurement_release(vehicle)
		
		target.reserve(vehicle)
		return true
	else:
		#Signal for Quarantine full
		if target.node_type == TrackNode.NodeType.WAIT \
			&& previous.node_type == TrackNode.NodeType.NORMAL:
			match current.zone_type:
				TrackNode.ZoneType.MEASUREMENT: 
					if !measurement_completed_notified:
						measurement_completed_notified = true
					MeasurementReady.emit()
				TrackNode.ZoneType.QUEUE: 
					if !quarantine_full_notified:
						quarantine_full_notified = true
						QuarantineQueueFull.emit()
				_: print("Invalid operation")
	return false

func arrived(vehicle: Vehicle, current_node: TrackNode, previous: TrackNode)->void:
	if previous:
		previous.release()
		
		# log status
		match current_node.node_type:
			TrackNode.NodeType.MACHINE: print(vehicle.name, " Reached ", current_node.name)
			TrackNode.NodeType.ENTRY: print(vehicle.name, " Reached ", current_node.name)
			TrackNode.NodeType.WAIT: print(vehicle.name, " Reached ", current_node.name)
			_: pass
			
		job_manager.update_status(vehicle, current_node, previous)
		
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
