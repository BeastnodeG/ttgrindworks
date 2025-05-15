extends ItemScriptActive

var SFX := load("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
var SPLASH := load("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")
var everything_pool_path := "res://objects/items/pools/everything.tres"
var toonup_pool_path := "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/toonup.tres"
var super_candies_pool_path := "res://objects/items/pools/super_candies.tres"

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

	var everything_pool := load(everything_pool_path) as ItemPool
	var toonup_pool := load(toonup_pool_path) as ItemPool
	var super_candies_pool := load(super_candies_pool_path) as ItemPool

	var item_list: Array[Item] = everything_pool.items.duplicate()
	item_list.append_array(toonup_pool.items)
	item_list.append_array(super_candies_pool.items)

	item_list.sort_custom(func(a: Item, b: Item) -> bool:
		return a.item_name.naturalnocasecmp_to(b.item_name) < 0
	)

	var last_letter := ""
	for item in item_list:
		var first_letter := item.item_name.substr(0, 1).to_upper()
		if first_letter != last_letter and last_letter != "":
			print(" ")
		print(item.item_name)
		last_letter = first_letter

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
