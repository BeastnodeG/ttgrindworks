extends FloorModifier

const CAPACITY_AMOUNT := -3
	
func modify_floor() -> void:
	BattleService.s_battle_ended.connect(on_battle_finished)

func clean_up() -> void:
	BattleService.s_battle_ended.disconnect(on_battle_finished)

func on_battle_finished() -> void:
	if not is_instance_valid(Util.get_player()): return
	Util.get_player().stats.charge_active_item(1)
	if RandomService.randi_channel("overcharged") % 4 == 0:
		Util.get_player().boost_queue.queue_text("Overcharged!", Color(0.996, 0.922, 0.365))

func get_mod_quality() -> ModType:
	return ModType.POSITIVE

func get_mod_name() -> String:
	return "Overcharged"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pocket_prank_icons/lightbulb.png")

func get_icon_offset() -> Vector2:
	return Vector2(11, 5)

func get_description() -> String:
	return "Pocket Pranks have a 25% chance to gain an additional charge after battle."
