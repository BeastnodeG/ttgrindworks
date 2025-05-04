extends Object

func get_hazard_damage(chain: ModLoaderHookChain, damage: int) -> int:
	var floor_number = chain.reference_object.floor_number
	var true_damage = damage + (-(floor_number + 1) * 1)
	
	var fm = chain.reference_object.floor_manager
	if is_instance_valid(fm) and fm.floor_tags.get("extra_hazard_damage", false):
		true_damage = floori(1.250 * true_damage) #(0.625 * true_damage)
	
	return true_damage
