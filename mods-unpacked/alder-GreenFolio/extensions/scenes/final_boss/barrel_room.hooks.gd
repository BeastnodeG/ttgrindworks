extends Object

#this doesnt work because it is preloaded - functionality moved to GFbarrel_room

func _ready(chain: ModLoaderHookChain) -> void:
	var scene := chain.reference_object as Node3D
	
	var gf_path = "/root/ModLoader/alder-GreenFolio/GFglobal"
	var tree := Engine.get_main_loop()
	if tree == null or not tree is SceneTree:
		return
	var gf = tree.get_root().get_node_or_null(gf_path)
	print("folio level is: ", gf.folio_level)
	if gf.folio_level >= 10:
		#remember to add a check for gf... please...
		scene.exit_elevator.scene_path = "res://mods-unpacked/alder-GreenFolio/extensions/scenes/final_boss/greenpenthouse.tscn"
	chain.execute_next()
