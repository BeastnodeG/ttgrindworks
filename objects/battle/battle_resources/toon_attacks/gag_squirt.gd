extends ToonAttack
class_name GagSquirt

const DEBUFF := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_drenched.tres")
const POISON_COLOR := Color(0, 0.43, 0.151)


func vanilla_3449751800_soak_opponent(who: Node3D, from: Node3D, time: float) -> void:
	var splash: Node3D = load('res://models/props/gags/water_splash/water_splash_untextured.tscn').instantiate()
	user.add_child(splash)
	if Util.get_player().stats.has_item('Witch Hat'):
		splash.set_color(POISON_COLOR)
	splash.global_position = from.global_position
	await splash.spray(who.global_position,time)
	splash.queue_free()

func vanilla_3449751800_apply_debuff(target: Cog) -> void:
	var new_effect: StatBoost = DEBUFF.duplicate(true)
	new_effect.target = target
	new_effect.boost = get_player_stats().get_stat('squirt_defense_boost')
	manager.add_status_effect(new_effect)

func vanilla_3449751800_get_player_stats() -> PlayerStats:
	if is_instance_valid(BattleService.ongoing_battle):
		return BattleService.ongoing_battle.battle_stats[Util.get_player()]
	else:
		return Util.get_player().stats

func vanilla_3449751800_get_stats() -> String:
	var string := "Damage: " + get_true_damage() + "\n"\
	+ "Affects: "
	match target_type:
		ActionTarget.SELF:
			string += "Self"
		ActionTarget.ENEMIES:
			string += "All Cogs"
		ActionTarget.ENEMY:
			string += "One Cog"
		ActionTarget.ENEMY_SPLASH:
			string += "Three Cogs"
		
	string += "\nDrenched: %s" % Util.float_to_perc(absf(get_player_stats().get_stat('squirt_defense_boost')))
	
	if Util.get_player().stats.has_item('Witch Hat'):
		string += "\nApplies: Poison"
	
	return string


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func soak_opponent(who: Node3D, from: Node3D, time: float):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_3449751800_soak_opponent, [who, from, time], 2672966168)
	else:
		await vanilla_3449751800_soak_opponent(who, from, time)


func apply_debuff(target: Cog):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3449751800_apply_debuff, [target], 184190505)
	else:
		vanilla_3449751800_apply_debuff(target)


func get_player_stats() -> PlayerStats:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3449751800_get_player_stats, [], 2273134770)
	else:
		return vanilla_3449751800_get_player_stats()


func get_stats() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3449751800_get_stats, [], 2863593798)
	else:
		return vanilla_3449751800_get_stats()
