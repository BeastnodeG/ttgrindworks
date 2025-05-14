extends ItemScript

var gf : Node = null

func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	BattleService.s_battle_started.connect(on_battle_start)
	BattleService.s_battle_ended.connect(on_battle_end)
	getGF()

func on_battle_start(manager: BattleManager) -> void:
	print("taser: battle started")
	manager.s_participant_died.connect(on_participant_died)

func on_battle_end() -> void:
	pass

func on_participant_died(participant: Variant) -> void:
	if participant is Cog and gf:
		gf.taser_count += 1
		print("Taser count:", gf.taser_count)

		if gf.taser_count >= 8:
			do_taser_effect()
			gf.taser_count = 0
			
func do_taser_effect() -> void:
	Util.get_player().stats.charge_active_item(1)
	Util.get_player().boost_queue.queue_text("Bzzt!", Color(0.996, 0.922, 0.365))


func getGF() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	if get_tree().get_root().has_node(path):
		gf = get_tree().get_root().get_node(path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", path)
