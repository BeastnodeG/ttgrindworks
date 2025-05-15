extends ItemScriptActive

var SFX := load("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
var SPLASH := load("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")
var everything_pool_path := "res://objects/items/pools/everything.tres"

func use() -> void:
	var world_item := ItemService.get_closest_item()
	if not world_item:
		cancel_use()
		return

	AudioManager.play_sound(SFX)
	world_item.override_replacement_rolls = true

	if world_item.bob_tween:
		world_item.bob_tween.kill()
	if world_item.rotation_tween:
		world_item.rotation_tween.kill()

	if world_item.model:
		world_item.model.queue_free()

	ItemService.item_removed(world_item.item)

	var EVERYTHING_POOL := load(everything_pool_path) as ItemPool
	var item_list: Array[Item] = EVERYTHING_POOL.items.duplicate()
	item_list.sort_custom(func(a: Item, b: Item) -> bool:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	)

	#print("Sorted items in Everything Pool:")
	#for item in item_list:
		#print("%s" % item.item_name)

	var current_name := world_item.item.item_name
	var next_item: Item = null
	for i in item_list.size():
		if item_list[i].item_name.naturalnocasecmp_to(current_name) > 0:
			next_item = item_list[i]
			break
	if next_item == null:
		next_item = item_list[0]

	world_item.item = next_item

	world_item.spawn_item()

	var splash = SPLASH.instantiate()
	world_item.add_child(splash)
	splash.restart()

	var shop = NodeGlobals.get_ancestor_of_type(world_item, ToonShop)
	if shop:
		var index = shop.world_items.find(world_item)
		if index != -1:
			shop.stored_prices[index] = world_item.item.get_shop_price()
