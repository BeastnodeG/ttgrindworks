extends ItemScript

const TASER_UI := "res://mods-unpacked/alder-GreenFolio/extensions/objects/player/ui/taser_progress/taser_progress_meter.tscn"
const UI_SCRIPT_PATH := "res://mods-unpacked/alder-GreenFolio/extensions/objects/player/ui/taser_progress/taser_progress_meter.gd"

var gf : Node = null
var taser_ui: Control

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	BattleService.s_battle_started.connect(on_battle_start)
	BattleService.s_battle_ended.connect(on_battle_end)
	getGF()
	_initialize_taser_ui()

func _initialize_taser_ui() -> void:
	var player = Util.get_player()
	for node in player.gui.get_children():
		if node.get_script():
			if node.get_script().resource_path == UI_SCRIPT_PATH:
				taser_ui = node
				return
	taser_ui = load(TASER_UI).instantiate()
	player.gui.add_child(taser_ui)

func on_battle_start(manager: BattleManager) -> void:
	print("taser: battle started")
	manager.s_participant_died.connect(on_participant_died)

func on_battle_end() -> void:
	pass

func on_participant_died(participant: Variant) -> void:
	if participant is Cog and gf and taser_ui:
		gf.taser_count += 1
		print("Taser count:", gf.taser_count)
		taser_ui.increase_taser(1)

func getGF() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	if get_tree().get_root().has_node(path):
		gf = get_tree().get_root().get_node(path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", path)
