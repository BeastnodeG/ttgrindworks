extends Node3D

@export var scroll_speed := -3.0

var mesh: MeshInstance3D
var mat: StandardMaterial3D

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child
			break

	if mesh and mesh.get_active_material(0):
		mat = mesh.get_active_material(0).duplicate(true) as StandardMaterial3D
		mesh.set_surface_override_material(0, mat)
	else:
		push_warning("%s: No mesh or material found for paint stream!" % name)

func _process(delta: float) -> void:
	if mat:
		mat.uv1_offset.y += scroll_speed * delta
