extends ItemScriptActive

var SFX := load("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
var SPLASH := load("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")

func validate_use() -> bool:
	return not get_items().is_empty()

func use() -> void:
	var world_items := get_items()
	
	AudioManager.play_sound(SFX)
	for world_item in world_items:
		reroll_to_next_alphabetical(world_item)
		
		var splash = SPLASH.instantiate()
		world_item.add_child(splash)
		splash.restart()
		
		var shop = NodeGlobals.get_ancestor_of_type(world_item, ToonShop)
		if shop:
			var index = shop.world_items.find(world_item)
			if index != -1:
				shop.stored_prices[index] = world_item.item.get_shop_price()

func reroll_to_next_alphabetical(world_item: WorldItem) -> void:
	var current_name := world_item.item.item_name
	var pool := world_item.pool
	
	if not pool:
		push_warning("WorldItem has no pool set, cannot reroll alphabetically")
		return
	
	world_item.override_replacement_rolls = true
	if world_item.bob_tween:
		world_item.bob_tween.kill()
	if world_item.rotation_tween:
		world_item.rotation_tween.kill()
	if world_item.model:
		world_item.model.queue_free()
	
	ItemService.item_removed(world_item.item)
	
	var item_list: Array[Item] = []
	for item_path in pool.items:
		var item = load(item_path) as Item
		if item:
			item_list.append(item)
	
	item_list.sort_custom(func(a: Item, b: Item) -> bool:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	)
		
	var next_item: Item = null
	for i in item_list.size():
		if item_list[i].item_name.naturalnocasecmp_to(current_name) > 0:
			next_item = item_list[i]
			break
	
	if next_item == null:
		next_item = item_list[0]
	
	world_item.item = next_item
	world_item.spawn_item()

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
