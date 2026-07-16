@tool
extends Node

var stops := [20.0, 50.0, 100.0]
var timer := 0.0
var points: Array[Vector3] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(poi.get_baked_points())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var poi:Curve3D = %QuarantinePath.curveints)
	pass
	
func _physics_process(delta: float) -> void:
	timer += delta

	# 0-5 sec = wait
	# 5-10 sec = move
	if fmod(timer, 10.0) >= 5.0:
		%PathFollow_1.progress += 2 * delta
		%PathFollow_2.progress += 2 * delta
