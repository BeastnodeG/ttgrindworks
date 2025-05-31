@tool
extends StatusEffect

func apply() -> void:
	var gagregen = Util.get_player().stats.gag_regeneration
	for track in gagregen.keys():
		gagregen[track] -= 1
		print("lowered to ", gagregen[track])

func cleanup() -> void:
	var gagregen = Util.get_player().stats.gag_regeneration
	for track in gagregen.keys():
		gagregen[track] += 1
		print("increased to ", gagregen[track])
