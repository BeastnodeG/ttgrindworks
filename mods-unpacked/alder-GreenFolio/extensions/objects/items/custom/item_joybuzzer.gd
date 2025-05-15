extends ItemScript

var last_hp: int = -1  # Tracks the player's previous HP

func on_collect(_item: Item, _object: Node3D) -> void:
	print("on collect called")
	setup()

func on_load(_item: Item) -> void:
	print("on load called")
	setup()

func setup() -> void:
	print("setting up joybuzzer")
	if not Util.get_player():
		await Util.s_player_assigned

	var player := Util.get_player()
	player.stats.hp_changed.connect(on_hp_changed)
	last_hp = player.stats.hp

func on_hp_changed(current_hp: int) -> void:
	print("hp changed")
	var player = Util.get_player()
	var stats = player.stats
	var max_hp = stats.max_hp

	# Skip if first run or healing
	if last_hp == -1 or current_hp >= last_hp:
		last_hp = current_hp
		return

	var lost_hp = last_hp - current_hp
	var lost_ratio = float(lost_hp) / float(max_hp)
	var chance = lost_ratio * 0.75

	print("Took ", lost_hp, "damage out of ", max_hp, "- Roll chance:", chance)

	if RandomService.randf_channel("true_random") < chance:
		stats.charge_active_item(1)
		player.boost_queue.queue_text("Schadenfreude!", Color(0.996, 0.922, 0.365))

	last_hp = current_hp
