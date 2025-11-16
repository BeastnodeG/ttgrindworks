# GFprogress.gd
extends Node
class_name GFGlobalprogress

var folio_unlocked: int = 0

func save_progress():
	var GFProgress = preload("res://mods-unpacked/alder-GreenFolio/GFprogress.gd")
	var file_name = "GFprogress.tres"
	
	var progress_data = GFProgress.new()
	progress_data.folio_unlocked = folio_unlocked
	
	ResourceSaver.save(progress_data, SaveFileService.SAVE_FILE_PATH + file_name)
	print("green folio progress file saved")

func load_progress():
	print("loading green folio progress")
	var file_path = SaveFileService.SAVE_FILE_PATH + "GFprogress.tres"
	if FileAccess.file_exists(file_path):
		var progress_loaded = ResourceLoader.load(file_path)
		if progress_loaded:
			folio_unlocked = progress_loaded.folio_unlocked
			print("green folio progress file loaded")
		else:
			print("failed to load GF progress, starting fresh.")
			var broken_file_path = "GFprogress_BROKEN.tres" + SaveFileService.SAVE_FILE_PATH
			DirAccess.rename_absolute(file_path, broken_file_path)
			folio_unlocked = 1
			save_progress()
	else:
		print("couldn't find GF progress, starting fresh.")
		folio_unlocked = 1
		save_progress()
