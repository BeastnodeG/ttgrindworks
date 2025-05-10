@tool
extends StatEffectRegeneration
class_name StatEffectMonarch

@export var SpecialEffect: String = "Basic"
@export var ButterflyAmount: int = 1

func renew() -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return

	manager.battle_node.focus_character(target)

	var final_damage := amount
	manager.affect_target(target, final_damage)

	apply_special_effects_on_hit(final_damage)

	if target is Player:
		target.set_animation("cringe")
	else:
		target.set_animation("pie-small")

	await manager.sleep(3.0)
	await manager.check_pulses([target])

func apply_special_effects_on_hit(_damage: int) -> void:
	var player: Player = Util.get_player()

	match SpecialEffect:
		"Cash":
			if player:
				for i in ButterflyAmount:
					if RandomService.randf_channel("true_random") <= 0.1:
						player.stats.add_money(1)
						print("wow you just won some money")
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
		"Princess":
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate()
			effect.stat = "damage"
			effect.boost = (0.9)
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			manager.add_status_effect(effect)
		"Fedora":
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate()
			effect.stat = "defense"
			effect.boost = (0.9)
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			manager.add_status_effect(effect)
		"Vampire":
			if player:
				if RandomService.randf_channel("true_random") <= 0.25:
					var healing: int = int(ceil(_damage * 0.2 * player.stats.healing_effectiveness))
					player.stats.hp = min(player.stats.hp + healing, player.stats.max_hp)
					print("Vampire butterfly healed for", healing)
		"Soak":
			if player:
				var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_drenched.tres").duplicate()
				effect.target = target
				effect.boost = player.stats.get_stat("squirt_defense_boost")
				manager.add_status_effect(effect)
		"Aftershock":
			if player:
				var effect := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_aftershock.tres").duplicate()
				effect.target = target
				effect.amount = roundi(_damage * 0.25)
				if player.stats.get_stat("drop_aftershock_round_boost") != 0:
					effect.rounds += player.stats.get_stat("drop_aftershock_round_boost")
				manager.add_status_effect(effect)
		"Poison":
			if player:
				var effect := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_poison.tres").duplicate()
				effect.target = target
				effect.rounds = -1
				effect.amount = roundi(_damage * 0.25)
				effect.icon = load("res://ui_assets/battle/statuses/poison.png")
					
				manager.add_status_effect(effect)
		_:
			pass

func get_icon() -> Texture2D:
	match SpecialEffect:
		"Vampire":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_throw.png")
		"Soak":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_squirt.png")
		"Aftershock":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_drop.png")
		"Hex":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_toonup.png")
		"Cash":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_lure.png")
		"Dragon":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_dragon.png")
		"Poison":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_witch.png")
		"Princess":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_princess.png")
		"Fedora":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_fedora.png")
		_:
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")

func get_status_name() -> String:
	match SpecialEffect:
		"Vampire":
			return "Vampire Butterfly"
		"Hex":
			return "Hexarch Butterfly"
		"Poison":
			return "Sickly Butterfly"
		"Cash":
			return "Moneyarch Butterfly"
		"Soak":
			return "Monarch Waterfly"
		"Aftershock":
			return "Shocking Butterfly"
		"Dragon":
			return "Dragonfly"
		"Princess":
			return "Princess Butterfly"
		"Fedora":
			return "Dapper Butterfly"
		_:
			return "Monarch Butterfly"

func get_description() -> String:
	var desc := "%d damage incoming." % amount

	match SpecialEffect:
		"Vampire":
			desc += "\nChance to lifesteal on hit."
		"Hex":
			desc += "\nApplies a random stat down."
		"Cash":
			desc += "\nChance to generate beans on hit."
		"Soak":
			desc += "\nApplies drenched on hit."
		"Aftershock":
			desc += "\nApplies aftershock on hit."
		"Dragon":
			desc += "\nYour wealth is it's power."
		"Princess":
			desc += "\nApplies attack down on hit."
		"Poison":
			desc += "\nApplies poison on hit."
		"Fedora":
			desc += "\nApplies defense down on hit."
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
