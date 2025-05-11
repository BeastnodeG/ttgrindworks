extends ItemCharSetup

func first_time_setup(player : Player) -> void:
	player.stats.gags_unlocked['Lure'] = 1
	player.stats.speed = 0.90
	player.stats.damage = 0.85
	player.stats.luck = 1.2
