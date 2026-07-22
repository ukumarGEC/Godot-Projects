@tool
extends Node
class_name  RobotManager

enum Robos{
	InputLoader,
	Grinding,
	GMSP,
	Gearset,
	BadDunnage,
	GoodDunnage
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#--------------------------------------------------
# ROBOT CONTROL
#--------------------------------------------------
func _run_robot(vehicle: Vehicle,roboId:int)->void:
	var robot : SixAxisRobot
	match roboId:
		1: robot = (%Robo_1.find_child("SixAxisRobot*"))
		2: robot = (%Robo_2.find_child("SixAxisRobot*"))
		3: robot = (%Robo_3.find_child("SixAxisRobot*"))
		6: robot = (%Robo_6.find_child("SixAxisRobot*"))
		7: robot = (%Robo_7.find_child("SixAxisRobot*"))
		8: robot = (%Robo_8.find_child("SixAxisRobot*"))
		9: robot = (%Robo_9.find_child("SixAxisRobot*"))
		10:robot = (%Robo_10.find_child("SixAxisRobot*"))
	await robot.pick_place(vehicle)
	
func _run(roboId:Robos)->void:
	var robot : SixAxisRobot
	match roboId:
		Robos.InputLoader: robot = (%Robo_1.find_child("SixAxisRobot*"))
		Robos.Grinding: robot = (%Robo_2.find_child("SixAxisRobot*"))
		Robos.Grinding: robot = (%Robo_3.find_child("SixAxisRobot*"))
		Robos.GMSP: robot = (%Robo_6.find_child("SixAxisRobot*"))
		Robos.GMSP: robot = (%Robo_7.find_child("SixAxisRobot*"))
		Robos.Gearset: robot = (%Robo_8.find_child("SixAxisRobot*"))
		Robos.BadDunnage: robot = (%Robo_9.find_child("SixAxisRobot*"))
		Robos.GoodDunnage:robot = (%Robo_10.find_child("SixAxisRobot*"))
	await robot.pick_place(null)
	
