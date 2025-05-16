extends Object

func sync_settings(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("doing our injection")
	var settings = chain.reference_object
	if 2.5 not in settings.SpeedOptions:
		settings.SpeedOptions.append_array([2.5, 3.0, 4.0, 5.0, 7.5, 10.0])
	#chain.execute_next()
