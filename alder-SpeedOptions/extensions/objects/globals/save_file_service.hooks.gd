extends Object

func _ready(chain: ModLoaderHookChain) -> void:
	var raw_idx := 0
	var file_path := SaveFileService.SAVE_FILE_PATH + SaveFileService.SETTINGS_FILE_NAME
	if FileAccess.file_exists(file_path):
		var f = FileAccess.open(file_path, FileAccess.READ)
		for line in f.get_as_text().split("\n"):
			if line.begins_with("battle_speed_idx"):
				raw_idx = int(line.split("=")[1].strip_edges())
				break
		f.close()

	chain.execute_next()

	if SaveFileService.settings_file:
		var settings = SaveFileService.settings_file
		settings.SpeedOptions = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0, 7.5, 10.0, 25.0, 50.0]
		settings.battle_speed_idx = raw_idx
		print("restored battle_speed_idx:", settings.battle_speed_idx)
