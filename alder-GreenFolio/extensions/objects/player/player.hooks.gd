extends Object

func reset_stats(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	
	var gf_path = "/root/ModLoader/alder-GreenFolio/GFglobal"
	var tree := Engine.get_main_loop()
	if tree == null or not tree is SceneTree:
		return
	
	var gf = tree.get_root().get_node_or_null(gf_path)
	if gf == null:
		print("GFglobal not found at", gf_path)
		return
	
	print("Current folio level:", gf.folio_level)
	var folio_store = gf.folio_level
	
	if gf.folio_level >= 6:
		print("Folio adjusting stats")
		var player = Util.get_player()
		player.stats.damage += -0.05
		player.stats.defense += -0.05
		player.stats.luck += -0.05
		player.stats.evasiveness += -0.05
		player.stats.speed += -0.05
		#player.stats.hp += -5
		#player.stats.max_hp += -5
	
	gf.reset_stats()
	gf.folio_level = folio_store
	print("GFglobal stats reset.")
