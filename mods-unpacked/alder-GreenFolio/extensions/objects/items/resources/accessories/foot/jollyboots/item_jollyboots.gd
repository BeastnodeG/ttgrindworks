extends ItemScript

const HEAL_AMOUNT := 0.05

var applied: Array[StatMultiplier] = []

func on_collect(_item: Item, _object: Node3D) -> void:
	BattleService.s_battle_ended.connect(on_battle_finished)

func on_load(_item: Item) -> void:
	BattleService.s_battle_ended.connect(on_battle_finished)

func on_item_removed() -> void:
	if BattleService.s_battle_ended.is_connected(on_battle_finished):
		BattleService.s_battle_ended.disconnect(on_battle_finished)

func on_battle_finished() -> void:
	var player := Util.get_player()
	Util.get_player().quick_heal(get_heal_amount(player.stats.max_hp))
	
func get_heal_amount(max_hp: int) -> int:
	return ceili(max_hp * HEAL_AMOUNT)
