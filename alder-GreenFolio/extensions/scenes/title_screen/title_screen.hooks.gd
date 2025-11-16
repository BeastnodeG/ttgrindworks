extends Object
var GreenFolioPanel: PackedScene = preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/thegreenfolio/greenfoliopanel.tscn")
var greenfolio_instance: Control
var folio_texts: Array = []
var unlocked_folios: Array[String] = []
var current_index: int = 0
var max_unlocked_index: int = 1
var ScrollButtonScript := preload("res://objects/general_ui/scroll_button/scroll_button.gd")

func _load_folio_texts() -> void:
	var path := "res://mods-unpacked/alder-GreenFolio/extensions/objects/thegreenfolio/folios.json"
	var file := FileAccess.open(path, FileAccess.READ)
	var data := file.get_as_text()
	var json_parser := JSON.new()
	var parse_result := json_parser.parse(data)
	folio_texts = json_parser.get_data()
	
func _update_folio_text() -> void:
	if not greenfolio_instance:
		return
	if folio_texts.is_empty():
		return
	current_index = clamp(current_index, 0, max_unlocked_index)
	print("printing folio texts size: ", folio_texts.size())
	var label: Label = greenfolio_instance.get_node("MarginContainer/VBoxContainer/SummaryDesc")
	label.text = folio_texts[current_index]
	
func _setup_scroll_button() -> void:
	if not greenfolio_instance:
		return
	var scroll_btn = greenfolio_instance.get_node("HBoxContainer/ScrollButton")
	if scroll_btn and scroll_btn.get_script() == ScrollButtonScript:
		print("Setting scroll button options to: ", unlocked_folios)
		scroll_btn.options = unlocked_folios
		scroll_btn.option_index = 0
		scroll_btn.update()
		if not scroll_btn.is_connected("s_option_changed", Callable(self, "_on_scroll_option_changed")):
			scroll_btn.connect("s_option_changed", Callable(self, "_on_scroll_option_changed"))
		print("Scroll button options are now: ", scroll_btn.options)
		
func begin_game(chain: ModLoaderHookChain, character: PlayerCharacter, falling_scene := false) -> void:
	print("wow begin game")
	if greenfolio_instance:
		greenfolio_instance.hide()
		
	var owner_node = chain.reference_object as Node
	var gf = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		gf.save_to()
		print("GFglobal data saved.")
	else:
		print("GFglobal not found at /root/ModLoader/alder-GreenFolio/GFglobal")
	
	print("foliosetup")
	print(gf.folio_level)
	
	await chain.execute_next([character, falling_scene])
	
	gf.folio_level = current_index
	print("printing after")
	print(gf.folio_level)
	
func clipboard_in(chain: ModLoaderHookChain) -> void:
	var self_ref = chain.reference_object
	
	if folio_texts.is_empty():
		_load_folio_texts()
	
	var owner_node = chain.reference_object as Node
	var gfp = owner_node.get_tree().get_root().get_node_or_null("/root/ModLoader/alder-GreenFolio/GFprogress")
	max_unlocked_index = 1
	if gfp:
		max_unlocked_index = gfp.folio_unlocked
		print("Max unlocked folio index: ", max_unlocked_index)
	
	unlocked_folios.clear()
	unlocked_folios.append("N/A")
	for i in range(1, min(max_unlocked_index + 1, folio_texts.size())):
		unlocked_folios.append("Folio %d" % i)
	
	if greenfolio_instance:
		greenfolio_instance.queue_free()
		greenfolio_instance = null
	
	var clipboard = self_ref.get_node("%CharacterClipboard")
	greenfolio_instance = GreenFolioPanel.instantiate()
	clipboard.add_child(greenfolio_instance)
	
	call_deferred("_setup_scroll_button")
	current_index = 0
	call_deferred("_update_folio_text")
	
	chain.execute_next()
	
	if greenfolio_instance:
		greenfolio_instance.show()
		
func clipboard_out(chain: ModLoaderHookChain) -> void:
	if greenfolio_instance:
		greenfolio_instance.hide()
	
	chain.execute_next()
	
func _on_scroll_option_changed(idx: int) -> void:
	current_index = idx
	_update_folio_text()
	
func back_pressed(chain: ModLoaderHookChain) -> void:
	print("wow back pressed ran")
	if greenfolio_instance:
		greenfolio_instance.hide()
	chain.execute_next()
