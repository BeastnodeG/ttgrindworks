extends Object

func get_anomalies(chain: ModLoaderHookChain) -> Array[Script]:
	var mods: Array[Script] = chain.execute_next()
	var anomalies_negative: Array[String] = chain.reference_object.get_script().ANOMALIES_NEGATIVE.duplicate(true)
	
	var tree := Engine.get_main_loop() as SceneTree
	var gf = tree.root.get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	
	if gf.folio_level >= 4:
		print("attempting to force an additiona negative anomaly because green folio")

		for mod in mods:
			if mod is Script and mod.resource_path in anomalies_negative:
				anomalies_negative.erase(mod.resource_path)

		if anomalies_negative.size() > 0:
			var new_mod: String = RandomService.array_pick_random("floor_mods", anomalies_negative)
			var loaded_mod: Script = Util.universal_load(new_mod)
			if not loaded_mod in mods:
				mods.append(loaded_mod)

	return mods
