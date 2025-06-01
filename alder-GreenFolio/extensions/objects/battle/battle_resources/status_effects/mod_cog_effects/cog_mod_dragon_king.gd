extends StatusEffect

const STAT_PERCENT := 2
const STATS := ["damage", "defense"]

var current_boost := 1.0

func _update_boost():
	var player := Util.get_player()
	if not player:
		return

	var money := player.stats.money
	var percent := int(floor(money / STAT_PERCENT))
	current_boost = 1.0 + percent * 0.01

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
	return "Your wealth is its power.\n+%d%% Damage\n+%d%% Defense" % [bonus, bonus]

func get_quality() -> EffectQuality:
	return EffectQuality.POSITIVE
