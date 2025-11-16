extends FloorModifier

const CAPACITY_AMOUNT := -3
	
func modify_floor() -> void:
	BattleService.s_battle_ended.connect(on_battle_finished)
	
	var env : Environment = game_floor.environment.environment.duplicate(true)
	env.background_energy_multiplier = 0.05
	env.fog_light_color = Color.BLACK
	env.fog_density = 0.2
	env.fog_enabled = true
	game_floor.environment.environment = env

func clean_up() -> void:
	BattleService.s_battle_ended.disconnect(on_battle_finished)

func on_battle_finished() -> void:
	if not is_instance_valid(Util.get_player()): return
	Util.get_player().stats.charge_active_item(-1)
	if RandomService.randi_channel("overcharged") % 4 == 0:
		Util.get_player().boost_queue.queue_text("Power Outage!", Color(1, 0, 0))

func get_mod_quality() -> ModType:
	return ModType.NEGATIVE

func get_mod_name() -> String:
	return "Power Outage"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pocket_prank_icons/unpoweredlightbulb.png")

func get_icon_offset() -> Vector2:
	return Vector2(11, 5)

func get_description() -> String:
	return "Pocket Pranks have a 25% chance to lose a charge after battle. Someone forgot to turn on the lights"
