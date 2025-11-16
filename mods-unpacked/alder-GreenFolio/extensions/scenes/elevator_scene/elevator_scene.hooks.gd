extends Object

func final_boss_time_baby(chain: ModLoaderHookChain) -> void:
	var owner_node = chain.reference_object as ElevatorScene
	owner_node.FINAL_FLOOR_VARIANT = load('res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/alt_floors/GFfinal_boss_floor.tres')
	print("green folio loaded custom barrel room")
	chain.execute_next()
