@tool
class_name JobManager
extends Node

var queue_empty := true
var parts_measured :bool = false
var parts_quarantined :bool = false
var measurement_queue: Array[Vehicle] = []
var quarantine_queue: Array[Vehicle] = []

var measurement_zone_capacity := 2      # Number of nodes in measurement zone
var quarantine_queue_capacity := 6     # Number of queue nodes

func update_status(vehicle: Vehicle, current: TrackNode, previous: TrackNode) -> void:
	if measurement_queue.is_empty() and quarantine_queue.is_empty():
		reset_cycle()
		
	if previous == null:
		return

	var entered_queue := previous.zone_type != TrackNode.ZoneType.QUEUE \
		and current.zone_type == TrackNode.ZoneType.QUEUE

	var left_queue := previous.zone_type == TrackNode.ZoneType.QUEUE \
		and current.zone_type != TrackNode.ZoneType.QUEUE

	var entered_measurement := previous.zone_type != TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type == TrackNode.ZoneType.MEASUREMENT

	var left_measurement := previous.zone_type == TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type != TrackNode.ZoneType.MEASUREMENT
		
	if vehicle.destination == Vehicle.Destination.QUEUE:
		if entered_queue:
			if !quarantine_queue.has(vehicle):
				quarantine_queue.append(vehicle)
				print_status()

		elif left_queue:
			quarantine_queue.erase(vehicle)
			print_status()
			
	if vehicle.destination == Vehicle.Destination.MEASUREMENT:

		if entered_measurement:
			if !measurement_queue.has(vehicle):
				measurement_queue.append(vehicle)
				print_status()

		elif left_measurement:
			measurement_queue.erase(vehicle)

			if measurement_queue.is_empty():
				parts_measured = true

			print_status()

func is_measurement_zone_empty() -> bool:
	return measurement_queue.is_empty()

func is_measurement_zone_full() -> bool:
	return measurement_queue.size() >= measurement_zone_capacity

func is_queue_empty() -> bool:
	return quarantine_queue.is_empty()

func is_queue_full() -> bool:
	return quarantine_queue.size() >= quarantine_queue_capacity

func can_queue_release(vehicle: Vehicle) -> bool:
	if !parts_measured:
		return false
	
	if quarantine_queue.is_empty():
		return false
	
	#for q in quarantine_queue:
		#print (q.name," -> ")
	
	return quarantine_queue.front() == vehicle


func can_measurement_release(vehicle: Vehicle) -> bool:
	if !quarantine_queue.is_empty():
		return false
	
	if measurement_queue.is_empty():
		return false
	
	return measurement_queue.front() == vehicle
	
func print_status()-> void:

	print("------------------------------")
	print("Queue Vehicles       :", quarantine_queue.size())
	print("Measurement Vehicles :", measurement_queue.size())
	#print("Queue Full           :", is_queue_full())
	#print("Measurement Empty    :", is_measurement_zone_empty())
	print("------------------------------")


func _on_TrafficManager_measurement_ready() -> void:
	parts_measured = true
	print("Parts measurement completed")

func _on_TrafficManager_quarantine_cleared() -> void:
	parts_quarantined = false
	print("Quarantined queue cleared")

func _on_TrafficManager_quarantine_queue_full() -> void:
	parts_quarantined = true
	print("Quarantined queue waiting for release")
	
func reset_cycle()->void :
	parts_measured = false
	parts_quarantined = false
	#print("Batch reset")
