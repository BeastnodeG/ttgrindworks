@tool
extends StatusEffect

func apply() -> void:
	var player = Util.get_player()
	var gagregen = player.stats.gag_regeneration
	for track in gagregen.keys():
		if player.gags_cost_beans:
			gagregen[track] += 1
		else:
			gagregen[track] -= 1
		print("decreased to ", gagregen[track])

func cleanup() -> void:
	var player = Util.get_player()
	var gagregen = player.stats.gag_regeneration
	for track in gagregen.keys():
		if player.gags_cost_beans:
			gagregen[track] -+ 1
		else:
			gagregen[track] += 1
		print("increased to ", gagregen[track])
		
func get_description() -> String:
	if Util.get_player().gags_cost_beans:
		return "+1 Gag Cost while in battle"
	return "-1 Gag Regeneration while in battle"
