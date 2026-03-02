extends Node


const MOD_DIR := "alder-SpeedOptions"
const LOG_NAME := "alder-SpeedOptions:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


func _init() -> void:
	SettingsFile.add_battle_speed(2.5)
	SettingsFile.add_battle_speed(3.0)
	SettingsFile.add_battle_speed(4.0)
	SettingsFile.add_battle_speed(5.0)
	SettingsFile.add_battle_speed(7.5)
	SettingsFile.add_battle_speed(10.0)
	SettingsFile.add_battle_speed(25.0)

func _ready() -> void:
	pass
