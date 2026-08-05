@tool
class_name JobManager
extends Node

var BatchCount := 0

var queue_empty := true
var parts_measured :bool = false
var parts_quarantined :bool = false
var measurement_queue: Array[Vehicle] = []
var quarantine_queue: Array[Vehicle] = []
var buffer_queue: Array[Vehicle] = []

@onready var queue_manager: QueueManager = $"../QueueManager"
@onready var route_finder : RouteFinder = $"../RouteFinder"
@onready var gear_repository_manager: GearRepositoryManager = $"../GearRepositoryManager"

var measurement_zone_capacity := 2      # Number of nodes in measurement zone
var quarantine_queue_capacity := 6     # Number of queue nodes

func _ready()->void:
	randomize()

func update_status(vehicle: Vehicle, current: TrackNode, previous: TrackNode) -> void:
	#if current.zone_type == TrackNode.ZoneType.QUEUE:
		#if previous.zone_type != TrackNode.ZoneType.QUEUE:
			#print(vehicle.name," REACHED QUEUE")
		#else :
			#print(vehicle.name," MOVED IN QUEUE")
	
	if measurement_queue.is_empty() and quarantine_queue.is_empty():
		reset_cycle()
		
	if previous == null:
		return

	var entered_queue := previous.zone_type != TrackNode.ZoneType.QUEUE \
		and current.zone_type == TrackNode.ZoneType.QUEUE

	var left_queue := previous.zone_type == TrackNode.ZoneType.QUEUE \
		and current.zone_type != TrackNode.ZoneType.QUEUE
		
	var entered_queue_buffer := previous.zone_type != TrackNode.ZoneType.QUEUEBUFFER \
		and current.zone_type == TrackNode.ZoneType.QUEUEBUFFER

	var left_queue_buffer := previous.zone_type == TrackNode.ZoneType.QUEUEBUFFER \
		and current.zone_type != TrackNode.ZoneType.QUEUEBUFFER

	var entered_measurement := previous.zone_type != TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type == TrackNode.ZoneType.MEASUREMENT

	var left_measurement := previous.zone_type == TrackNode.ZoneType.MEASUREMENT \
		and current.zone_type != TrackNode.ZoneType.MEASUREMENT
		
	var photobooth_finished := previous.node_type == TrackNode.NodeType.MACHINE \
		and current.zone_type == TrackNode.ZoneType.PHOTOBOOTH
		
	if vehicle.destination == Vehicle.Destination.QUEUE:
		if entered_queue:
			if !quarantine_queue.has(vehicle):
				quarantine_queue.append(vehicle)
				print_status()

		elif left_queue:
			quarantine_queue.erase(vehicle)
			print_status()
			
		if entered_queue_buffer:
			if !buffer_queue.has(vehicle):
				buffer_queue.append(vehicle)
				print_status()

		elif left_queue_buffer:
			buffer_queue.erase(vehicle)
			print_status()
			
	if vehicle.destination == Vehicle.Destination.MEASUREMENT:

		if entered_measurement:
			if !measurement_queue.has(vehicle):
				measurement_queue.append(vehicle)
				print_status()

		elif left_measurement:
			measurement_queue.erase(vehicle)

			#if measurement_queue.is_empty():
				#parts_measured = true
				#_on_TrafficManager_measurement_ready()
			print_status()
				
		elif photobooth_finished:
			_on_TrafficManager_measurement_ready()
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
	
	if !buffer_queue.is_empty():
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
	
	#update measurement result - good/bad
	BatchCount = BatchCount + 1
	route_finder.is_Good = BatchCount % 2 == 0

	print("Parts measurement completed")
	
	#while !queue.empty()
	queue_manager.release_queue()

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

func _on_Technician_finished() -> void:
	route_finder.is_Good = true

func _on_TrafficManager_batchfinished() -> void:
	print("Batch finished")
	if !route_finder.is_Good:
		await %Environment.start_Repair()
		print("Machine repair process completed")
		#print("Clearing dunnage........")
		#await %Environment.start_towing(AutoVehicle.VehicleLocation.BadDunage)
		#gear_repository_manager.reset_bad_dunnage()
		#print("Dunnage cleared........")
	#else:
		#print("Clearing dunnage........")
		#await %Environment.start_towing(AutoVehicle.VehicleLocation.GoodDunnage)
		#gear_repository_manager.reset_good_dunnage()
		#print("Dunnage cleared........")
#
	#print("Loading Gears........")
	#await %Environment.start_towing(AutoVehicle.VehicleLocation.Loader)
	#gear_repository_manager.reload()
	#print("Gears Loaded")


func _on_GearRepositoryManager_loader_empty() -> void:
	print("Loading Gears........")
	await %Environment.start_towing(AutoVehicle.VehicleLocation.Loader)
	print("Gears Loaded")


func _on_GearRepositoryManager_good_dunnage_full() -> void:
	print("Clearing good dunnage........")
	await %Environment.start_towing(AutoVehicle.VehicleLocation.GoodDunnage)
	print("Good Dunnage cleared........")


func _on_GearRepositoryManager_bad_dunnage_full() -> void:
	print("Clearing bad dunnage........")
	await %Environment.start_towing(AutoVehicle.VehicleLocation.BadDunage)
	print("Bad Dunnage cleared........")
