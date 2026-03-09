extends Node
class_name GFGlobalprogress

const PROGRESS_RESOURCE_PATH := "res://mods-unpacked/alder-GreenFolio/GFprogress.gd"
const PROGRESS_FILE_NAME := "GFprogress.tres"

var _resource: Resource

func _init() -> void:
	_resource = load(PROGRESS_RESOURCE_PATH).new()

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

func save_progress():
	ResourceSaver.save(_resource, SaveFileService.SAVE_FILE_PATH + PROGRESS_FILE_NAME)
	print("green folio progress file saved")

func load_progress():
	print("loading green folio progress")
	var file_path = SaveFileService.SAVE_FILE_PATH + PROGRESS_FILE_NAME
	if FileAccess.file_exists(file_path):
		var progress_loaded = ResourceLoader.load(file_path)
		if progress_loaded:
			_resource = progress_loaded
			print("green folio progress file loaded")
		else:
			print("failed to load GF progress, starting fresh.")
			var broken_file_path = "GFprogress_BROKEN.tres" + SaveFileService.SAVE_FILE_PATH
			DirAccess.rename_absolute(file_path, broken_file_path)
			_resource = load(PROGRESS_RESOURCE_PATH).new()
			_resource.folio_unlocked = 1
			save_progress()
	else:
		print("couldn't find GF progress, starting fresh.")
		_resource = load(PROGRESS_RESOURCE_PATH).new()
		_resource.folio_unlocked = 1
		save_progress()
