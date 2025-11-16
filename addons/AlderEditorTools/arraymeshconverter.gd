@tool
extends EditorScript

#the effort i go through to not have blender in my workflow lmao
#i use this in tandem with csg converter to automatically generate collision - apparently its a better idea to export your csg to blender and make your rooms that way but...

func _run() -> void:
	var root: Node = get_editor_interface().get_edited_scene_root()
	if root == null:
		push_error("No scene is currently open.")
		return

	var csg_node: Node = root.find_child("CSG", true, false)
	if csg_node == null:
		push_error("No node named 'CSG' found.")
		return

	print("Found 'CSG' at: ", csg_node.get_path())

	var converted: int = 0
	for child in csg_node.get_children():
		converted += _convert_arraymeshes_to_boxes(child)

	print("Conversion complete.", converted, " MeshInstance3D(s).")

	get_editor_interface().get_edited_scene_root().set_editable_instances_changed()


func _convert_arraymeshes_to_boxes(node: Node) -> int:
	var count: int = 0

	if node is MeshInstance3D and node.mesh is ArrayMesh:
		var mi: MeshInstance3D = node
		var arr_mesh: ArrayMesh = mi.mesh

		var aabb: AABB = arr_mesh.get_aabb()

		var box: BoxMesh = BoxMesh.new()
		box.size = aabb.size
		box.add_uv2 = true

		if arr_mesh.get_surface_count() > 0:
			var mat: Material = arr_mesh.surface_get_material(0)
			if mat != null:
				box.surface_set_material(0, mat)

		mi.mesh = box
		count += 1
		print("Converted: ", mi.get_path())

		var static_exists: bool = false
		for child in mi.get_children():
			if child is StaticBody3D:
				static_exists = true
				break

		if not static_exists:
			var static_body: StaticBody3D = StaticBody3D.new()
			static_body.name = mi.name + "_StaticBody"

			var collision: CollisionShape3D = CollisionShape3D.new()
			var shape: BoxShape3D = BoxShape3D.new()
			shape.extents = box.size / 2.0
			collision.shape = shape

			static_body.add_child(collision)

			mi.add_child(static_body)
			static_body.owner = mi.owner
			collision.owner = mi.owner

			print("Added StaticBody3D + CollisionShape3D to: ", mi.get_path())

	for child in node.get_children():
		count += _convert_arraymeshes_to_boxes(child)

	return count
