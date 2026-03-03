@tool
extends StatusEffect

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
var saved_regen := 0

func vanilla_4242834435_apply() -> void:
	if player.stats.gag_regeneration.has(track_name):
		saved_regen = player.stats.gag_regeneration[track_name]
		player.stats.gag_regeneration[track_name] += penalty

func vanilla_4242834435_cleanup() -> void:
	if player.stats.gag_regeneration.has(track_name):
		player.stats.gag_regeneration[track_name] = saved_regen

func vanilla_4242834435_get_description() -> String:
	if player.gags_cost_beans:
		return "Increased %s cost" % track_name
	return "%d %s point regeneration" % [penalty, track_name]

func vanilla_4242834435_get_icon() -> Texture2D:
	return EffectIcons[track_name]

func vanilla_4242834435_combine(effect: StatusEffect) -> bool:
	if effect.track_name == track_name:
		rounds = maxi(rounds, effect.rounds)
		return true
	
	return false


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func apply():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4242834435_apply, [], 2725321737)
	else:
		vanilla_4242834435_apply()


func cleanup():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4242834435_cleanup, [], 2465915979)
	else:
		vanilla_4242834435_cleanup()


func get_description() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4242834435_get_description, [], 2655408102)
	else:
		return vanilla_4242834435_get_description()


func get_icon() -> Texture2D:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4242834435_get_icon, [], 2875014699)
	else:
		return vanilla_4242834435_get_icon()


func combine(effect: StatusEffect) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_4242834435_combine, [effect], 2592839776)
	else:
		return vanilla_4242834435_combine(effect)
