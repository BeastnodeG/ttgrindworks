@tool
extends StatusEffect
class_name StatusGreenDeal

var GREEN_DEAL_PARTICLES := load("res://objects/battle/effects/poison/poison_cog.tscn")
var SFX := load("res://audio/sfx/items/green_deal.ogg")

@export var amount: int

var particles: Node3D
var applied_damage_boost := 1.0
var additive_damage_boost := 0.0 #for description

func apply():
	if not is_instance_valid(target) or not (target is Player):
		return

	var battle_stats: BattleStats = manager.battle_stats[target]
	if "damage" in battle_stats:
		var base_damage := battle_stats.damage
		var bonus := (base_damage * amount) / 100.0
		applied_damage_boost = (base_damage + bonus) / base_damage
		additive_damage_boost = applied_damage_boost
		battle_stats.damage *= applied_damage_boost
		print("Applied Green Deal damage boost: x%.2f" % applied_damage_boost)

func expire():
	print("we straight up destroying it i think")
	if is_instance_valid(particles):
		particles.queue_free()

	if is_instance_valid(target) and target is Player:
		var battle_stats: BattleStats = manager.battle_stats[target]
		if "damage" in battle_stats:
			battle_stats.damage /= applied_damage_boost
			print("Removed Green Deal damage boost")

func renew():
	if not is_instance_valid(target) or not (target is Player):
		return

	var damage := ceili(target.stats.max_hp * (amount / 100.0))
	if target.stats.hp <= damage:
		AudioManager.play_sound(SFX)
		await _trigger_effect()
		expire()

func force_trigger():
	if is_instance_valid(target) and target is Player:
		await _trigger_effect()
		expire()

func _trigger_effect() -> void:
	var damage := ceili(target.stats.max_hp * (amount / 100.0))
	manager.battle_node.focus_character(target)
	manager.affect_target(target, damage)

	if not particles:
		place_particles(target)

	if particles.has_node("AnimationPlayer"):
		particles.get_node("AnimationPlayer").play("on_apply")
	
	target.last_damage_source = "Hubris"
	target.set_animation('cringe')

	await manager.barrier(target.animator.animation_finished, 2.75)
	target.set_animation("neutral")
	await manager.check_pulses([target])

func place_particles(who: Node3D) -> void:
	particles = GREEN_DEAL_PARTICLES.instantiate()
	if who.get_node_or_null(NodePath(particles.name)):
		var old_particles: Node = who.get_node(NodePath(particles.name))
		old_particles.set_name("removing")
		old_particles.queue_free()
	
	var toon_node = who.get_node("Toon")
	toon_node.add_child(particles)
	particles.scale *= 2.0
	particles.position.y = 0.01

func get_status_name() -> String:
	return "Green Deal"

func get_description() -> String:
	var damage_threshold: int = ceili(target.stats.max_hp * (amount / 100.0) + 1)
	print(additive_damage_boost)
	return "You will go sad if the turn ends with your laff below %d!\nx%.2f damage multiplier." % [damage_threshold, additive_damage_boost]

func combine(effect: StatusEffect) -> bool: #we probably don't want to keep this but im afraid of removing it and having everything break
	if effect is StatusGreenDeal:
		amount = max(amount, effect.amount)
		return true
	return true
