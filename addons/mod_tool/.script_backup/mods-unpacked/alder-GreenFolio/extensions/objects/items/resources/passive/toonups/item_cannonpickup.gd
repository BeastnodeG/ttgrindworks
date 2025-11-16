extends Node3D

func vanilla_1387802578_collect() -> void:
	var curr_val: int = Util.get_player().stats.toonups[7]
	Util.get_player().stats.toonups[movie_type] = min(curr_val + 1, Globals.MaxToonupConsumables)

func vanilla_1387802578_modify(ui: Node3D) -> void:
	# sory
	if ui.movie_type == ToonUp.MovieType.PIXIE:
		ui.get_node("Icon").show()
		ui.get_node("Particles").hide()
		ui.get_node("Particles").emitting = false

func vanilla_1387802578_setup(item: Item) -> void:
	if not Util.get_player():
		return
	
	var pickup_count: int = Util.get_player().stats.toonups[movie_type]
	var items_in_play: Array = ItemService.get_items_in_play(ToonUpNames[movie_type])
	pickup_count += items_in_play.size()
	
	# NOTE: This count includes the item itself, so max is ok. Its only when OVER max that it becomes a problem.
	if pickup_count > Globals.MaxToonupConsumables:
		item.reroll()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func collect():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1387802578_collect, [], 3344913976)
	else:
		vanilla_1387802578_collect()


func modify(ui: Node3D):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1387802578_modify, [ui], 2574832634)
	else:
		vanilla_1387802578_modify(ui)


func setup(item: Item):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1387802578_setup, [item], 1516454979)
	else:
		vanilla_1387802578_setup(item)
