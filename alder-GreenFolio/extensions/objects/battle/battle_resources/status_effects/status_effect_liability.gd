@tool
extends StatusEffect
class_name StatusEffectLiability

@export var damage_amount := 1

func apply() -> void:
	damage_amount = (target.stats.max_hp*1)
	var battle_node := manager.battle_node
	return

func cleanup() -> void:
	#deal 50% damage (damage_amount) to waste broker
	#add action as damage?
	var waste_broker: Cog = manager.battle_node.get_node_or_null("WasteBroker")
	if waste_broker and is_instance_valid(waste_broker):
		if not waste_broker.stats.hp <= 0:
			print("doing damage ", damage_amount)
			manager.affect_target(waste_broker, damage_amount, true)
			waste_broker.set_animation("pie-small")
			await manager.check_pulses([waste_broker]) #we check pulse first incase the waste broker dies directly after you kill another cog (or else he attacks while dead)
			await manager.barrier(waste_broker.animator.animation_finished, 4.0)
	return

func get_description() -> String:
	return "Defeat this Cog to deal %d damage to the Waste Broker!" % damage_amount

func combine(effect : StatusEffect) -> bool:
	return false
