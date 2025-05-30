@tool
extends StatusEffect

func apply() -> void:
	var player_stats = manager.battle_stats[Util.get_player()]
	for track in player_stats.gag_regeneration.keys():
		player_stats.gag_regeneration[track] -= 1

func cleanup() -> void:
	var player_stats = manager.battle_stats[Util.get_player()]
	for track in player_stats.gag_regeneration.keys():
		player_stats.gag_regeneration[track] += 1
