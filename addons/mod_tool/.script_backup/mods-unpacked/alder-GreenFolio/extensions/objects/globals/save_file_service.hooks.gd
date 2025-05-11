extends Object

func _save_run(chain: ModLoaderHookChain) -> void:
	# 1) Run the original save logic
	chain.execute_next()

	# 2) 'chain.reference_object' is the Node instance that owns _save_run()
	var owner_node = chain.reference_object as Node

	# 3) From there we can get the tree and find GFglobal
	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		gf.save_to()
		print("GFglobal data saved.")
	else:
		print("GFglobal not found at /root/ModLoader/alder-GreenFolio/GFglobal")
