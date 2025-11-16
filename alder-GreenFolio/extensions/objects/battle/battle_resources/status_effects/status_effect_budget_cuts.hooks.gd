extends Object

#the vanilla script doesn't consider other temporary point regen bonuses/debuffs
#this is an issue for interacting with debuffs like phisher, where phisher will give you permanent point regen after budget cuts expires

func apply(chain: ModLoaderHookChain) -> void:
	var status_effect = chain.reference_object
	var player = status_effect.target
	var track_name = status_effect.track_name
	var penalty = status_effect.penalty
	
	if player.stats.gag_regeneration.has(track_name):
		player.stats.gag_regeneration[track_name] += penalty

func cleanup(chain: ModLoaderHookChain) -> void:
	var status_effect = chain.reference_object
	var player = status_effect.target
	var track_name = status_effect.track_name
	var penalty = status_effect.penalty
	
	if player.stats.gag_regeneration.has(track_name):
		player.stats.gag_regeneration[track_name] -= penalty
