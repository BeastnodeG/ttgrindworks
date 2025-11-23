extends Node
class_name GFglobal

var green_deal_strength: float = 2.5
var monarch_absorbed_items : Array[Dictionary] = [{ "name": "The Monarch", "qualitoon": 1 },]
var squirt_splash: bool = true
var taser_count: int = 0
var folio_level: int = 0
var atomic_effect: String = "plutonium"

var carrossel_progressive_item_count: int = 1
var carrossel_progressive_cycle_duration: float = 2.0
var carrossel_reward_item_count: int = 1
var carrossel_reward_cycle_duration: float = 2.0

func save_to():
	var GFSaveData = preload("res://mods-unpacked/alder-GreenFolio/GFcurrent_save.gd")
	var file_name = "GFcurrent_save.tres"
	
	var current_save_data = GFSaveData.new()
	current_save_data.green_deal_strength = green_deal_strength
	current_save_data.monarch_absorbed_items = monarch_absorbed_items
	current_save_data.taser_count = taser_count
	current_save_data.squirt_splash = squirt_splash
	current_save_data.folio_level = folio_level
	current_save_data.atomic_effect = atomic_effect
	current_save_data.carrossel_progressive_item_count = carrossel_progressive_item_count
	current_save_data.carrossel_progressive_cycle_duration = carrossel_progressive_cycle_duration
	current_save_data.carrossel_reward_item_count = carrossel_reward_item_count
	current_save_data.carrossel_reward_cycle_duration = carrossel_reward_cycle_duration

	ResourceSaver.save(current_save_data, SaveFileService.SAVE_FILE_PATH + file_name)
	print("green folio saved to: ", SaveFileService.SAVE_FILE_PATH + file_name)
	
func load_save():
	print("loading green folio save")
	var file_path = SaveFileService.SAVE_FILE_PATH + "GFcurrent_save.tres"
	if FileAccess.file_exists(file_path):
		var current_save_loaded = ResourceLoader.load(file_path)
		if current_save_loaded:
			green_deal_strength = current_save_loaded.green_deal_strength
			monarch_absorbed_items = current_save_loaded.monarch_absorbed_items
			taser_count = current_save_loaded.taser_count
			squirt_splash = current_save_loaded.squirt_splash
			folio_level = current_save_loaded.folio_level
			atomic_effect = current_save_loaded.atomic_effect
			carrossel_progressive_item_count = current_save_loaded.carrossel_progressive_item_count
			carrossel_progressive_cycle_duration = current_save_loaded.carrossel_progressive_cycle_duration
			carrossel_reward_item_count = current_save_loaded.carrossel_reward_item_count
			carrossel_reward_cycle_duration = current_save_loaded.carrossel_reward_cycle_duration
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
	taser_count = 0
	squirt_splash = true
	folio_level = 0
	atomic_effect = "plutonium"
	
	carrossel_progressive_item_count = 1
	carrossel_progressive_cycle_duration = 2.0
	carrossel_reward_item_count = 1
	carrossel_reward_cycle_duration = 2.0
	
	var player = Util.get_player()
	if player: #EVIL GREEN FOLIO - I WILL modify the VANILLA CURRENT SAVE file!!!!!!!!!!
		player.stats.toonups[7] = 1
