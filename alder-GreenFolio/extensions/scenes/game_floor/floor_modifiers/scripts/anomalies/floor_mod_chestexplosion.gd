extends FloorModifier

func modify_floor() -> void:
	Globals.s_chest_spawned.connect(on_chest_spawned)

func on_chest_spawned(chest: TreasureChest) -> void:
	chest.s_opened.connect(roll_for_deletion.bind(chest))

func roll_for_deletion(chest: TreasureChest) -> void:
	if chest.scripted_progression:
		return
	if RandomService.randi_channel("chestboom") % 10 == 0:
		destroy_chest(chest)

func destroy_chest(chest: TreasureChest) -> void:
	var timer := Timer.new()
	timer.wait_time = 0.75
	timer.one_shot = true
	add_child(timer)
	
	AudioManager.play_snippet(load("res://audio/sfx/battle/gags/trap/TL_dynamite.ogg"), 0.15, 0.85, 0.75)
	
	timer.start()
	await timer.timeout

	var world_item: WorldItem = chest.get_node("Item").get_child(0)
	cleanup_world_item(world_item)

	var chest_pos := chest.global_position
	chest.vanish()
	timer.queue_free()

	var player := Util.get_player()
	var hit = false
	if player.global_position.distance_to(chest_pos) <= 3.0: #not using a hitbox because it Makes Me Want To Go Sad
		AudioManager.play_sound(player.toon.yelp)
		player.last_damage_source = "a trapped chest"
		player.quick_heal(Util.get_hazard_damage() - 2)
		
		if player.stats.hp > 0:
			player.state = Player.PlayerState.STOPPED
			player.set_animation("slip-backward")
			hit = true

	await play_explosion_effect(chest_pos)
	
	if player.stats.hp > 0 and hit == true:
			await player.animator.animation_finished
			player.state = Player.PlayerState.WALK
			player.do_invincibility_frames(1.0)

func play_explosion_effect(pos: Vector3) -> void:
	AudioManager.play_sound(load("res://audio/sfx/battle/cogs/ENC_cogfall_apart.ogg"))
	var kaboom := Sprite3D.new()
	kaboom.render_priority = 1
	kaboom.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	kaboom.texture = load("res://models/props/gags/tnt/kaboom.png")
	add_child(kaboom)
	kaboom.global_position = pos
	kaboom.scale *= 0.25

	var kaboom_tween := create_tween()
	kaboom_tween.tween_property(kaboom, "pixel_size", 0.05, 0.25)
	await kaboom_tween.finished
	kaboom_tween.kill()
	kaboom.queue_free()

func cleanup_world_item(world_item: WorldItem) -> void:
	ItemService.item_removed(world_item.item)

func get_mod_name() -> String:
	return "Sabotage"

func get_mod_icon() -> Texture2D:
	return load("res://ui_assets/battle/gags/inventory_tnt.png")

func get_description() -> String:
	return "10% chance for chests have a little bit more \"personality\""

func get_mod_quality() -> ModType:
	return ModType.NEGATIVE
