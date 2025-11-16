# green_final_boss_scene.hooks.gd
extends Object

func on_battle_finished(chain: ModLoaderHookChain) -> void:
	var owner_node = chain.reference_object as FinalBossScene
	print("battle finish detected")
	var gfp_path := "/root/ModLoader/alder-GreenFolio/GFprogress"
	var gfp: Node = null
	if owner_node.get_tree().get_root().has_node(gfp_path):
		gfp = owner_node.get_tree().get_root().get_node(gfp_path)
		print("Loaded GFGlobalprogress")
	else:
		print("GFGlobalprogress not found at", gfp_path)
	
	var gf_path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	var gf: Node = null
	if owner_node.get_tree().get_root().has_node(gf_path):
		gf = owner_node.get_tree().get_root().get_node(gf_path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", gf_path)
	
	if gfp and gf and gfp.folio_unlocked <= gf.folio_level:
		gfp.folio_unlocked += 1
		gfp.save_progress()
		print("folio level increased!")
	
	chain.execute_next()
