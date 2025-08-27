extends StatusEffect

const STAT_PERCENT := 1.25
const STATS := ["damage", "defense"]
const DEFENSE_CAP := 10.0

var current_boost := 1.0
var defense_capped := false

func _update_boost():
	var player := Util.get_player()
	if not player:
		return

	var money := player.stats.money
	var percent := int(floor(money / STAT_PERCENT))
	current_boost = 1.0 + percent * 0.01

	defense_capped = current_boost > DEFENSE_CAP
	if defense_capped:
		current_boost = DEFENSE_CAP

func apply():
	_update_boost()

	var battle_stats: BattleStats = manager.battle_stats.get(target)
	if not battle_stats:
		return

	for stat in STATS:
		if stat in battle_stats:
			battle_stats.set(stat, battle_stats.get(stat) * current_boost)

func expire():
	var battle_stats: BattleStats = manager.battle_stats.get(target)
	if not battle_stats:
		return

	for stat in STATS:
		if stat in battle_stats:
			battle_stats.set(stat, battle_stats.get(stat) / current_boost)

func get_description() -> String:
	var bonus := int((current_boost - 1.0) * 100.0)
	var desc := "Your wealth is its power.\n"
	desc += "+%d%% Damage\n" % bonus
	desc += "+%d%% Defense%s" % [bonus, " (Capped)" if defense_capped else ""]
	return desc

func get_quality() -> EffectQuality:
	return EffectQuality.POSITIVE
