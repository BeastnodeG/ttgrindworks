extends ItemScriptActive

const SFX := preload("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
const SPLASH := preload("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")

func validate_use() -> bool:
	return not get_items().is_empty()

func use() -> void:
	var world_items := get_items()
	
	# Now we can reroll our items :)
	AudioManager.play_sound(SFX)
	for world_item in world_items:
		var outcome := RandomService.randf_channel("paintbrush_destroy_roll")
		if outcome < 0.25:
			var dust_cloud = Globals.DUST_CLOUD.instantiate()
			world_item.get_parent().add_child(dust_cloud)
			dust_cloud.scale *= world_item.scale
			dust_cloud.global_position = world_item.global_position
			world_item.queue_free()
			print("all my homies hate paintbrush")
			continue
			
		world_item.override_replacement_rolls = true
		world_item.reroll()
		var splash = SPLASH.instantiate()
		world_item.add_child(splash)
		splash.restart()
	
		if not NodeGlobals.get_ancestor_of_type(world_item, ToonShop) == null:
			var shop = NodeGlobals.get_ancestor_of_type(world_item, ToonShop)
			var index = shop.world_items.find(world_item)
			shop.stored_prices[index] = world_item.item.get_shop_price()

func get_items() -> Array[WorldItem]:
	var items: Array[WorldItem] = []
	# Find our World Items
	var root: Node
	if Util.floor_manager:
		root = Util.floor_manager.get_current_room()
	else:
		root = SceneLoader.current_scene
	var world_items: Array[Node] = NodeGlobals.get_children_of_type(root, WorldItem, true)
	items.assign(world_items)
	return items
