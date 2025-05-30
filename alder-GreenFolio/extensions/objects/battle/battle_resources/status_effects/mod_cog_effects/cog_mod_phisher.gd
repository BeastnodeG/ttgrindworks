@tool
extends StatusEffect

func apply() -> void:
	var player_stats = manager.battle_stats[Util.get_player()]
	for track in player_stats.gag_regeneration.keys():
		player_stats.gag_regeneration[track] -= 1
		print("lowered to ", player_stats.gag_regeneration[track])

func cleanup() -> void:
	var player_stats = manager.battle_stats[Util.get_player()]
	for track in player_stats.gag_regeneration.keys():
		player_stats.gag_regeneration[track] += 1
		print("increased to ", player_stats.gag_regeneration[track])
