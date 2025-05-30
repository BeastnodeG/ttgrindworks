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
	# This can now be moved to overwrites.gd
	print("green folio ACTIVATED!!!!!!!!!!!!!!!.")
