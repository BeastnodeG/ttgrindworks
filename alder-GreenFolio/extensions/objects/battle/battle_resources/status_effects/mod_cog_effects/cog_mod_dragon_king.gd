extends StatusEffect

const STAT_PERCENT := 1.25
const STATS := ["damage", "defense"]
const DEFENSE_CAP := 9.0
const DAMAGE_CAP := 5.0

var current_boost := 1.0
var defense_capped := false
var damage_capped := false

func update_boost():
	var player := Util.get_player()
	if not player:
		return
	
	var money := player.stats.money
	var percent := int(floor(money / STAT_PERCENT))
	current_boost = 1.0 + percent * 0.01
	
	# Check caps for both stats
	defense_capped = current_boost > DEFENSE_CAP
	damage_capped = current_boost > DAMAGE_CAP

func apply():
	update_boost()
	var battle_stats: BattleStats = manager.battle_stats.get(target)
	if not battle_stats:
		return

	for stat in STATS:
		if stat in battle_stats:
			var boost_to_apply := current_boost
			
			# Apply appropriate cap for each stat
			if stat == "defense" and defense_capped:
				boost_to_apply = DEFENSE_CAP
			elif stat == "damage" and damage_capped:
				boost_to_apply = DAMAGE_CAP
			
			battle_stats.set(stat, battle_stats.get(stat) * boost_to_apply)

func expire():
	var battle_stats: BattleStats = manager.battle_stats.get(target)
	if not battle_stats:
		return

	for stat in STATS:
		if stat in battle_stats:
			var boost_to_remove := current_boost
			
			# Remove the same boost that was applied
			if stat == "defense" and defense_capped:
				boost_to_remove = DEFENSE_CAP
			elif stat == "damage" and damage_capped:
				boost_to_remove = DAMAGE_CAP
			
			battle_stats.set(stat, battle_stats.get(stat) / boost_to_remove)

func get_description() -> String:
	var damage_boost := current_boost
	var defense_boost := current_boost
	
	# Apply caps for display
	if damage_capped:
		damage_boost = DAMAGE_CAP
	if defense_capped:
		defense_boost = DEFENSE_CAP
	
	var damage_bonus := int((damage_boost - 1.0) * 100.0)
	var defense_bonus := int((defense_boost - 1.0) * 100.0)
	
	var desc := "Your wealth is its power.\n"
	desc += "+%d%% Damage%s\n" % [damage_bonus, " (Capped)" if damage_capped else ""]
	desc += "+%d%% Defense%s" % [defense_bonus, " (Capped)" if defense_capped else ""]
	return desc

func get_quality() -> EffectQuality:
	return EffectQuality.POSITIVE
