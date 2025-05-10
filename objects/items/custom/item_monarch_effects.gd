extends ItemScript

var MONARCH_STATUS := load("res://objects/battle/battle_resources/status_effects/resources/status_effect_monarch.tres")
const QUALITOON_DAMAGE := [3, 3, 6, 9, 12, 15] # q5 doesn't exist but we include it for safety... don't i sound so smart
var player: Player

# Keyword-effect and damage multiplier map
const EFFECT_MAP := {
	"Jellybean": { effect = "Cash", damage_multiplier = 0.5 },
	"Super Candy": { effect = "Hex", damage_multiplier = 1 },
	"Candy": { effect = "Hex", damage_multiplier = 0.75 },
	"Treasure": { effect = "Vampire", damage_multiplier = 0.5 },
	"Laff Boost": { effect = "Vampire", damage_multiplier = 0.75 },
	"Random": { effect = "Random", damage_multiplier = 0.75},
	"Task Reroll": { effect = "Random", damage_multiplier = 1 },
	"Toonup": { effect = "Hex", damage_multiplier = 0.5 },
	"Squirt": { effect = "Soak", damage_multiplier = 1 },
	"Trap": { effect = "Basic", damage_multiplier = 1.25 },
	"Lure": { effect = "Hex", damage_multiplier = 1 },
	"Sound": { effect = "Basic", damage_multiplier = 1.5 },
	"Throw": { effect = "Vampire", damage_multiplier = 1 },
	"Drop": { effect = "Aftershock", damage_multiplier = 0.9 },
	
	#start of specific accessories
	"Dragon Wings": { effect = "Dragon", damage_multiplier = 1 },
	
	"Fedora": { effect = "Fedora", damage_multiplier = 2 },
	
	"Witch Hat": { effect = "Poison", damage_multiplier = 2 },
	
	"Princess Hat": { effect = "Princess", damage_multiplier = 2 },
	"Crown": { effect = "Princess", damage_multiplier = 1.5 },
	"Tiara": { effect = "Princess", damage_multiplier = 1.25 },
	
	"Chef Hat": { effect = "Vampire", damage_multiplier = 0.75 },
	"Pixie Wings": { effect = "Vampire", damage_multiplier = 1.25 },
	"Bat Wings": { effect = "Vampire", damage_multiplier = 2 },
	"Heart Glasses": { effect = "Vampire", damage_multiplier = 1 },
	"Heart Headband": { effect = "Vampire", damage_multiplier = 1 },
	"Sandwich": { effect = "Vampire", damage_multiplier = 1 },
	"Green Deal": { effect = "Vampire", damage_multiplier = 1 },
	
	"Baseball Cap": { effect = "Basic", damage_multiplier = 1.1 },
	"Roman Helmet": { effect = "Basic", damage_multiplier = 1.1 },
	"Toys Backpack": { effect = "Basic", damage_multiplier = 1.1 },
	"Viking Helmet": { effect = "Basic", damage_multiplier = 1.1 },
	"Wooden Sword": { effect = "Basic", damage_multiplier = 1.75 },
	"Aviators": { effect = "Basic", damage_multiplier = 1.5 },
	
	"Bowler Hat": { effect = "Cash", damage_multiplier = 1 },
	"Fez": { effect = "Cash", damage_multiplier = 1 },
	"Fruit Hat": { effect = "Cash", damage_multiplier = 1.25 },
	"Pirate Hat": { effect = "Cash", damage_multiplier = 1 },
	"Jellybean Jar": { effect = "Cash", damage_multiplier = 1 },
	"Golden Jellybean": { effect = "Cash", damage_multiplier = 1 },
	"Tax Write-Off": { effect = "Cash", damage_multiplier = 1 },
	
	"Gag Attack Pack": { effect = "Random", damage_multiplier = 1.25 },
	"Medium Pouch": { effect = "Random", damage_multiplier = 1.25 },
	"Celebrity Shades": { effect = "Random", damage_multiplier = 1 },
	"Star Glasses": { effect = "Random", damage_multiplier = 1 },
	"Mini Blinds": { effect = "Random", damage_multiplier = 1 },
	"Goggles": { effect = "Random", damage_multiplier = 1.5 },
	"Alien Glasses": { effect = "Random", damage_multiplier = 2 },
	"White-Out": { effect = "Random", damage_multiplier = 1 },
	"Paint Bucket": { effect = "Random", damage_multiplier = 1.5 },
	"Paint Brush": { effect = "Random", damage_multiplier = 1.25 },
	
	"Scuba Tank": { effect = "Soaked", damage_multiplier = 1 },
	"Shark Fin": { effect = "Soaked", damage_multiplier = 1 },
	"Scuba Mask": { effect = "Soaked", damage_multiplier = 2 },
	
	"Anvil Hat": { effect = "Aftershock", damage_multiplier = 0.9 },
	"Big Weight Hat": { effect = "Aftershock", damage_multiplier = 0.9 },
	"Bird Nest": { effect = "Aftershock", damage_multiplier = 0.9 },
	"Flowerpot Hat": { effect = "Aftershock", damage_multiplier = 0.9 },
	
	"3D Glasses": { effect = "Hex", damage_multiplier = 1 },
	"Jester Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Police Hat": { effect = "Hex", damage_multiplier = 1 },
	"Pompadour Hairdo": { effect = "Hex", damage_multiplier = 1 },
	"Propeller Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Rainbow Wig": { effect = "Hex", damage_multiplier = 1.25 },
	"Wizard Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Toy Hammer": { effect = "Hex", damage_multiplier = 1 },
	
}

const RANDOM_EFFECT := {
	"Vampire": 0.5,
	"Hex": 0.75,
	"Soak": 0.75,
	"Aftershock": 1.1,
	"Basic": 1.25,
	"Cash": 0.5
}

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
	if not player:
		return

	var absorbed_items = player.stats.monarch_absorbed_items
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

		var effect_info := get_special_effect(item.name)

		# Apply special Dragon calculation
		if effect_info.effect == "Dragon":
			var money_bonus := int(player.stats.money / 5)
			status.amount = total_damage + money_bonus
		else:
			status.amount = round(total_damage * effect_info.damage_multiplier)

		status.SpecialEffect = effect_info.effect
		manager.add_status_effect(status)

func get_special_effect(item_name: String) -> Dictionary:
	for keyword in EFFECT_MAP.keys():
		if item_name == keyword:
			var base_info = EFFECT_MAP[keyword]
			var base_multiplier: float = float(base_info.damage_multiplier)

			if base_info.effect == "Random":
				var random_effects := RANDOM_EFFECT.keys()
				var chosen_effect: String = RandomService.array_pick_random('true_random', random_effects)
				var chosen_multiplier: float = float(RANDOM_EFFECT.get(chosen_effect, 1.0))
				var final_multiplier: float = base_multiplier * chosen_multiplier

				print("Random effect selected: %s (%.2f x %.2f = %.2f)" % [chosen_effect, base_multiplier, chosen_multiplier, final_multiplier])
				return {
					effect = chosen_effect,
					damage_multiplier = final_multiplier
				}

			return base_info

	# Fallback
	return { effect = "Basic", damage_multiplier = 1.0 }
