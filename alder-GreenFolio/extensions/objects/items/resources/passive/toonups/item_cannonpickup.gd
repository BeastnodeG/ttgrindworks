extends Node3D

func collect() -> void:
	var curr_val: int = Util.get_player().stats.toonups[7]
	Util.get_player().stats.toonups[7] = min(curr_val + 1, Globals.MaxToonupConsumables)

func modify(ui: Node3D) -> void:
	pass

func setup(item: Item) -> void:
	if not Util.get_player():
		return
	
	var pickup_count: int = Util.get_player().stats.toonups[7]
	var items_in_play: Array = ItemService.get_items_in_play("Confetti Cannon")
	pickup_count += items_in_play.size()
	
	# NOTE: This count includes the item itself, so max is ok. Its only when OVER max that it becomes a problem.
	if pickup_count > Globals.MaxToonupConsumables:
		item.reroll()
		
	#replicate the hook that we have for toonup pickups -nevermind-
	#var gf = get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")

#	if (pickup_count > 3 and gf.folio_level >= 2) or (pickup_count > 1 and gf.folio_level >= 8):
#		print("CANNON foliolevel toonup reroll")
#		item.reroll()
