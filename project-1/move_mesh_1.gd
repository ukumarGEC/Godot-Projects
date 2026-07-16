@tool
extends MeshInstance3D

var timer := 0.0

func _physics_process(delta: float) -> void:
	timer += delta

	# 0-5 sec = wait
	# 5-10 sec = move
	if fmod(timer, 10.0) >= 5.0:
		%PathFollow_1.progress += 2 * delta
