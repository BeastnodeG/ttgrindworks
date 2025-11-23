extends ItemScript

func on_collect(_item: Item, _object: Node3D) -> void:
	BattleService.s_battle_started.connect(on_battle_started)

func on_load(_item: Item) -> void:
	BattleService.s_battle_started.connect(on_battle_started)

func on_item_removed() -> void:
	if BattleService.s_battle_started.is_connected(on_battle_started):
		BattleService.s_battle_started.disconnect(on_battle_started)

func on_battle_started(manager: BattleManager) -> void:
	print("activating starboots")
	var player := Util.get_player()
	var gag_balance := player.stats.gag_balance
	
	var total := 0
	var count := 0
	
	for track in gag_balance.keys():
		total += gag_balance[track]
		count += 1
	
	var average := 0
	if count > 0:
		average = ceili(float(total) / float(count))
	
	for track in gag_balance.keys():
		gag_balance[track] = average
	print("total average: ", average)
	
