class_name MonarchButterflyData

const BASE_DAMAGE: int = 6
const EVERGREEN_PENALTY: float = 0.4
const RARITY_MULT_PER_OFFSET: float = 0.1

const QUALITOON_MULT: Array[float] = [0.8, 0.9, 1, 2, 2.5]

const EVERGREEN_OVERRIDES: Dictionary = {
	"Gag Point Boost": false,
	"Extra Turn": false,
	"Emergency Unite": false
}

const BULK_ABSORB: Dictionary = {
	"Gag Point Boost": { "count": 14, "qualitoon": 1 },
	"Extra Move": { "count": 7, "qualitoon": 1 },
	"Accessory Trunk": { "count": 4, "qualitoon": 1 },
	"???": { "count": 4, "qualitoon": 2 },
	"Monarch Butterfly": { "count": 20, "qualitoon": 1 },
}

const EFFECT_MAP: Dictionary = {
	#special items
	"Gag Point Boost": { effect = "Random", damage_multiplier = 1 },
	"Extra Move": { effect = "Random", damage_multiplier = 1 },
	"Accessory Trunk": { effect = "Random", damage_multiplier = 0.75 },
	"???": { effect = "Random", damage_multiplier = 1 },
	"Monarch Butterfly": { effect = "Basic", damage_multiplier = 1 },
	
	"The Monarch": { effect = "Basic", damage_multiplier = 1.1 },
	
	#evergreen items
	"Jellybean": { effect = "Cash", damage_multiplier = 1 },
	"Super Candy": { effect = "Hex", damage_multiplier = 1 },
	"Candy": { effect = "Hex", damage_multiplier = 1 },
	"Treasure": { effect = "Vampire", damage_multiplier = 1 },
	"Laff Boost": { effect = "Vampire", damage_multiplier = 1 },
	"Random": { effect = "Random", damage_multiplier = 1},
	"Task Reroll": { effect = "Random", damage_multiplier = 1.25 },
	"Toonup": { effect = "Hex", damage_multiplier = 1.25 },
	"Squirt": { effect = "Soak", damage_multiplier = 1 },
	"Trap": { effect = "Lightning", damage_multiplier = 0.9 },
	"Lure": { effect = "Cash", damage_multiplier = 1 },
	"Sound": { effect = "Booming", damage_multiplier = 0.5 },
	"Throw": { effect = "Vampire", damage_multiplier = 0.9 },
	"Drop": { effect = "Aftershock", damage_multiplier = 0.75 },
	
	#start of specific accessories
	"Dragon Wings": { effect = "Dragon", damage_multiplier = 1 },
	"Dragonfly Wings": { effect = "Dragon", damage_multiplier = 1 },
	
	"Fedora": { effect = "Fedora", damage_multiplier = 3 },
	
	"Witch Hat": { effect = "Poison", damage_multiplier = 1 },
	"Green Deal": { effect = "Poison", damage_multiplier = 1 },
	"Space Helmet": { effect = "Poison", damage_multiplier = 1 },
	"Oil Can": { effect = "Poison", damage_multiplier = 1 },
	
	"Princess Hat": { effect = "Princess", damage_multiplier = 3 },
	"Crown": { effect = "Princess", damage_multiplier = 1 },
	"Tiara": { effect = "Princess", damage_multiplier = 1 },
	"Opossum Charm": { effect = "Princess", damage_multiplier = 1 },
	
	"Chef Hat": { effect = "Vampire", damage_multiplier = 1 },
	"Pixie Wings": { effect = "Vampire", damage_multiplier = 1 },
	"Bat Wings": { effect = "Vampire", damage_multiplier = 1 },
	"Heart Glasses": { effect = "Vampire", damage_multiplier = 1 },
	"Heart Headband": { effect = "Vampire", damage_multiplier = 1 },
	"Sandwich": { effect = "Vampire", damage_multiplier = 1 },
	"Emergency Unite": {effect = "Vampire", damage_multiplier = 1},
	"Smooch Glasses": {effect = "Vampire", damage_multiplier = 1},
	"Watering Can": {effect = "Vampire", damage_multiplier = 1},
	"Jolly Boots": {effect = "Vampire", damage_multiplier = 1},
	
	"Wooden Sword": { effect = "Basic", damage_multiplier = 2 },
	"Balancing Scale": { effect = "Basic", damage_multiplier = 2 },
	
	"Bowler Hat": { effect = "Cash", damage_multiplier = 1 },
	"Fez": { effect = "Cash", damage_multiplier = 1 },
	"Fruit Hat": { effect = "Cash", damage_multiplier = 1 },
	"Pirate Hat": { effect = "Cash", damage_multiplier = 1 },
	"Jellybean Jar": { effect = "Cash", damage_multiplier = 1 },
	"Golden Jellybean": { effect = "Cash", damage_multiplier = 1 },
	"Tax Write-Off": { effect = "Cash", damage_multiplier = 1 },
	"Cash Register": { effect = "Cash", damage_multiplier = 1 },
	"Calculator": { effect = "Cash", damage_multiplier = 1 },
	"Moneybags Coin": { effect = "Cash", damage_multiplier = 1 },
	
	"Gag Attack Pack": { effect = "Random", damage_multiplier = 1 },
	"Medium Pouch": { effect = "Random", damage_multiplier = 1 },
	"Small Pouch": { effect = "Random", damage_multiplier = 1 },
	"Large Pouch": { effect = "Random", damage_multiplier = 1 },
	"Goggles": { effect = "Random", damage_multiplier = 1.5 },
	"Alien Glasses": { effect = "Random", damage_multiplier = 1 },
	"Paint Bucket": { effect = "Random", damage_multiplier = 1 },
	"Paint Brush": { effect = "Random", damage_multiplier = 1 },
	"Paintball": { effect = "Random", damage_multiplier = 1.25 },
	"Angel Wings": { effect = "Random", damage_multiplier = 1 },
	"Dilly Dial": { effect = "Random", damage_multiplier = 1 },
	"Spinning Top": { effect = "Random", damage_multiplier = 2 },
	"Alien Glasses?": { effect = "Random", damage_multiplier = 2 },
	"More Choices": { effect = "Random", damage_multiplier = 1 },
	"More Options": { effect = "Random", damage_multiplier = 1 },
	"Masquerade Mask": { effect = "Random", damage_multiplier = 1 },
	"Recycle Bin": { effect = "Random", damage_multiplier = 1 },
	
	"Scuba Tank": { effect = "Soak", damage_multiplier = 1 },
	"Shark Fin": { effect = "Soak", damage_multiplier = 1 },
	"Scuba Mask": { effect = "Soak", damage_multiplier = 1 },
	"Fire Hydrant": { effect = "Soak", damage_multiplier = 1 },
	"Fishing Hat": { effect = "Soak", damage_multiplier = 1 },
	
	"Anvil Hat": { effect = "Aftershock", damage_multiplier = 1.3 }, #damage for aftershock butterflies boosted since the payoff for absorbing over taking should be higher imo
	"Big Weight Hat": { effect = "Aftershock", damage_multiplier = 1.3 },
	"Bird Nest": { effect = "Aftershock", damage_multiplier = 1.3 },
	"Flowerpot Hat": { effect = "Aftershock", damage_multiplier = 1.3 },
	
	"Taser": { effect = "Lightning", damage_multiplier = 1 },
	"Joybuzzer": { effect = "Lightning", damage_multiplier = 1 },
	"Lightbulb": { effect = "Lightning", damage_multiplier = 1 },
	"Bee Wings": { effect = "Lightning", damage_multiplier = 1 },
	"Bird Wings": { effect = "Lightning", damage_multiplier = 1 },
	"Jet Pack": { effect = "Lightning", damage_multiplier = 1 },
	"Airplane Wings": { effect = "Lightning", damage_multiplier = 1 },
	"Butterfly Wings": { effect = "Lightning", damage_multiplier = 1.1 },
	"Wingtips": { effect = "Lightning", damage_multiplier = 1 },
	"Super Toon Cape": { effect = "Lightning", damage_multiplier = 1 },
	"Goon Foot": { effect = "Lightning", damage_multiplier = 1 },
	"Philosopher's Stone": { effect = "Lightning", damage_multiplier = 1 },
	
	"Jamboree Pack": { effect = "Booming", damage_multiplier = 1 },
	"Conductor Hat": { effect = "Booming", damage_multiplier = 1 },
	"Sombrero": { effect = "Booming", damage_multiplier = 1 },
	"Toonosaur Hat": { effect = "Booming", damage_multiplier = 2 },
	"Toonosaur Boots": { effect = "Booming", damage_multiplier = 2 },
	"Celebrity Shades": { effect = "Booming", damage_multiplier = 1 },
	"Star Glasses": { effect = "Booming", damage_multiplier = 1 },
	"Mini Blinds": { effect = "Booming", damage_multiplier = 1 },
	"Wacky Whistle": { effect = "Booming", damage_multiplier = 1 },
	
	"Monocle": { effect = "Dapper", damage_multiplier = 1 },
	"Top Hat": { effect = "Dapper", damage_multiplier = 1 },
	
	"3D Glasses": { effect = "Hex", damage_multiplier = 1 },
	"Jester Hat": { effect = "Hex", damage_multiplier = 1 },
	"Police Hat": { effect = "Hex", damage_multiplier = 1 },
	"Pompadour Hairdo": { effect = "Hex", damage_multiplier = 1 },
	"Propeller Hat": { effect = "Hex", damage_multiplier = 1 },
	"Rainbow Wig": { effect = "Hex", damage_multiplier = 1 },
	"Wizard Hat": { effect = "Hex", damage_multiplier = 1 },
	"Toy Hammer": { effect = "Hex", damage_multiplier = 1 },
	"Groucho Glasses": { effect = "Hex", damage_multiplier = 1 },
	"Pink Slip": { effect = "Hex", damage_multiplier = 1 },
}

