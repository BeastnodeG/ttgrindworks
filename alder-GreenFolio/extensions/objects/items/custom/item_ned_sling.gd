extends ItemScript

const TARGET_STAT := "damage"
const MULTIPLIER_AMOUNT := -0.5

var multiplier: StatMultiplier
var last_known_turns: int = 2

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func on_item_removed() -> void:
	if multiplier:
		Util.get_player().stats.multipliers.erase(multiplier)

func setup() -> void:
	if not Util.get_player():
		await Util.s_player_assigned

	var player := Util.get_player()

	if not multiplier:
		multiplier = StatMultiplier.new()
		multiplier.stat = TARGET_STAT
		multiplier.amount = MULTIPLIER_AMOUNT
		multiplier.additive = false
		player.stats.multipliers.append(multiplier)

	BattleService.s_battle_initialized.connect(on_battle_change)
	BattleService.s_round_ended.connect(on_battle_change)

func on_battle_change(_arg = null) -> void:
	var player := Util.get_player()
	if not player:
		return

	var current_turns = player.stats.turns
	if current_turns > last_known_turns:
		print("incrementing turns")
		player.stats.turns += 1
	last_known_turns = player.stats.turns
