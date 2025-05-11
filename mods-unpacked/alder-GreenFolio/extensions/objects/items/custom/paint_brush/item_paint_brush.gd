extends ItemScriptActive

var SFX := load("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
var SPLASH := load("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")

func use() -> void:
	var world_item := ItemService.get_closest_item()
	
	if not world_item:
		cancel_use()
		return
	
	var outcome := RandomService.randf_channel("paintbrush_destroy_roll")
	if outcome < 0.25:
		var dust_cloud = Globals.DUST_CLOUD.instantiate()
		world_item.get_parent().add_child(dust_cloud)
		dust_cloud.scale *= world_item.scale
		dust_cloud.global_position = world_item.global_position
		world_item.queue_free()
		print("all my homies hate paintbrush")
		return
	
	# Normal paint splash behavior
	AudioManager.play_sound(SFX)
	world_item.override_replacement_rolls = true
	world_item.reroll()
	
	var splash = SPLASH.instantiate()
	world_item.add_child(splash)
	splash.restart()
	
	if not NodeGlobals.get_ancestor_of_type(world_item, ToonShop) == null:
		var shop = NodeGlobals.get_ancestor_of_type(world_item, ToonShop)
		var index = shop.world_items.find(world_item)
		shop.stored_prices[index] = world_item.item.get_shop_price()
