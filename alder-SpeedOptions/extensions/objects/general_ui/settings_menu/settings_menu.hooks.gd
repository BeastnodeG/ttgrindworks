extends Object

func backup_prev_settings(chain: ModLoaderHookChain) -> void:
	var menu = chain.reference_object
	
	var speed_idx = SaveFileService.settings_file.battle_speed_idx
	var speed_options = SaveFileService.settings_file.SpeedOptions

	chain.execute_next()

	menu.prev_file.SpeedOptions = speed_options
	menu.prev_file.battle_speed_idx = speed_idx
