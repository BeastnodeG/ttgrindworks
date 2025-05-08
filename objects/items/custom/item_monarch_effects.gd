extends ItemScript

const MONARCH_STATUS := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_monarch.tres")
const QUALITOON_DAMAGE := [3, 3, 6, 9, 12, 15] #15 doesn't get reached becauser q6 items don't exist... but whatever.

var player: Player

func on_collect(_item: Item, _object: Node3D) -> void:
	var _player: Player
	if not Util.get_player():
		_player = await Util.s_player_assigned
	else:
		_player = Util.get_player()
	setup(_player)

func on_load(item: Item) -> void:
	on_collect(item, null)

func setup(_player: Player) -> void:
	player = _player
	print("yeah im doing some connecting")
	BattleService.s_battle_started.connect(sendtheswarm)
	BattleService.s_round_ended.connect(sendtheswarm)
	
func sendtheswarm(manager: BattleManager) -> void:
	var absorbed_items = MonarchRegistry.get_absorbed_items()
	print("Butterflies we're using: " + str(absorbed_items))

	if not manager.cogs or manager.cogs.is_empty():
		print("No cogs available to apply effects to.")
		return

	for item in absorbed_items:
		var qualitoon := int(item.get("qualitoon", 2))
		var base_damage: int = QUALITOON_DAMAGE[clamp(qualitoon, 0, 5)]

		var player_damage := player.stats.damage
		var total_damage: int = round(base_damage + player_damage)

		var cog: Cog = RandomService.array_pick_random('true_random', manager.cogs)
		var status := MONARCH_STATUS.duplicate()
		status.target = cog
		status.ButterflyAmount = qualitoon + 1
		
		var special := get_special_effect(item.name)
		
		if special == "Candy": #this feels stupid. oh well
			status.amount = round(total_damage * 1.25)
			special = "Hex"
		else:
			status.amount = total_damage
		
		status.SpecialEffect = special
		
		manager.add_status_effect(status)

#no one... will notice
func get_special_effect(item_name: String) -> String:
	var effect_map := {
		"Jellybean": "Cash",
		"Super Candy": "Candy",
		"Candy": "Candy",
		"Toonup": "Hex",
		"Treasure": "Vampire"
	}
	
	for keyword in effect_map.keys():
		if item_name == keyword:
			print("yeah you're special :3")
			return effect_map[keyword]

	return "Basic"
