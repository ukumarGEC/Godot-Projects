@tool
class_name JobManager
extends Node

var parts_measured :bool = false
var measurement_queue: Array[Vehicle] = []
var quarantine_queue: Array[Vehicle] = []

var measurement_zone_capacity := 2      # Number of nodes in measurement zone
var quarantine_queue_capacity := 8     # Number of queue nodes

func update_status(vehicle: Vehicle, current: TrackNode, previous: TrackNode) -> void:

	# -------------------------------
	# Quarantine Queue Entry
	# -------------------------------
	if vehicle.destination == Vehicle.Destination.QUEUE:
		if previous.zone_type != TrackNode.ZoneType.QUEUE \
		and current.zone_type == TrackNode.ZoneType.QUEUE:

			if !quarantine_queue.has(vehicle):
				quarantine_queue.append(vehicle)

	# -------------------------------
	# Quarantine Queue Exit
	# -------------------------------
	if vehicle.destination == Vehicle.Destination.QUEUE:
		if previous.zone_type == TrackNode.ZoneType.QUEUE \
		and current.zone_type != TrackNode.ZoneType.QUEUE:

			quarantine_queue.erase(vehicle)

	# -------------------------------
	# Measurement Zone Entry
	# -------------------------------
	if vehicle.destination == Vehicle.Destination.MEASUREMENT:
		if previous.zone_type != TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type == TrackNode.ZoneType.MEASUREMENT:

			if !measurement_queue.has(vehicle):
				measurement_queue.append(vehicle)
				print("Measure entry")
				

	# -------------------------------
	# Measurement Zone Exit
	# -------------------------------
	if vehicle.destination == Vehicle.Destination.MEASUREMENT:
		if previous.zone_type == TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type != TrackNode.ZoneType.MEASUREMENT:

			measurement_queue.erase(vehicle)
			print("Measure exit")
			if measurement_queue.size() == 0:
				parts_measured = true

func is_measurement_zone_empty() -> bool:
	return measurement_queue.is_empty()

func is_measurement_zone_full() -> bool:
	return measurement_queue.size() >= measurement_zone_capacity

func is_queue_empty() -> bool:
	return quarantine_queue.is_empty()

func is_queue_full() -> bool:
	return quarantine_queue.size() >= quarantine_queue_capacity

func can_queue_release() -> bool:
	print_status()
	# Queue can enter measurement only when
	# measurement zone is completely empty.
	return parts_measured


func can_measurement_release() -> bool:
	# Measurement vehicle can leave only after
	# queue has filled up.
	return is_queue_full()
	
func print_status()-> void:

	print("------------------------------")
	print("Queue Vehicles       :", quarantine_queue.size())
	print("Measurement Vehicles :", measurement_queue.size())
	print("Queue Full           :", is_queue_full())
	print("Measurement Empty    :", is_measurement_zone_empty())
	print("------------------------------")
