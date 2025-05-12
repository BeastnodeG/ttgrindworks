extends Node
class_name GFglobal

var green_deal_strength = 2.5
var monarch_absorbed_items : Array[Dictionary] = [{ "name": "The Monarch", "qualitoon": 1 },]

# Save function
func save_to():
	var GFSaveData = preload("res://mods-unpacked/alder-GreenFolio/GFSaveData.gd")
	var file_name = "GFcurrent_save.tres"
	
	var save_data = GFSaveData.new()
	save_data.green_deal_strength = green_deal_strength
	save_data.monarch_absorbed_items = monarch_absorbed_items

	ResourceSaver.save(save_data, SaveFileService.SAVE_FILE_PATH + file_name)
	print("green folio saved to: ", SaveFileService.SAVE_FILE_PATH + file_name)
	
func load_save():
	print("loading green folio save")
	var file_path = SaveFileService.SAVE_FILE_PATH + "GFcurrent_save.tres"
	if FileAccess.file_exists(file_path):
		var loaded = ResourceLoader.load(file_path)
		if loaded:
			green_deal_strength = loaded.green_deal_strength
			monarch_absorbed_items = loaded.monarch_absorbed_items
			print("green folio save loaded successfully")
		else:
			print("Failed to load green folio save file.")
	else:
		print("green folio save file not found")

func delete_save():
	print("deleting green folio save")
	var file_path = SaveFileService.SAVE_FILE_PATH + "GFcurrent_save.tres"
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("green folio save deleted")
	else:
		print("green folio save file not found")
	reset_stats()

func reset_stats():
	print("resetting green folio stats")
	green_deal_strength = 2.5
	monarch_absorbed_items = [{ "name": "The Monarch", "qualitoon": 1 },]
