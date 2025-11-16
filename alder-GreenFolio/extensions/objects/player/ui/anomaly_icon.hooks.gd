extends Object

func hover(chain: ModLoaderHookChain) -> void:
	var instantiated_anomaly = chain.reference_object  # this is the original node
	var mod_name = instantiated_anomaly.get_mod_name()
	
	if mod_name.begins_with("Folio"):
		print("folio anomaly detected, adjusting")
		HoverManager.hover(instantiated_anomaly.get_anomaly_description(), 12, 0.025, instantiated_anomaly.get_anomaly_name(), instantiated_anomaly.get_anomaly_color())
		var hover_seq = Sequence.new([
			LerpProperty.new(instantiated_anomaly, ^"scale", 0.1, Vector2.ONE * 1.15)
				.interp(Tween.EASE_IN_OUT, Tween.TRANS_QUAD),
		]).as_tween(instantiated_anomaly)
		AudioManager.play_sound(instantiated_anomaly.HOVER_SFX, 6.0)
	else:
		chain.execute_next()
