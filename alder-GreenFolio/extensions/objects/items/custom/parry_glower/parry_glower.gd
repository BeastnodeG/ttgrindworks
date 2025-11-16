extends ItemScriptActive

var SFX := preload("res://audio/sfx/battle/cogs/attacks/SA_glower_power.ogg")
var SUCCESS := preload("res://audio/sfx/battle/cogs/attacks/SA_writeoff_ding_only.ogg")
var FAIL := preload("res://audio/sfx/misc/MG_neg_buzzer.ogg")
var STATUS := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres")

#i'm very Not Proud of this item, 
#but i spent so much time making it i thought i may as well include it anyways as a "Q7"

var player: Player
var timer_active := false
var parry_success := false
var parry_used := false
var damage_taken_during_action := false
var current_action: BattleAction
var out_of_combat := false
var hp_before_parry := 0 

func on_collect(_item: Item, _object: Node3D) -> void:
	super.on_collect(_item, _object)
	if not Util.get_player():
		player = await Util.s_player_assigned
	else:
		player = Util.get_player()
	setup(player)

func setup(_player: Player) -> void:
	player = _player
	BattleService.s_action_started.connect(action_started)
	BattleService.s_action_finished.connect(action_finished)
	player.stats.hp_changed.connect(on_hp_changed)

func on_hp_changed(_current_hp: int) -> void:
	if timer_active and not parry_success:
		print("damaged during parry, success")
		AudioManager.play_sound(SUCCESS)
		player.stats.charge_active_item(2)
		player.boost_queue.queue_text("Parry!", Color(1, 1, 1))
		parry_success = true
	damage_taken_during_action = true

func action_started(action: BattleAction) -> void:
	print("battle action started")
	current_action = action
	damage_taken_during_action = false

	if action is CogAttack and action.target_type == 0:
		# speedup should only happen if charged
		if player.stats.current_active_item.current_charge >= 2:
			print("cog attack detected, item has enough charge")
			action.manager.revert_battle_speed()
			await get_tree().create_timer(0.4).timeout
			action.set_camera_angle("SIDE_RIGHT")
		else:
			print("cog attack, but no charge")
	else:
		print("manual speedup")
		Engine.time_scale = SaveFileService.settings_file.SpeedOptions[SaveFileService.settings_file.get('battle_speed_idx')]

func action_finished(_action: BattleAction) -> void:
	print("battle action finished")

	if parry_used:
		if not parry_success and damage_taken_during_action:
			print("parry failed")
			fail_effect()
		elif not damage_taken_during_action:
			print("recuperate")
			recuperate_effect()

	parry_used = false

func use() -> void:
	AudioManager.play_sound(SFX)
	parry_success = false
	parry_used = true
	timer_active = true
	out_of_combat = BattleService.ongoing_battle == null
	hp_before_parry = player.stats.hp  

	var defense_boost := StatMultiplier.new()
	defense_boost.stat = "defense"
	defense_boost.amount = 1.0
	defense_boost.additive = true
	player.stats.multipliers.append(defense_boost)

	# this sucks
	#Task.delayed_call(TaskContainer, 0.5, func():
		#player.stats.multipliers.erase(defense_boost)
	#)

	await get_tree().create_timer(0.5).timeout
	player.stats.multipliers.erase(defense_boost)

	timer_active = false

	if out_of_combat:
		if parry_success:
			print("realtime parry succeeded")

			# heal back hazard damage since modifying defense doesnt work
			var damage_taken := hp_before_parry - player.stats.hp
			if damage_taken > 0:
				print("healing damage: ", damage_taken)
				player.quick_heal(ceili(damage_taken*0.5))
		else:
			print("Out-of-combat parry failed.")
			player.boost_queue.queue_text("Disarmed!", Color(1, 0, 0))
			AudioManager.play_sound(FAIL)

func fail_effect() -> void:
	player.boost_queue.queue_text("Disarmed!", Color(1, 0, 0))
	disarmed(BattleService.ongoing_battle)
	AudioManager.play_sound(FAIL)

func recuperate_effect() -> void:
	player.boost_queue.queue_text("Recuperate", Color(1, 1, 1))
	player.stats.charge_active_item(2)
	AudioManager.play_sound(SUCCESS)

func disarmed(manager: BattleManager) -> void:
	var status := STATUS.duplicate(true)
	status.boost = 0.80
	status.rounds = 1
	status.quality = StatusEffect.EffectQuality.NEGATIVE
	status.stat = 'defense'
	status.target = player
	manager.add_status_effect(status)
	BattleService.s_refresh_statuses.emit()
