@tool
extends StatEffectRegeneration
class_name StatEffectMonarch

@export var SpecialEffect: String = "Basic"
@export var ButterflyAmount: int = 1

func renew() -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return

	manager.battle_node.focus_character(target)

	var final_damage := calculate_damage()
	manager.affect_target(target, final_damage)

	# Special effect actions (e.g., add beans)
	apply_special_effects_on_hit(final_damage)

	if target is Player:
		target.set_animation("cringe")
	else:
		target.set_animation("pie-small")

	await manager.sleep(3.0)
	await manager.check_pulses([target])

func calculate_damage() -> int:
	match SpecialEffect:
		"Toonup":
			return round(amount * 0.75)
		"Cash":
			return round(amount * 0.5)
		_:
			return amount

func apply_special_effects_on_hit(_damage: int) -> void:
	var player: Player = Util.get_player()


	match SpecialEffect:
		"Cash":
			if player:
				print("we can run this like, ", ButterflyAmount)
				for i in ButterflyAmount:
					if RandomService.randf_channel("true_random") <= 0.075:
						print("wow you just won some money")
						player.stats.add_money(1)

		"Hex":
			var stat = RandomService.array_pick_random("true_random", ["damage", "defense"])
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate()
			
			effect.stat = stat
			effect.boost = (1 - (0.02 * ButterflyAmount))
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			
			manager.add_status_effect(effect)

		"Vampire":
			if player:
				for i in ButterflyAmount:
					if RandomService.randf_channel("true_random") <= 0.5:
						var healing: int = ceil(_damage * 0.2 * player.stats.healing_effectiveness)
						player.stats.hp = min(player.stats.hp + healing, player.stats.max_hp)
						print("Vampire butterfly healed for", healing)

		_:
			pass



func get_icon() -> Texture2D:
	match SpecialEffect:
		"Vampire":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_throw.png")
		"Hex":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_toonup.png")
		"Cash":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_lure.png")
		_:
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")

func get_status_name() -> String:
	match SpecialEffect:
		"Vampire":
			return "Vampire Butterfly"
		"Hex":
			return "Hexarch Butterfly"
		"Cash":
			return "Moneyarch Butterfly"
		_:
			return "Monarch Butterfly"

func get_description() -> String:
	var desc := "%d damage incoming." % calculate_damage()
	
	match SpecialEffect:
		"Vampire":
			desc += "\nChance to lifesteal on hit."
		"Hex":
			desc += "\nApplys a random stat down."
		"Cash":
			desc += "\nChance to generate beans on hit."
		_:
			pass
	
	return desc


func combine(effect: StatusEffect) -> bool:
	if effect.rounds == rounds and effect.SpecialEffect == SpecialEffect:
		amount += effect.amount
		ButterflyAmount += effect.ButterflyAmount
		return true
	return false


func randomize_effect() -> void:
	super()
