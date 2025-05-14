extends ItemScript

const BOOST_STATS :={
	'damage': 0.01,
	'speed': -0.02,
	'evasiveness': -0.01
}
var multipliers: Array[StatMultiplier]

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func on_item_removed() -> void:
	for multiplier in multipliers:
		Util.get_player().stats.multipliers.erase(multiplier)

func setup() -> void:
	print("setup time")
	if not Util.get_player():
		await Util.s_player_assigned
	var player := Util.get_player()
	player.stats.s_luck_changed.connect(on_money_changed)
	create_multipliers()
	on_money_changed(player.stats.luck)
	print("printing luck")
	print(player.stats.luck)

## Sync multipliers to current money amount
func on_money_changed(luck) -> void:
	for mult: StatMultiplier in multipliers:
		if mult.stat in BOOST_STATS.keys():
			mult.amount = floori(((luck - 1.0)/2) * 100.0) * BOOST_STATS[mult.stat]

func create_multipliers() -> void:
	print("making multipliers")
	for stat in BOOST_STATS.keys():
		var mult := StatMultiplier.new()
		mult.stat = stat
		mult.amount = 0.0
		mult.additive = true
		multipliers.append(mult)
		Util.get_player().stats.multipliers.append(mult)
