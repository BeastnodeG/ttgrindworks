#extends ItemScriptActive
#
#const EXTRATURN_EFFECT := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/status_effect_extraturns.tres")
#const SFX_USE := preload("res://audio/sfx/battle/gags/MG_pos_buzzer.ogg")
#
#func use() -> void:
	#var player = Util.get_player()
	#AudioManager.play_sound(SFX_USE)
	#
	#var battle := BattleService.ongoing_battle
	#
	#var effect: StatusEffect = EXTRATURN_EFFECT.duplicate(true)
	#effect.target = player
	#effect.rounds = 0
	#effect.extra_turns = (player.stats.turns)
	#battle.add_status_effect(effect)
#
	#BattleService.s_refresh_statuses.emit()
	#battle.battle_ui.refresh_turns()


extends ItemScriptActive
const SFX_USE := preload("res://audio/sfx/battle/gags/MG_pos_buzzer.ogg")

func use() -> void:
	var player := Util.get_player()
	var manager := BattleService.ongoing_battle
	
	AudioManager.play_sound(SFX_USE)
	
	manager.battle_stats[player].turns *= 2
	manager.battle_ui.refresh_turns()
	
	if not manager.s_round_started.is_connected(reset_moves):
		manager.s_round_started.connect(reset_moves, CONNECT_ONE_SHOT)

func reset_moves(_battle) -> void:
	var manager := BattleService.ongoing_battle
	var player := Util.get_player()
	manager.battle_stats[player].turns = player.stats.turns
	manager.battle_ui.refresh_turns()
