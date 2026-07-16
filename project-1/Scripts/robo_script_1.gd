@tool
class_name Robo_script_1
extends SixAxisRobot

var _running := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().paused:
		return
	pass

func start() -> void:
	if _running:
		return
	_running = true
	# _pick_place_loop()
	
func stop() -> void:
	_running = false
	
func pick_place_loop()-> void:
	while _running:
		await pick_place()

func pick_place() -> void:
	# Pick position (front)
	await _move([0, 20, 85, 0, 65, 0])
	await _move([0, 55, 75, 0, 45, 0])
	vacuum_on = true
	await get_tree().create_timer(0.3).timeout
	await _move([0, 20, 85, 0, 65, 0])
	
	# Place position (back)
	await _move([180, 20, 85, 0, 65, 0])
	
	await _move([180, 55, 75, 0, 45, 0])
	await get_tree().create_timer(0.3).timeout
	vacuum_on = false
	await _move([180, 20, 85, 0, 65, 0])
	
	await get_tree().create_timer(1).timeout
	
	await _move([180, 55, 75, 0, 45, 0])
	await get_tree().create_timer(0.3).timeout
	vacuum_on = true
	await _move([180, 20, 85, 0, 65, 0])
	
	# Put position (front)
	await _move([0, 20, 85, 0, 65, 0])
	await _move([0, 55, 75, 0, 45, 0])
	vacuum_on = false
	await get_tree().create_timer(0.3).timeout
	await _move([0, 20, 85, 0, 65, 0])
	
	# Return Home
	move_to_home()
	await _wait_until_done()
	
	await get_tree().create_timer(0.5).timeout
		
func _wait_until_done() -> void:
	while is_moving():
		await get_tree().process_frame
		
func _move(target_angles: Array) -> void:
	move_to_position(target_angles)
	await _wait_until_done()
	
func _startFromHome() -> void:
	stop()
	stop_motion() # Stop any active tween
	move_to_position(home_position, true)
	_running = true
	#_pick_place_loop()
