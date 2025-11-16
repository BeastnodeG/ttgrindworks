extends Object

var gf: Node = null

func apply_debuff(chain: ModLoaderHookChain, target: Cog) -> void:
	var gag := chain.reference_object as GagSquirt
	if Util.get_player().stats.has_item("Space Helmet"):
		print("no drenched for you!")
		return
	chain.execute_next([target])

func get_stats(chain: ModLoaderHookChain) -> String:
	var gag := chain.reference_object as GagSquirt
	var string_text: String = chain.execute_next()
	
	var gag_level: int = get_gag_level(gag)
	var atom_stacks: int = floori(gag_level / 2) + 1
	if Util.get_player().stats.has_item("Space Helmet"):
		
		getGF()
		
		var new_string := []
		for line in string_text.split("\n"):
			if line.begins_with("Drenched:"):
				new_string.append("Atom Stacks: %d" % atom_stacks)
				if gf and gf.atomic_effect:
					new_string.append("Cycle: %s" % gf.atomic_effect.capitalize())
			else:
				new_string.append(line)
		string_text = "\n".join(new_string)
			
	return string_text
	
func get_gag_level(action: ToonAttack) -> int:
	var loadout: GagLoadout = Util.get_player().stats.character.gag_loadout
	for track in loadout.loadout:
		for i in range(track.gags.size()):
			if track.gags[i].action_name == action.action_name:
				return i
	return -1

func getGF() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var root := tree.get_root()
	gf = root.get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		print("gf test, ", gf.atomic_effect)
