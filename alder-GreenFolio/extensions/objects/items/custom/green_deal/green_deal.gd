extends ItemScriptActive

var SFX := load("res://audio/sfx/items/green_deal.ogg")
var STATUS := load("res://objects/battle/battle_resources/status_effects/resources/status_green_deal.tres")

var player: Player
var greendeal_status: StatusEffect

func on_collect(_item: Item, _object: Node3D) -> void:
	super.on_collect(_item, _object)
	if not Util.get_player():
		player = await Util.s_player_assigned
	else:
		player = Util.get_player()
	setup(player)

func setup(_player: Player) -> void:
	player = _player
	BattleService.s_battle_started.connect(apply_status)
	BattleService.s_round_ended.connect(end_round)

func end_round(manager: BattleManager) -> void:
	increase_strength()
	apply_status(manager)

func apply_status(manager: BattleManager) -> void:
	var status := STATUS.duplicate()
	status.amount = player.stats.green_deal_strength
	status.target = player
	manager.add_status_effect(status)
	greendeal_status = status

func increase_strength() -> void:
	player.stats.green_deal_strength += 2.5

func use() -> void:
	var battle := BattleService.ongoing_battle

	battle.battle_ui.visible = false
	if is_instance_valid(battle.battle_ui.timer):
		battle.battle_ui.timer.timer.set_paused(true)

	AudioManager.play_sound(SFX)

	var effect := STATUS.duplicate()
	effect.target = player
	effect.amount = player.stats.green_deal_strength
	effect.manager = battle
	player.stats.green_deal_strength = 0.0
	effect.force_trigger()

	await battle.sleep(2.8)

	battle.battle_ui.visible = true
	battle.battle_node.focus_character(battle.battle_node)
	if is_instance_valid(battle.battle_ui.timer):
		battle.battle_ui.timer.timer.set_paused(false)

	if greendeal_status:
		await battle.expire_status_effect(greendeal_status)
		greendeal_status = null

	BattleService.s_refresh_statuses.emit()
