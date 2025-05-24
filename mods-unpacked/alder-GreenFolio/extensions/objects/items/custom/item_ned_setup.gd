extends ItemCharSetup

func first_time_setup(player : Player) -> void:
	player.stats.gags_unlocked['Lure'] = 1
	player.stats.gags_unlocked['Throw'] = 1
	player.stats.luck = 1.05
	player.stats.damage = 1 #handled by neds item
	player.stats.speed = 1.1
	player.stats.turns += 1
	player.stats.gag_cap = 20
	for track in Util.get_player().stats.gag_balance.keys():
		Util.get_player().stats.gag_regeneration[track] += 1
