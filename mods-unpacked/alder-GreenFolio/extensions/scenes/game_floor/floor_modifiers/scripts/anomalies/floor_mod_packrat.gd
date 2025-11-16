extends FloorModifier

const CAPACITY_AMOUNT := 3

func modify_floor() -> void:
	var player := Util.get_player()
	player.stats.gag_cap += CAPACITY_AMOUNT

func clean_up() -> void:
	var player := Util.get_player()
	player.stats.gag_cap += (CAPACITY_AMOUNT*-1)

func get_mod_quality() -> ModType:
	return ModType.POSITIVE

func get_mod_name() -> String:
	return "Pack Rat"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/packratinscryption.png")

func get_icon_offset() -> Vector2:
	return Vector2(11, 5)

func get_description() -> String:
	return "Increases gag point capacity by 3"
