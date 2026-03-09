extends Object
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")

func _save_run(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("saving run via hook")
	var gf = GFUTIL.get_gf()
	if gf:
		gf.save_to()
		print("GFglobal data saved.")
	else:
		print("GFglobal not found")
		
func load_run(chain: ModLoaderHookChain) -> String:
	print("attempting to load run via hook")
	var gf = GFUTIL.get_gf()

	if gf:
		gf.load_save()
		print("GFglobal data loaded.")
	else:
		print("GFglobal not found")

	var result := chain.execute_next() as String
	return result

func delete_run_file(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("deleting run via hook")
	var gf = GFUTIL.get_gf()
	if gf:
		gf.delete_save()
		print("GFglobal data deleted.")
	else:
		print("GFglobal not found")
		
func _save_progress(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	print("saving progress via hook")
	var gfp = GFUTIL.get_progress()
	if gfp:
		gfp.save_progress()
		print("GFglobalprogress data saved.")
	else:
		print("GFglobalprogress not found")

func load_progress(chain: ModLoaderHookChain) -> String:
	print("attempting to load progress via hook")
	var gfp = GFUTIL.get_progress()
	if gfp:
		gfp.load_progress()
		print("GFglobalprogress data loaded.")
	else:
		print("GFGlobalprogress not found")
	var result := chain.execute_next() as String
	return result
