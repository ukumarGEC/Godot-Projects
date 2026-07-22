class_name Pallet_Path
extends PathFollow3D


#--------------------------------------------------
# PATH REFERENCES
#--------------------------------------------------
@onready var path: Path3D = get_parent() as Path3D
@onready var stoppage_path:Path3D = %QuarantineGQGHalt
@onready var robo_Manager:RobotManager = %RobotManager
#@export var stoppage_path: Path3D

#--------------------------------------------------
# CONSTANTS
#--------------------------------------------------
const MOVE_SPEED := 1
const HALT_THRESHOLD := 0.02
const RELEASE_DISTANCE := 0.5

#--------------------------------------------------
# VARIABLES
#--------------------------------------------------
var start_delay := 0.0
@onready var traffic_manager: TrafficManager = %TrafficManager

enum PalletState
{
	WAIT_START,
	MOVING,
	WAITING
}

var state := PalletState.WAIT_START
var current_station := -1
var occupied_station := -1
var halt_offsets:Array[float] = []

#--------------------------------------------------
# READY
#--------------------------------------------------
func _ready() -> void:
	print(name, " getting ready..")
	#if Engine.is_editor_hint():
		#return
	await get_tree().process_frame
	progress = 0
	progress_ratio = 0
	add_to_group("pallets")
	traffic_manager.station_released.connect(_station_released)
	_cache_halt_positions()
	print(name," is ready")

#--------------------------------------------------
# PROCESS
#--------------------------------------------------
func _process(delta:float)->void:
	if get_tree().paused:
		return
	match state:
		PalletState.WAIT_START:
			start_delay -= delta
			if start_delay <= 0:
				state = PalletState.MOVING
		PalletState.MOVING:
			progress += MOVE_SPEED * delta
			check_station()
			release_old_station()
		PalletState.WAITING:
			pass

#--------------------------------------------------
# CACHE STATION POSITIONS
#--------------------------------------------------
func _cache_halt_positions()->void:
	halt_offsets.clear()
	if stoppage_path == null:
		return
	var curve := stoppage_path.curve
	for i in curve.point_count:
		var global_position_s:Vector3 = (stoppage_path.to_global(curve.get_point_position(i)))
		var local_position:Vector3 = (path.to_local(global_position_s))
		var offset:float = (path.curve.get_closest_offset(local_position))
		halt_offsets.append(offset)

#--------------------------------------------------
# CHECK STATION ARRIVAL
#--------------------------------------------------
func check_station()->void:
	for i in halt_offsets.size():
		if abs(progress - halt_offsets[i]) <= HALT_THRESHOLD:
			if current_station == i:
				return
			current_station = i
			occupied_station = i
			traffic_manager.occupy(path, current_station, self )
			# stop pallet here
			state = PalletState.WAITING
			# wait for robot process
			#await _process_station(i)
			await  _update_pallet_status(current_station)
			try_move_next()
			return

#--------------------------------------------------
# TRY NEXT STATION
#--------------------------------------------------
func try_move_next()->void:
	var next_station := current_station + 1
	if traffic_manager.is_free(path, next_station):
		state = PalletState.MOVING
	else:
		state = PalletState.WAITING

#--------------------------------------------------
# WAITING PALLET CALLBACK
#--------------------------------------------------
func _station_released(path3d:Path3D, station:int)->void:
	if path3d != path:
		return
	if state != PalletState.WAITING:
		return
	if station == current_station + 1:
		try_move_next()

#--------------------------------------------------
# RELEASE OLD STATION
#--------------------------------------------------
func release_old_station()->void:
	if occupied_station == -1:
		return
	if progress > (halt_offsets[occupied_station] + RELEASE_DISTANCE):
		traffic_manager.release(path, occupied_station)
		occupied_station = -1

#--------------------------------------------------
# PALLET STATUS
#--------------------------------------------------
func _update_pallet_status(machineID:int)->void:
	if path.name.contains("Q"):
		match machineID:
			0:
				print(name," leaves input loader")
				#await robo_Manager._run_robot(1)
			2:
				print(name," reached Gear Grinding")
				#await robo_Manager._run_robot(2)
			4:	
				print(name," reached Washer")
				await get_tree().create_timer(5.0).timeout
			6:	
				print(name," reached Gear Quarantine.")
				await get_tree().create_timer(5.0).timeout
			7:	
				print(name," reached Gear Quarantine")
				await get_tree().create_timer(5.0).timeout
			8:	
				print(name," reached Gear Quarantine")
				await get_tree().create_timer(5.0).timeout
			9:	
				print(name," reached Gear Quarantine")
				await get_tree().create_timer(5.0).timeout
			10:	
				print(name," reached Gear Quarantine")
				await get_tree().create_timer(5.0).timeout
			11:	print(name," reached Gear Quarantine")
			13:
				if path.name.contains("GQB"):
					print(name," reached Bad Dunnage")
					#await robo_Manager._run_robot(9)
				else:
					print(name," reached Good Dunnage")
					#await robo_Manager._run_robot(10)
	elif path.name.contains("M"):
		match machineID:
			0:
				print(name," leaves input loader")
				#robo_Manager._run_robot(1)
			1:
				print(name," reached Gear Grinding")
				#robo_Manager._run_robot(2)
			3:
				print(name," reached GMSP")
				#robo_Manager._run_robot(6)
			4:
				print(name," reached 300T GearSet")
				#robo_Manager._run_robot(8)
			6:
				if path.name.contains("GMB"):
					print(name," reached Bad Dunnage")
					#robo_Manager._run_robot(9)
				else:
					print(name," reached Good Dunnage")
					#robo_Manager._run_robot(10)

#--------------------------------------------------
# HELPERS
#--------------------------------------------------
