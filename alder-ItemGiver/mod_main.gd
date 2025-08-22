extends Node


const MOD_DIR := "alder-ItemGiver"
const LOG_NAME := "alder-ItemGiver:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	install_script_extensions()
	install_script_hook_files()

	add_translations()


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")


func install_script_hook_files() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_hooks("res://objects/pause_menu/pause_menu.gd", extensions_dir_path.path_join("objects/pause_menu/pause_menu.hooks.gd"))



func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	pass
