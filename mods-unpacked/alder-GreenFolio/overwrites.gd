extends Node

const MOD_DIR := "alder-GreenFolio"
const LOG_NAME := "alder-GreenFolio:Overwrites"

var mod_dir_path := ""

func _init():
	#pass
	
	var toonup := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/gag_loadouts/gag_tracks/toon_up.tres")
	toonup.take_over_path("res://objects/battle/battle_resources/gag_loadouts/gag_tracks/toon_up.tres")
	
	#no longer needed, thanks evan!
	#var everything := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/everything.tres")
	#var special_items := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/special_items.tres")
	#var shop_rewards := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/shop_rewards.tres")
	#var rewards:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/rewards.tres")
	#var active_items:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/active_items.tres")
	#var progressives:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/progressives.tres")
	#var shop_progressives:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/shop_progressives.tres")
	#var battle_clears:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/battle_clears.tres")
	#var floor_clears:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/floor_clears.tres")
	#var accessories:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/accessories.tres")
	#
	#everything.take_over_path("res://objects/items/pools/everything.tres")
	#special_items.take_over_path("res://objects/items/pools/special_items.tres")
	#shop_rewards.take_over_path("res://objects/items/pools/shop_rewards.tres")
	#rewards.take_over_path("res://objects/items/pools/rewards.tres")
	#active_items.take_over_path("res://objects/items/pools/active_items.tres")
	#progressives.take_over_path("res://objects/items/pools/progressives.tres")
	#shop_progressives.take_over_path("res://objects/items/pools/shop_progressives.tres")
	#battle_clears.take_over_path("res://objects/items/pools/battle_clears.tres")
	#floor_clears.take_over_path("res://objects/items/pools/floor_clears.tres")
	#accessories.take_over_path("res://objects/items/pools/accessories.tres")
