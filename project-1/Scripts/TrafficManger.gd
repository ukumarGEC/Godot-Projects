@tool
class_name TrafficManager
extends Node

signal MeasurementReady
signal QuarantineCleared
signal QuarantineQueueFull
var quarantine_full_notified := false
var measurement_completed_notified := false
var queue_vehicle_can_move:= false
signal batchfinished

#@onready var zone_controller : ZoneController = $ZoneController
@onready var job_manager: JobManager = $"../JobManager"
@onready var queue_manager: QueueManager = $"../QueueManager"

func request_move(vehicle: Vehicle, current:TrackNode, target: TrackNode, previous: TrackNode) -> bool:
	if target == null:
		return false
		
	if target.is_free():
		# Handle waiting queued nodes on front
		if current.node_type == TrackNode.NodeType.WAIT \
			&& target.node_type != TrackNode.NodeType.WAIT:
			match current.zone_type:
				#TrackNode.ZoneType.QUEUE: 
					#if !job_manager.can_queue_release(vehicle):
						#target.release()
						#return false
				TrackNode.ZoneType.MEASUREMENT: 
					if !job_manager.can_measurement_release(vehicle):
						return false
						
		target.reserve(vehicle)
		return true
	#else:
		##Signal for Quarantine full
		#if target.node_type == TrackNode.NodeType.WAIT \
			#&& previous.node_type == TrackNode.NodeType.ENTRY:
			#match current.zone_type:
				#TrackNode.ZoneType.MEASUREMENT: 
					#if !measurement_completed_notified:
						#measurement_completed_notified = true
						#MeasurementReady.emit()
				#TrackNode.ZoneType.QUEUE: 
					#if !quarantine_full_notified:
						#quarantine_full_notified = true
						#QuarantineQueueFull.emit()
				##_: print("Invalid operation")
	return false

func arrived(vehicle: Vehicle, current_node: TrackNode, previous: TrackNode)->void:
	if vehicle.name == "V7" && current_node.name == "NL1":
		reset_notification_controll()
		if job_manager.BatchCount !=0:
			batchfinished.emit()
	
	#if vehicle.name == "V2" && current_node.name == "NL1":
		#print("Measurement completed")
		#if !measurement_completed_notified:
			#measurement_completed_notified = true
			#MeasurementReady.emit()
	
	if previous:
		previous.release()
		
	# log status
	match current_node.node_type:
		TrackNode.NodeType.MACHINE: print(vehicle.name, " Reached ", current_node.name)
		TrackNode.NodeType.ENTRY: print(vehicle.name, " Reached ", current_node.name)
		#TrackNode.NodeType.WAIT: print(vehicle.name, " Reached ", current_node.name)
		_: pass
		
	job_manager.update_status(vehicle, current_node, previous)
	if current_node.name == "NQ4":
		queue_manager.vehicle_entered_queue(vehicle)
		return		
		
func reset_notification_controll()-> void:
	measurement_completed_notified = false
	quarantine_full_notified = false
	
