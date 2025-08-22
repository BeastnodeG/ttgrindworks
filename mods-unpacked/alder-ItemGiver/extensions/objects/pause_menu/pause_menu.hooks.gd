extends Node
var item_edit: LineEdit
var give_button: Button
func sync_reward(chain: ModLoaderHookChain) -> void:
	var pause_menu = chain.reference_object
	if not is_instance_valid(item_edit):
		item_edit = LineEdit.new()
		item_edit.name = "ItemEdit"
		item_edit.placeholder_text = "Enter item path or name..."
		item_edit.custom_minimum_size = Vector2(400, 30)
		var version_label = pause_menu.get_node("%VersionLabel")
		item_edit.position = Vector2(pause_menu.size.x - 500, 20)
		give_button = Button.new()
		give_button.name = "GiveButton"
		give_button.text = "Give Item"
		give_button.custom_minimum_size = Vector2(80, 30)
		give_button.position = item_edit.position + Vector2(item_edit.custom_minimum_size.x + 10, 0)
		give_button.pressed.connect(_on_give_button_pressed)
		pause_menu.add_child(item_edit)
		pause_menu.add_child(give_button)
	chain.execute_next()
func _on_give_button_pressed() -> void:
	var input = item_edit.text.strip_edges()
	
	if input.is_empty():
		return
	
	var success = give_item_to_player(input)
	
	if success:
		item_edit.text = ""
static func give_item_to_player(input: String) -> bool:
	var item_resource = find_item(input)
	if not item_resource:
		return false
	
	var player = Util.get_player()
	if not player:
		return false
	
	return spawn_world_item(item_resource, player)
static func find_item(input: String):
	if ResourceLoader.exists(input):
		return load(input)
	
	var everything_pool = load("res://objects/items/pools/everything.tres")
	if not everything_pool:
		return null
	
	for item in everything_pool.items:
		if item.item_name.to_lower() == input.to_lower():
			return item
	
	return null
static func spawn_world_item(item_resource, player) -> bool:
	var world_item_scene = load("res://objects/items/world_item/world_item.tscn")
	if not world_item_scene:
		return false
	
	var zone
	if is_instance_valid(Util.floor_manager):
		zone = Util.floor_manager.get_current_room()
	else:
		zone = SceneLoader
	
	if not zone:
		return false
	
	var rel_basis = player.toon.global_basis
	var base_pos = player.global_position + (rel_basis * Vector3(0, 0.2, 3))
	
	var random_x = randf_range(-1.5, 1.5)
	var random_z = randf_range(-0.5, 0.5)
	var rel_pos = base_pos + (rel_basis * Vector3(random_x, 0, random_z))
	
	var raycast_check = player.get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(player.global_position, rel_pos, 0b0001)
	)
	if raycast_check:
		rel_pos = raycast_check.position - (rel_basis * Vector3(0, 0, 0.5))
	
	var ground_check = player.get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(
			rel_pos + Vector3(0, 2, 0), 
			rel_pos - Vector3(0, 5, 0), 
			0b0001
		)
	)
	if ground_check:
		rel_pos.y = ground_check.position.y + 0.25
	
	var world_item = world_item_scene.instantiate()
	world_item.item = item_resource
	world_item.override_replacement_rolls = true
	
	zone.add_child(world_item)
	world_item.global_position = rel_pos
	world_item.rotation.y = randf_range(0, TAU)
	
	if "DUST_CLOUD" in Globals:
		var dust_cloud = Globals.DUST_CLOUD.instantiate()
		zone.add_child(dust_cloud)
		dust_cloud.global_position = world_item.global_position
	
	return true
