extends Node3D

@export var particle_node: GPUParticles3D
@export var target_bone: Node3D

func _process(delta):
	if particle_node and target_bone:
		var mat = particle_node.process_material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("bone_pos", target_bone.global_transform.origin)
