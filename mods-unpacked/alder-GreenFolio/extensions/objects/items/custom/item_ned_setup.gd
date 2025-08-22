extends ItemCharSetup

func first_time_setup(player : Player) -> void:
	player.stats.gags_unlocked['Lure'] = 1
	player.stats.gags_unlocked['Throw'] = 1
	player.stats.gags_unlocked['Squirt'] = 1
	player.stats.luck = 1
	player.stats.damage = 0.95 #halved by neds item
	player.stats.speed = 1.1
	player.stats.turns = 2
	player.stats.max_turns = 6
	player.stats.gag_cap = 15
	for track in Util.get_player().stats.gag_balance.keys():
		Util.get_player().stats.gag_regeneration[track] += 1
