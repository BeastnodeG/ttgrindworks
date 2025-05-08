@tool
extends StatEffectRegeneration
class_name StatEffectMonarch

@export var SpecialEffect: String = "Basic"

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
		"Cash":
			return round(amount * 0.5)
		_:
			return amount

func apply_special_effects_on_hit(_damage: int) -> void:
	match SpecialEffect:
		"Cash":
			if RandomService.randf_channel("true_random") <= 0.05:
				print("wow you just won some money")
				var player = Util.get_player()
				if player:
					player.stats.add_money(1)
		_:
			pass

func get_icon() -> Texture2D:
	match SpecialEffect:
		"Cash":
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_lure.png")
		_:
			return load("res://ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")

func get_status_name() -> String:
	match SpecialEffect:
		"Cash":
			return "Moneyarch Butterfly"
		_:
			return "Monarch Butterfly"

func get_description() -> String:
	var desc := "%d damage incoming." % calculate_damage()
	
	match SpecialEffect:
		"Cash":
			desc += "\nChance to generate beans on hit."
		_:
			pass
	
	return desc


func combine(effect: StatusEffect) -> bool:
	if effect.rounds == rounds and effect.SpecialEffect == SpecialEffect:
		amount += effect.amount
		return true
	return false


func randomize_effect() -> void:
	super()
