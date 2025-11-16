extends Object

func get_icon(chain: ModLoaderHookChain) -> Texture2D:
	var stat_boost = chain.reference_object as StatBoost
	if stat_boost.stat == "accuracy":
		return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/accuracy.png")
	
	return chain.execute_next([])
