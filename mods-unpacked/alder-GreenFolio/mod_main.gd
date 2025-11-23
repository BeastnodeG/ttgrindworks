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
	ModLoaderMod.install_script_hooks("res://objects/general_ui/settings_menu/settings_menu.gd", extensions_dir_path.path_join("objects/general_ui/settings_menu/settings_menu.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://scenes/game_floor/game_floor.gd", extensions_dir_path.path_join("scenes/game_floor/game_floor.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/player/ui/anomaly_icon.gd", extensions_dir_path.path_join("objects/player/ui/anomaly_icon.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://scenes/game_floor/floor_variants/floor_variant.gd", extensions_dir_path.path_join("scenes/game_floor/floor_variants/floor_variant.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/toon_attacks/gag_squirt.gd", extensions_dir_path.path_join("objects/battle/battle_resources/toon_attacks/gag_squirt.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/items/custom/fire_hydrant/item_fire_hydrant.gd", extensions_dir_path.path_join("objects/items/custom/fire_hydrant/item_fire_hydrant.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/status_effects/stat_boost.gd", extensions_dir_path.path_join("objects/battle/battle_resources/status_effects/stat_boost.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/status_effects/status_effect_budget_cuts.gd", extensions_dir_path.path_join("objects/battle/battle_resources/status_effects/status_effect_budget_cuts.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/misc_movies/traffic_manager/status_effect_red_light.gd", extensions_dir_path.path_join("objects/battle/battle_resources/misc_movies/traffic_manager/status_effect_red_light.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://scenes/final_boss/penthouse_boss.gd", extensions_dir_path.path_join("scenes/final_boss/penthouse_boss.hooks.gd"))
	if not ModLoaderMod.is_mod_loaded("CrazyMew37-EndlessMode"):
		print("endless not installed, hooking elevator")
		ModLoaderMod.install_script_hooks("res://scenes/elevator_scene/elevator_scene.gd", extensions_dir_path.path_join("scenes/elevator_scene/elevator_scene.hooks.gd"))
	else:
		print("endless mode installed, skipping elevator_scene hook")
func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")

func _add_global_class():
	var GFGlobal = load("res://mods-unpacked/alder-GreenFolio/GFglobal.gd").new()
	GFGlobal.name = "GFglobal"
	add_child(GFGlobal)
	
	var GFprogress = load("res://mods-unpacked/alder-GreenFolio/GFglobalprogress.gd").new()
	GFprogress.name = "GFprogress"
	add_child(GFprogress)

func _ready() -> void:
	Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/flutterby.tres")
	Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/nedslinger.tres")
	#Globals.ADDITIONAL_TOON_PATHS.append("res://mods-unpacked/alder-GreenFolio/extensions/objects/player/character/sofiesquirt.tres")
	
	Globals.additional_floors.append(load("res://mods-unpacked/alder-GreenFolio/extensions/scenes/floor_variants/sewers.tres"))
	
#a resource file is probably a more sane way to do this. i just like the convinence of this though :)
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
		"battoon_cape": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/accessories/backpacks/battoon_cape.tres",
		"turn_box": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/active/turn_box.tres",
		"jollyboots": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/accessories/foot/jollyboots/jollyboots.tres",
		"cannon": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/toonups/cannon.tres",
		"space_helmet": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/accessories/hats/atomichat/space_helmet.tres",
		"starboots": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/accessories/foot/starboots/starboots.tres",
		"thegray": "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/thegrey.tres",
		"rewardoptions" : "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/carrossel_rewards.tres",
		"progressoptions" : "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/carrossel_progressive.tres",
		"monoalien" : "res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/monoalien_glasses.tres",
	}

	var pool_memberships := {
		"special_items.tres": ["battoon_cape", "alphabet_soup", "taser", "space_helmet"],
		"shop_rewards.tres": ["progressoptions", "rewardoptions", "jollyboots", "taser", "opossum_tail", "lightbulb", "green_deal", "paint_brush"],
		"shop_progressives.tres": ["cannon", "paintball"],
		"rewards.tres": ["monoalien", "turn_box", "starboots", "lightbulb", "opossum_tail", "paint_brush"],
		"progressives.tres": ["cannon", "paintball"],
		"floor_clears.tres": ["jollyboots", "opossum_tail", "lightbulb"],
		"everything.tres": ["progressoptions", "rewardoptions", "monoalien", "thegray", "starboots", "jollyboots", "space_helmet", "turn_box", "battoon_cape", "lightbulb", "taser", "joybuzzer", "opossum_tail", "paintball", "alphabet_soup", "paint_brush", "monarch_butterfly", "green_deal"],
		"battle_clears.tres": [],
		"active_items.tres": ["alphabet_soup", "paint_brush", "monarch_butterfly", "green_deal", "turn_box"],
		"accessories.tres": ["monoalien", "progressoptions", "rewardoptions", "thegray", "starboots", "jollyboots", "taser", "lightbulb", "opossum_tail", "battoon_cape", "space_helmet"],
		"stranger_items.tres": ["monoalien", "thegray", "green_deal", "space_helmet", "battoon_cape", "monarch_butterfly"]
	}

	for pool_name in pool_memberships:
		var pool: Object = ItemService.pool_from_path("res://objects/items/pools/%s" % pool_name)
		if not pool:
			push_error("Missing pool: %s" % pool_name)
			continue

		for item_name in pool_memberships[pool_name]:
			var item_path = item_paths.get(item_name, "")
			if item_path and item_path not in pool.items:
				pool.items.append(item_path)
				var item = load(item_path)
				if item:
					print("Added %s to %s" % [item.item_name, pool_name])
				else:
					push_error("Failed to load item at: %s" % item_path)
				
	var anomaly_paths := {
		"positive": [
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_packrat.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_budgetsurplus.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_prankovercharged.gd",
		],
		"neutral": [
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_experimental_hardware.gd",
		],
		"negative": [
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_sadmosphere.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_shakedown.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_budgetcuts.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_vertigo.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_chestexplosion.gd",
			"res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_prankpoweroutage.gd",
		],
	}
	
	for anomaly in anomaly_paths["positive"]:
		if anomaly not in FloorVariant.ANOMALIES_POSITIVE:
			FloorVariant.ANOMALIES_POSITIVE.append(anomaly)
			print("Added positive anomaly: %s" % anomaly)
			
	for anomaly in anomaly_paths["neutral"]:
		if anomaly not in FloorVariant.ANOMALIES_NEUTRAL:
			FloorVariant.ANOMALIES_NEUTRAL.append(anomaly)
			print("Added neutral anomaly: %s" % anomaly)
			
	for anomaly in anomaly_paths["negative"]:
		if anomaly not in FloorVariant.ANOMALIES_NEGATIVE:
			FloorVariant.ANOMALIES_NEGATIVE.append(anomaly)
			print("Added negative anomaly: %s" % anomaly)
	print("green folio setup complete")
