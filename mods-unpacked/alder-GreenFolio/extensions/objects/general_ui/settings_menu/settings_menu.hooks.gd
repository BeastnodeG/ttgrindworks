extends Object

func cry_for_help(chain: ModLoaderHookChain) -> void:
	var player = Util.get_player()
	
	print("adding meta")
	player.set_meta("stuck", true) #just discovered metadata.... its FRICKEN awesome -- we need to store this so our auto unstuck ovveride doesnt break the im stuck button
	chain.execute_next()
	player.remove_meta("stuck")
	print("removed meta")
