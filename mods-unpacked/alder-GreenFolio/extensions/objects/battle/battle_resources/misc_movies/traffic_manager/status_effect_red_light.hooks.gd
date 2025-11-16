extends Object

func ban_random_track(chain: ModLoaderHookChain, _actions: Array[BattleAction] = []) -> void:
	var status_effect = chain.reference_object
	status_effect.trimmed_list = status_effect.trimmed_list.filter(func(track: Track):
		return track.track_name != "Throw"
	)
	chain.execute_next([_actions])
