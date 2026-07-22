extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.BLACK
	self.material_override = material
	pass # Replace with function body.
