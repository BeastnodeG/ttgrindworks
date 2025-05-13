extends Node

const MOD_DIR := "alder-GreenFolio"
const LOG_NAME := "alder-GreenFolio:Overwrites"

var mod_dir_path := ""

func _init():
	var everything := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/everything.tres")
	var special_items := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/special_items.tres")
	var shop_rewards := preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/shop_rewards.tres")
	var rewards:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/rewards.tres")
	var active_items:= preload("res://mods-unpacked/alder-GreenFolio/overwrites/objects/items/pools/active_items.tres")
	
	everything.take_over_path("res://objects/items/pools/everything.tres")
	special_items.take_over_path("res://objects/items/pools/special_items.tres")
	shop_rewards.take_over_path("res://objects/items/pools/shop_rewards.tres")
	rewards.take_over_path("res://objects/items/pools/rewards.tres")
	active_items.take_over_path("res://objects/items/pools/active_items.tres")
