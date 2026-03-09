extends Node
class_name GFglobal

const SAVE_RESOURCE_PATH := "res://mods-unpacked/alder-GreenFolio/GFcurrent_save.gd"
const SAVE_FILE_NAME := "GFcurrent_save.tres"

var _resource: Resource

func _init() -> void:
	_resource = load(SAVE_RESOURCE_PATH).new()

func _get(property_name: StringName) -> Variant:
	if _resource:
		return _resource.get(property_name)
	return null

func _set(property_name: StringName, value: Variant) -> bool:
	if _resource:
		var props = _resource.get_property_list()
		for p in props:
			if p.name == property_name:
				_resource.set(property_name, value)
				return true
	return false

func _get_property_list() -> Array[Dictionary]:
	if _resource:
		return _resource.get_property_list()
	return []

func save_to():
	ResourceSaver.save(_resource, SaveFileService.SAVE_FILE_PATH + SAVE_FILE_NAME)
	print("green folio saved to: ", SaveFileService.SAVE_FILE_PATH + SAVE_FILE_NAME)
	
func load_save():
	print("loading green folio save")
	var file_path = SaveFileService.SAVE_FILE_PATH + SAVE_FILE_NAME
	if FileAccess.file_exists(file_path):
		var save_loaded = ResourceLoader.load(file_path)
		if save_loaded:
			_resource = save_loaded
			print("green folio save loaded successfully")
		else:
			print("Failed to load green folio save file.")
	else:
		print("green folio save file not found")

func delete_save():
	print("deleting green folio save")
	var file_path = SaveFileService.SAVE_FILE_PATH + SAVE_FILE_NAME
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("green folio save deleted")
	else:
		print("green folio save file not found")
	reset_stats()

func reset_stats():
	print("resetting green folio stats")
	_resource = load(SAVE_RESOURCE_PATH).new()
	
	var player = Util.get_player()
	if player: #EVIL GREEN FOLIO - I WILL modify the VANILLA CURRENT SAVE file!!!!!!!!!!
		player.stats.toonups[7] = 1
