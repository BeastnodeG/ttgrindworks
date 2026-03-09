# green_final_boss_scene.hooks.gd
extends Object
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")

func on_battle_finished(chain: ModLoaderHookChain) -> void:
	print("battle finish detected")
	var gfp = GFUTIL.get_progress()
	var gf = GFUTIL.get_gf()
	
	if gfp and gf and gfp.folio_unlocked <= gf.folio_level:
		gfp.folio_unlocked += 1
		gfp.save_progress()
		print("folio level increased!")
	
	chain.execute_next()
