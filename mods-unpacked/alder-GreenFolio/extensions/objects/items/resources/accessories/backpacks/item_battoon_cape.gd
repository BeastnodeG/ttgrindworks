extends ItemScript

const MULTIPLIERS := {
	"speed": 0.1,
	"evasiveness": 0.1,
	"defense": -0.1,
}

var applied: Array[StatMultiplier] = []

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func on_item_removed() -> void:
	var player := Util.get_player()
	if player:
		for mult in applied:
			player.stats.multipliers.erase(mult)
	applied.clear()

func setup() -> void:
	if not Util.get_player():
		await Util.s_player_assigned

	var player := Util.get_player()

	for stat in MULTIPLIERS.keys():
		var mult := StatMultiplier.new()
		mult.stat = stat
		mult.amount = MULTIPLIERS[stat]
		mult.additive = false
		player.stats.multipliers.append(mult)
		applied.append(mult)
