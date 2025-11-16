extends FloorModifier

## Boosts the player's max hp for the floor

const BOOST_AMOUNT := 0.8

var raw_boost := 0

func modify_floor() -> void:
	var player := Util.get_player()
	raw_boost = ceili(player.stats.max_hp * BOOST_AMOUNT) - player.stats.max_hp
	player.stats.max_hp += raw_boost
	player.stats.hp = mini(player.stats.hp, player.stats.max_hp)

func clean_up() -> void:
	var player := Util.get_player()
	player.stats.max_hp -= raw_boost
	player.stats.hp = mini(player.stats.hp, player.stats.max_hp)

func get_mod_quality() -> ModType:
	return ModType.NEGATIVE

func get_mod_name() -> String:
	return "Sadmosphere"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/sadmosphere.png")

func get_icon_offset() -> Vector2:
	return Vector2(5, 5)

func get_description() -> String:
	return "20% decreased max Laff"
