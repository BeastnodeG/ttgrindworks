extends Object

#commented out in mod_main

func sync_settings(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("doing our injection")
	var settings = chain.reference_object
	if 2.5 not in settings.SpeedOptions:
		settings.SpeedOptions = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0, 7.5, 10.0, 25.0, 50.0]
	#chain.execute_next()
