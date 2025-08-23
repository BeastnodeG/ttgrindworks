extends Node

const MOD_DIR := "alder-GreenFolio"
const LOG_NAME := "alder-GreenFolio:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	# Add extensions
	install_script_extensions()
	install_script_hook_files()

	# Add translations
	add_translations()

	#add "global class"
	_add_global_class()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")

func install_script_hook_files() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	print("installing script hooks")
	ModLoaderMod.install_script_hooks("res://objects/globals/save_file_service.gd", extensions_dir_path.path_join("objects/globals/save_file_service.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/player/player.gd", extensions_dir_path.path_join("objects/player/player.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://scenes/title_screen/title_screen.gd", extensions_dir_path.path_join("scenes/title_screen/title_screen.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/status_effects/mod_cog_effects/status_effect_mod_cog.gd", extensions_dir_path.path_join("objects/battle/battle_resources/status_effects/mod_cog_effects/status_effect_mod_cog.hooks.gd"))

func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")

func _add_global_class():
	var global_instance = load("res://mods-unpacked/alder-GreenFolio/GFglobal.gd").new()
	global_instance.name = "GFglobal"
	add_child(global_instance)

func _ready() -> void:
	Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/flutterby.tres")
	Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/nedslinger.tres")
	Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/sofiesquirt.tres")
	print("green folio ACTIVATED!!!!!!!!!!!!!!!")

	var item_paths := {
		"taser": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/taser.tres",
		"opossum_tail": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/opossum_tail.tres",
		"lightbulb": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/lightbulb.tres",
		"joybuzzer": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/joybuzzer.tres",
		"parry_glower": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/parry_glower.tres",
		"paint_brush": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/paint_brush.tres",
		"paintball": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/paintball.tres",
		"monarch_butterfly": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/monarch_butterfly.tres",
		"green_deal": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/green_deal.tres",
		"alphabet_soup": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/alphabet_soup.tres",
	}

	var pool_memberships := {
		"special_items.tres": ["green_deal", "monarch_butterfly", "alphabet_soup", "paint_brush", "taser", "joybuzzer"],
		"shop_rewards.tres": ["taser", "opossum_tail", "lightbulb", "joybuzzer", "green_deal", "paint_brush",],
		"shop_progressives.tres": ["paintball"],
		"rewards.tres": ["lightbulb", "opossum_tail", "green_deal"],
		"progressives.tres": ["paintball"],
		"floor_clears.tres": ["opossum_tail", "joybuzzer", "lightbulb"],
		"everything.tres": ["lightbulb", "taser", "joybuzzer", "opossum_tail", "paintball", "alphabet_soup", "paint_brush", "monarch_butterfly, green_deal"],
		"battle_clears.tres": [],
		"active_items.tres": ["alphabet_soup", "paint_brush", "monarch_butterfly", "green_deal"],
		"accessories.tres": ["taser", "lightbulb", "opossum_tail", "joybuzzer"],
	}

	for pool_name in pool_memberships:
		var pool: Object = ItemService.pool_from_path("res://objects/items/pools/%s" % pool_name)
		if not pool:
			push_error("Missing pool: %s" % pool_name)
			continue

		for item_name in pool_memberships[pool_name]:
			var item := load(item_paths.get(item_name, ""))
			if item and item not in pool.items:
				pool.items.append(item)
				print("Added %s to %s" % [item.item_name, pool_name])