const RANDOM_EFFECT := {
	"Vampire": 0.75,
	"Hex": 1,
	"Soak": 1,
	"Aftershock": 0.75,
	"Cash": 1,
	"Lightning": 1,
	"Booming": 0.75
}

const BUTTERFLY_ICONS := {
	"Vampire": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_throw.png"),
	"Soak": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_squirt.png"),
	"Aftershock": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_drop.png"),
	"Hex": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_toonup.png"),
	"Cash": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_lure.png"),
	"Dragon": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_dragon.png"),
	"Poison": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_witch.png"),
	"Princess": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_princess.png"),
	"Fedora": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_fedora.png"),
	"Lightning": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_healing.png"),
	"Booming": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_sound.png"),
	"Dapper": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_dapper.png"),
	"Default": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")
}

static func get_special_effect(item_name: String) -> Dictionary:
	var base_info: Dictionary = EFFECT_MAP.get(item_name, { effect = "Basic", damage_multiplier = 1.0 })

	if base_info.effect == "Random":
		var random_effects := RANDOM_EFFECT.keys()
		var chosen_effect: String = RandomService.array_pick_random('true_random', random_effects)
		var chosen_multiplier: float = float(RANDOM_EFFECT.get(chosen_effect, 1.0))
		var final_multiplier: float = float(base_info.damage_multiplier) * chosen_multiplier
		print("Random effect selected: %s (%.2f x %.2f = %.2f)" % [chosen_effect, float(base_info.damage_multiplier), chosen_multiplier, final_multiplier])
		return {
			effect = chosen_effect,
			damage_multiplier = final_multiplier
		}

	return base_info

static func calculate_damage(item: Dictionary, effect_multiplier: float, atkstat: float) -> int:
	var qualitoon_idx: int = clampi(int(item.get("qualitoon", 0)), 0, 4)
	var is_evergreen: bool = item.get("evergreen", false)
	var item_rarity: int = int(item.get("rarity", 0))

	var qualitymult: float = QUALITOON_MULT[qualitoon_idx]

	var raritymult := 0.0
	if item_rarity > 0:
		var expected_rarity: int = qualitoon_idx + 1
		raritymult = (item_rarity - expected_rarity) * RARITY_MULT_PER_OFFSET

	if is_evergreen:
		qualitymult *= EVERGREEN_PENALTY

	return roundi(((qualitymult + raritymult) * (BASE_DAMAGE + (Util.floor_number))) * effect_multiplier * atkstat)

static func get_butterfly_power(item: Dictionary) -> int:
	if item.get("evergreen", false):
		return 1
	return clampi(int(item.get("qualitoon", 0)) + 1, 1, 5)
