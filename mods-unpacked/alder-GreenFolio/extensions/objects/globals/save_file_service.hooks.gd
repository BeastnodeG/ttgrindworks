extends Object

func _save_run(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("saving run via hook")
	var owner_node = chain.reference_object as Node

	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		gf.save_to()
		print("GFglobal data saved.")
	else:
		print("GFglobal not found at /root/ModLoader/alder-GreenFolio/GFglobal")
		
func load_run(chain: ModLoaderHookChain) -> String:
	print("attempting to load run via hook")

	var owner_node = chain.reference_object as Node
	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")

	if gf:
		gf.load_save()
		print("GFglobal data loaded.")
	else:
		print("GFglobal not found at /root/ModLoader/alder-GreenFolio/GFglobal")

	# Get the return value from the next hook or the vanilla function
	var result := chain.execute_next() as String
	return result

func delete_run_file(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("deleting run via hook")
	var owner_node = chain.reference_object as Node

	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		gf.delete_save()
		print("GFglobal data deleted.")
	else:
		print("GFglobal not found at /root/ModLoader/alder-GreenFolio/GFglobal")
		
func _save_progress(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("saving progress via hook")
	var owner_node = chain.reference_object as Node
	var gfp = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFprogress")
	if gfp:
		gfp.save_progress()
		print("GFglobalprogress data saved.")
	else:
		print("GFglobalprogress not found at /root/ModLoader/alder-GreenFolio/GFprogress")

func load_progress(chain: ModLoaderHookChain) -> String:
	print("attempting to load progress via hook")
	var owner_node = chain.reference_object as Node
	var gfp = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFprogress")
	if gfp:
		gfp.load_progress()
		print("GFglobalprogress data loaded.")
	else:
		print("GFGlobalprogress not found at /root/ModLoader/alder-GreenFolio/GFprogress")
	# Get the return value from the next hook or the vanilla function
	var result := chain.execute_next() as String
	return result
