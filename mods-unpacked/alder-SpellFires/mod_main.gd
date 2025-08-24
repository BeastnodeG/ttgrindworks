extends Node


const MOD_DIR := "alder-SpellFires"
const LOG_NAME := "alder-SpellFires:Main"

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


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")


func install_script_hook_files() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_ui/battle_ui.gd", extensions_dir_path.path_join("objects/battle/battle_ui/battle_ui.hooks.gd"))
	ModLoaderMod.install_script_hooks("res://objects/battle/battle_resources/toon_attacks/attack_fire.gd", extensions_dir_path.path_join("objects/battle/battle_resources/toon_attacks/attack_fire.hooks.gd"))



func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	pass
