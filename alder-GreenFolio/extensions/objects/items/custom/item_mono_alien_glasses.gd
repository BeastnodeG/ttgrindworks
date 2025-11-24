extends ItemScript

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	BattleService.s_round_started.connect(on_round_start)

func on_round_start(actions: Array[BattleAction]) -> void:
	var actions_to_insert := []
	
	for i in range(actions.size()):
		var action = actions[i]
		if action is ToonAttack and randf() < Util.get_relevant_player_stats().get_luck_weighted_chance(0.05, 0.15, 2.0): #5% -> 15% at 2.0 luck
			var duplicated_action = duplicate_action(action)
			if duplicated_action:
				actions_to_insert.append({"index": i + 1, "action": duplicated_action})
	
	for j in range(actions_to_insert.size() - 1, -1, -1):
		var insert_data = actions_to_insert[j]
		actions.insert(insert_data.index, insert_data.action)

func duplicate_action(original: ToonAttack) -> ToonAttack:
	var new_action = original.duplicate(true)
	
	new_action.user = original.user
	new_action.track = original.track
	new_action.manager = original.manager
	
	if original.icon:
		new_action.icon = original.icon
	
	var valid_cogs = BattleService.ongoing_battle.cogs.filter(func(c): return c.stats.hp > 0)
	
	if valid_cogs.is_empty():
		return null
	
	if original.target_type == BattleAction.ActionTarget.ENEMY:
		new_action.targets = [valid_cogs.pick_random()]
	else:
		var random_index = randi() % valid_cogs.size()
		new_action.reassess_splash_targets(random_index, BattleService.ongoing_battle)
	
	new_action.special_action_exclude = true
	
	if is_instance_valid(Util.get_player()) and Util.get_player().boost_queue:
		Util.get_player().boost_queue.queue_text("Copied!", Color(0.49, 0.49, 0.49, 1.0))
	
	return new_action
