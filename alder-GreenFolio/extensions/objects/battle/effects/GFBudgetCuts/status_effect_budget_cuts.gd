@tool
extends StatusEffect

#unused because im a stupid idiot and forgot i could just hook the vanilla script

const EffectIcons: Dictionary = {
	"Trap": preload("res://ui_assets/battle/statuses/budget_trap.png"),
	"Lure": preload("res://ui_assets/battle/statuses/budget_lure.png"),
	"Sound": preload("res://ui_assets/battle/statuses/budget_sound.png"),
	"Squirt": preload("res://ui_assets/battle/statuses/budget_squirt.png"),
	"Throw": preload("res://ui_assets/battle/statuses/budget_throw.png"),
	"Drop": preload("res://ui_assets/battle/statuses/budget_drop.png"),
}

@export var track_name: String
@export var penalty := -2

var player: Player:
	get: return target

func apply() -> void:
	if player.stats.gag_regeneration.has(track_name):
		player.stats.gag_regeneration[track_name] += penalty

func cleanup() -> void:
	if player.stats.gag_regeneration.has(track_name):
		player.stats.gag_regeneration[track_name] -= penalty

func get_description() -> String:
	if player.gags_cost_beans:
		return "Increased %s cost" % track_name
	return "%d %s point regeneration" % [penalty, track_name]

func get_icon() -> Texture2D:
	return EffectIcons[track_name]
