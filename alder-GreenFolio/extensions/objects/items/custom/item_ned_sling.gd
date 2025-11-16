extends ItemScript

const TARGET_STAT := "damage"
const MULTIPLIER_AMOUNT := -0.5

var multiplier: StatMultiplier
var last_known_turns: int = 2
var last_known_regen: int = 2

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	print("loaded")
	setup()

func on_item_removed() -> void:
	if multiplier:
		Util.get_player().stats.multipliers.erase(multiplier)

func setup() -> void:
	if not Util.get_player():
		await Util.s_player_assigned
	
	var player := Util.get_player()
	
	last_known_turns = player.stats.turns
	last_known_regen = player.stats.gag_regeneration[player.stats.gag_regeneration.keys()[0]]
	print("printing last known turns and regen")
	print(last_known_regen)
	print(last_known_turns)
	
	if not multiplier:
		multiplier = StatMultiplier.new()
		multiplier.stat = TARGET_STAT
		multiplier.amount = MULTIPLIER_AMOUNT
		multiplier.additive = false
		player.stats.multipliers.append(multiplier)

	BattleService.s_battle_initialized.connect(on_battle_change)
	#BattleService.s_round_ended.connect(on_battle_change)

func on_battle_change(_arg = null) -> void:
	var player := Util.get_player()
	if not player:
		return

	var current_turns = player.stats.turns
	#yes this implementation is weird. i don't care anymore
	if current_turns > last_known_turns and current_turns % 2 != 0:
		print("incrementing turns")
		player.stats.turns += 1
	last_known_turns = player.stats.turns

	var gags = player.stats.gag_regeneration
	var first_track = gags.keys()[0]
	var current_regen = gags[first_track]
	if current_regen > last_known_regen and current_regen % 2 != 0:
		print("incrementing gag regen")
		for track in gags.keys():
			gags[track] += 1
	last_known_regen = gags[first_track]
