extends ItemScriptActive

var SFX := load("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
var SPLASH := load("res://objects/battle/effects/rainbow_paint_splash/rainbow_paint_splash_effect.tscn")


func on_collect(_item: Item, _object: Node3D) -> void:
	print("doing the setup for paintball")
	super.on_collect(_item, _object)
	##1.1.1b made this no longer needed
	#for i in ItemService.seen_items:
		#if i.item_name == "Paintball":
			#ItemService.seen_items.erase(i)
			#print("we've found it!!! the paintball!!!")

func validate_use() -> bool:
	return ItemService.get_closest_item() != null

func use() -> void:
	var world_item := ItemService.get_closest_item()
	
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
	
	attempt_disconnect()
	Util.get_player().stats.current_active_item = null
