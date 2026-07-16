extends Node3D

@export var robots:Array[SixAxisRobot]
const ROBOT_START_DELAY := 2.0
var pallets:Array[Pallet_Path] = []

#--------------------------------------------------
# READY
#--------------------------------------------------
func _ready()->void:
	print("Factory Controller getting ready..")
	process_mode = Node.PROCESS_MODE_ALWAYS
	setBuildingDimension()
	await get_tree().process_frame
	collect_pallets()
	reset_pallets()
	addDelayToPallets()
	#reset_robots()
	#startRobots()
	print("Factory controller is ready")

#--------------------------------------------------
# PROCESS
#--------------------------------------------------
func _process(_delta:float)->void:
	MapActionHandler()
	
#--------------------------------------------------
# INPUT CONTROL
#--------------------------------------------------
func MapActionHandler()->void:
	if Input.is_action_just_pressed("ui_page_down"):
		get_tree().paused = true
		print("Simulation Paused")

	if Input.is_action_just_pressed("ui_page_up"):
		get_tree().paused = false
		print("Simulation Resumed")

	if Input.is_action_just_pressed("ui_home"):
		reset_world()
		print("Simulation Reset")

#--------------------------------------------------
# BUILDING
#--------------------------------------------------
func setBuildingDimension()->void:
	%Building.width_sections = 10
	%Building.length_sections = 7

#--------------------------------------------------
# PALLET MANAGEMENT
#--------------------------------------------------
func collect_pallets()->void:
	pallets.clear()
	var nodes := get_tree().get_nodes_in_group("pallets")
	for node in nodes:
		if node is Pallet_Path:
			pallets.append(node)
	print("Total pallets : ", pallets.size())

func reset_pallets()->void:
	for pallet in pallets:
		pallet.progress = 0
		pallet.progress_ratio = 0
		pallet.current_station = -1
		pallet.occupied_station = -1
		pallet.state = pallet.PalletState.WAIT_START
	print("Pallets reset")
	
func addDelayToPallets()-> void:
	#%GearPallet_01.start_delay = 2
	#%GearPallet_02.start_delay = 20
	#%GearPallet_03.start_delay = 38
	#%GearPallet_04.start_delay = 56
	#%GearPallet_05.start_delay = 74
	#%GearPallet_06.start_delay = 92
	pass

#--------------------------------------------------
# ROBOTS
#--------------------------------------------------
func startRobots()->void:
	for i in robots.size():
		_start_robot(i)

func _start_robot(index:int)->void:
	await get_tree().create_timer(index * ROBOT_START_DELAY).timeout
	if index < robots.size():
		robots[index].start()

#--------------------------------------------------
# RESET WORLD
#--------------------------------------------------
func reset_world()->void:
	get_tree().paused = false
	print("Resetting simulation...")
	var traffic:TrafficManager = get_tree().get_first_node_in_group("traffic_manager")
	if traffic:
		traffic.reset()
	reset_pallets()
	reset_robots()
	print("Reset complete")
	addDelayToPallets()
	
#--------------------------------------------------
# RESET ROBOTS
#--------------------------------------------------
func reset_robots()->void:
	for robot in robots:
		print(robot.get_parent().name, 	" reset")
		robot.go_home_action()
