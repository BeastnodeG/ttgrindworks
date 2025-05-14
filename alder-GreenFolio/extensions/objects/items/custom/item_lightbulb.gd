extends ItemScript

const BOOST_STATS := {
	"damage": 0.05,
	"speed": 0.05,
	"evasiveness": 0.05,
	"defense": 0.05,
	"luck": 0.05
}

var multipliers: Array[StatMultiplier] = []
var last_was_charged := false

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func on_item_removed() -> void:
	for mult in multipliers:
		mult.amount = 0.0

func setup() -> void:
	if not Util.get_player():
		await Util.s_player_assigned
	create_multipliers()
	set_process(true)

func create_multipliers() -> void:
	var stats = Util.get_player().stats

	for stat in BOOST_STATS.keys():
		var mult := StatMultiplier.new()
		mult.stat = stat
		mult.amount = 0.0
		mult.additive = true
		multipliers.append(mult)
		stats.multipliers.append(mult)

#i hate process but i also don't want to do a hook
#oh well!
func _process(_delta: float) -> void:
	var player = Util.get_player()
	var item = player.stats.current_active_item
	var charged = item and item.current_charge >= item.charge_count

	if charged != last_was_charged:
		last_was_charged = charged
		for mult in multipliers:
			mult.amount = BOOST_STATS[mult.stat] if charged else 0.0
