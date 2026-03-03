@tool
extends StatusEffect
class_name StatBoost

var ICONS := {
	'damage': load("res://ui_assets/battle/statuses/damage.png"),
	'defense': load("res://ui_assets/battle/statuses/defense.png"),
	'evasiveness': load("res://ui_assets/battle/statuses/evasiveness.png"),
	'luck': load("res://ui_assets/battle/statuses/luck_crit.png"),
}

@export var stat: String = 'defense'
@export var boost: float = 1.0


func vanilla_1728743197_apply():
	var battle_stats: BattleStats = manager.battle_stats[target]
	if stat in battle_stats:
		battle_stats.set(stat,battle_stats.get(stat) + boost)

func vanilla_1728743197_expire():
	var battle_stats = manager.battle_stats[target]
	if stat in battle_stats:
		battle_stats.set(stat, battle_stats.get(stat) - boost) 

func vanilla_1728743197_get_description() -> String:
	return "%s%s%% %s" % ["+" if boost > 0.0 else "-", roundi(abs(boost) * 100), stat[0].to_upper() + stat.substr(1)]

func vanilla_1728743197_get_icon() -> Texture2D:
	return ICONS[stat]

func vanilla_1728743197_get_status_name() -> String:
	return stat[0].to_upper() + stat.substr(1) + (" Up" if boost > 0.0 else " Down")

func vanilla_1728743197_combine(effect: StatusEffect) -> bool:
	if not effect is StatBoost:
		return false
	
	if force_no_combine or effect.force_no_combine:
		return false

	if effect is StatBoost:
		if effect.stat == stat and effect.rounds == rounds and get_quality() == effect.get_quality():
			expire()
			boost = get_combined_boost(boost, effect.boost)
			apply()
			return true
	
	return false

func vanilla_1728743197_get_quality() -> EffectQuality:
	if boost >= 0.0:
		return EffectQuality.POSITIVE
	return EffectQuality.NEGATIVE

func vanilla_1728743197_randomize_effect() -> void:
	stat = ICONS.keys().pick_random()
	rounds = randi_range(1, 3)
	boost = randf_range(-0.25, 0.25)
	if boost > 0.0:
		quality = StatusEffect.EffectQuality.POSITIVE
	else:
		quality = StatusEffect.EffectQuality.NEGATIVE

func vanilla_1728743197_get_combined_boost(boost1: float, boost2: float) -> float:
	return boost1 + boost2


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func apply():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_apply, [], 2423725923)
	else:
		return vanilla_1728743197_apply()


func expire():
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_expire, [], 2839569674)
	else:
		return vanilla_1728743197_expire()


func get_description() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_get_description, [], 1149488064)
	else:
		return vanilla_1728743197_get_description()


func get_icon() -> Texture2D:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_get_icon, [], 628734789)
	else:
		return vanilla_1728743197_get_icon()


func get_status_name() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_get_status_name, [], 3459996608)
	else:
		return vanilla_1728743197_get_status_name()


func combine(effect: StatusEffect) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_combine, [effect], 572512826)
	else:
		return vanilla_1728743197_combine(effect)


func get_quality() -> StatusEffect.EffectQuality:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_get_quality, [], 1448857797)
	else:
		return vanilla_1728743197_get_quality()


func randomize_effect():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1728743197_randomize_effect, [], 1876629138)
	else:
		vanilla_1728743197_randomize_effect()


func get_combined_boost(boost1: float, boost2: float) -> float:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1728743197_get_combined_boost, [boost1, boost2], 1344093123)
	else:
		return vanilla_1728743197_get_combined_boost(boost1, boost2)
