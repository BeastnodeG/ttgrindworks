extends ItemCharSetup

func first_time_setup(player : Player) -> void:
	var stats := player.stats
	player.stats.gags_unlocked['Squirt'] = 1
	player.stats.speed = 1
	player.stats.damage = 1
	player.stats.defense = 1
	player.stats.luck = 1.05
	stats.gag_effectiveness['Throw'] = 0.9
	stats.gag_effectiveness['Lure'] = 0.9
	stats.gag_effectiveness['Trap'] = 0.9
	stats.gag_effectiveness['Drop'] = 0.9
	stats.gag_effectiveness['Sound'] = 0.9
