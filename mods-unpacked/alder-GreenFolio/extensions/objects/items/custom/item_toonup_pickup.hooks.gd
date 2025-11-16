extends Object
#disabled in mod_main
func setup(chain: ModLoaderHookChain, item: Item) -> void:
	chain.execute_next()
	
	var owner_node = chain.reference_object as Node
	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	
	var movie_type = chain.reference_object.movie_type
	var ToonUpNames: Dictionary = chain.reference_object.ToonUpNames
	
	var pickup_count: int = Util.get_player().stats.toonups[movie_type]
	var items_in_play: Array = ItemService.get_items_in_play(ToonUpNames[movie_type])
	pickup_count += items_in_play.size()
	
	if (pickup_count > 3 and gf.folio_level >= 2) or (pickup_count > 2 and gf.folio_level >= 8):
		print("foliolevel toonup reroll")
		item.reroll()
	
