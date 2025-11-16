extends FloorModifier

const RANDOM_COG_CHANCE := 0.1

func modify_floor() -> void:
	BattleService.s_round_started.connect(on_round_start)

func on_round_start(actions: Array[BattleAction]) -> void:
	for action in actions:
		if action is ToonAttack and RandomService.randf_channel('true_random') < RANDOM_COG_CHANCE:
			print('randomizing action: %s' % action.action_name)
			randomize_action(action)

func randomize_action(action: ToonAttack) -> void:
	var prev_targets := action.targets
	var prev_main_target = action.main_target
	if not action.target_type == BattleAction.ActionTarget.ENEMY:
		action.targets.clear()
		action.reassess_splash_targets(RandomService.randi_channel('true_random') % BattleService.ongoing_battle.cogs.size(), BattleService.ongoing_battle)
		if not action.main_target == prev_main_target:
			Util.get_player().boost_queue.queue_text("Vertigo!", Color(0.0, 0.602, 0.186))
	else:
		action.targets = [RandomService.array_pick_random('true_random', BattleService.ongoing_battle.cogs)]
		if not action.targets[0] == prev_targets[0]:
			Util.get_player().boost_queue.queue_text("Vertigo!", Color(0.0, 0.602, 0.186))
	action.special_action_exclude = true


func get_mod_quality() -> ModType:
	return ModType.NEGATIVE

func get_mod_name() -> String:
	return "Vertigo"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/vertigo.png")

func get_description() -> String:
	return "10% chance for Gags to target a random Cog."
