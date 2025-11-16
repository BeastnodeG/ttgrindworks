@tool
extends StatusEffect
class_name StatusEffectExtraTurns

@export var extra_turns := 1

func apply() -> void:
	var stats : PlayerStats = manager.battle_stats[target]
	stats.turns += extra_turns
	BattleService.ongoing_battle.battle_ui.refresh_turns()

func get_description() -> String:
	if extra_turns == 1:
		return "+1 turn"
	return "+%s turns" % extra_turns

func cleanup() -> void:
	if not target: return
	var stats : PlayerStats = manager.battle_stats[target]
	stats.turns -= extra_turns
	BattleService.ongoing_battle.battle_ui.refresh_turns()

func combine(effect : StatusEffect) -> bool:
	if effect.get_script() == get_script() and rounds == effect.rounds:
		cleanup()
		extra_turns += effect.extra_turns
		apply()
		return true
	return false
