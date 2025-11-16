@tool
extends StatEffectRegeneration
class_name StatEffectAtomi

var STAT_ICONS := {
	'damage': load("res://ui_assets/battle/statuses/damage.png"),
	'accuracy': load("res://ui_assets/battle/statuses/pinpoint_accuracy.png"),
}

const ATOMIC_ICONS: Dictionary = {
	"plutonium": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/plutonium.png"),
	"actinium": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/actinium.png"),
	"curium": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/curium.png"),
	"thorium": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/thorium.png"),
}

const PARTICLE := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/atoms/atomorbit.tscn")
const MonarchParticleFollow := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchparticlefollow.gd")

var particles: GPUParticles3D
@export var fresh_applied: bool = true
var gf: Node = null

var current_atomic_effect: String = ""
var stat_modifications_applied: Dictionary = {}
var damage_effect_triggered: bool = false

func apply() -> void:
	if target is Cog:
		create_particles()
		target.set_animation("pie-small")
		BattleService.s_round_ended.connect(shift_atomic_effect)
		getGF()
		amount = target.level
		if gf:
			current_atomic_effect = gf.atomic_effect
			apply_atomic_modifications()

func shift_atomic_effect(manager: BattleManager) -> void:
	damage_effect_triggered = false
	await manager.get_tree().process_frame
	
	if not gf:
		getGF()
	
	var new_atomic_effect: String = gf.atomic_effect
	if current_atomic_effect != new_atomic_effect and current_atomic_effect != "":
		revert_stat_modifications()
	
	current_atomic_effect = new_atomic_effect
	apply_atomic_modifications()

func create_particles() -> void:
	particles = PARTICLE.instantiate() as GPUParticles3D
	target.body.head_bone.add_child(particles)
	particles.transform.origin = Vector3.ZERO
	particles.amount = rounds
	
	var mat = particles.draw_pass_1.material as StandardMaterial3D
	var shader = particles.process_material as ShaderMaterial
	shader.set_shader_parameter("seed", int(RandomService.randf_range_channel("true_random", 1, 50000)))
	
	var follow_helper = MonarchParticleFollow.new()
	follow_helper.particle_node = particles
	follow_helper.target_bone = target.body.head_bone
	particles.add_child(follow_helper)

func apply_atomic_modifications() -> void:
	
	var drenched_power = get_player_stats().get_stat('squirt_defense_boost')
	
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	
	var battle_stats: BattleStats = manager.battle_stats[target]
	
	match current_atomic_effect:
		"plutonium":
			# -5% (0.25*0.2) damage per atom 
			var damage_reduction: float = 1.0 + ((0.25*drenched_power) * (rounds+1))
			if "damage" in battle_stats:
				print("adjusting damage")
				var original_damage: float = battle_stats.get("damage")
				var new_damage: float = original_damage * damage_reduction
				battle_stats.set("damage", new_damage)
				stat_modifications_applied["damage"] = damage_reduction
		
		"actinium":
			# -10% (0.5*0.2) accuracy per atom
			var accuracy_reduction: float = 1.0 + ((0.5*drenched_power) * (rounds+1))
			if "accuracy" in battle_stats:
				print("adjusting accuracy")
				var original_accuracy: float = battle_stats.get("accuracy")
				var new_accuracy: float = original_accuracy * accuracy_reduction
				battle_stats.set("accuracy", new_accuracy)
				stat_modifications_applied["accuracy"] = accuracy_reduction

func revert_stat_modifications() -> void:
	if not is_instance_valid(target) or stat_modifications_applied.is_empty():
		return
	print("reverting stat changes")
	var battle_stats: BattleStats = manager.battle_stats[target]
	
	if "damage" in stat_modifications_applied and "damage" in battle_stats:
		var current_damage: float = battle_stats.get("damage")
		var reverted_damage: float = current_damage / stat_modifications_applied["damage"]
		battle_stats.set("damage", reverted_damage)
	
	if "accuracy" in stat_modifications_applied and "accuracy" in battle_stats:
		var current_accuracy: float = battle_stats.get("accuracy")
		var reverted_accuracy: float = current_accuracy / stat_modifications_applied["accuracy"]
		battle_stats.set("accuracy", reverted_accuracy)
	
	stat_modifications_applied.clear()

#this sucks but like... i don't want to think about what happens when OTHER stat downs are applied.

func trigger_curium_effect() -> void:
	var drenched_power = get_player_stats().get_stat('squirt_defense_boost')
	
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	
	damage_effect_triggered = true
	var bonus: int = 1 if not fresh_applied else 0
	var damage_amount: int = (amount * (rounds + bonus)*-5)*drenched_power
	
	manager.battle_node.focus_character(target)
	target.set_animation('pie-small')
	manager.affect_target(target, damage_amount)
	await manager.sleep(3.0)
	await manager.check_pulses([target])

func trigger_thorium_effect() -> void:
	var drenched_power = get_player_stats().get_stat('squirt_defense_boost')
	
	if not is_instance_valid(target):
		return
	
	damage_effect_triggered = true
	var bonus: int = 1 if not fresh_applied else 0
	var damage_amount: int = (((amount * (rounds + bonus)) / 2)*-5)*drenched_power
	var other_cogs: Array[Cog] = []
	
	for cog in manager.cogs:
		if cog != target:
			other_cogs.append(cog)
	
	if other_cogs.size() > 0:
		manager.battle_node.focus_cogs()
		
		for cog in other_cogs:
			cog.set_animation('pie-small')
		
		for cog in other_cogs:
			manager.affect_target(cog, damage_amount)
		
		await manager.sleep(3.0)
		await manager.check_pulses(other_cogs)

func renew() -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	getGF()
	
	match gf.atomic_effect:
		"curium":
			await trigger_curium_effect()
		"thorium":
			await trigger_thorium_effect()
	
	if fresh_applied:
		fresh_applied = false
	
	if is_instance_valid(particles):
		particles.amount = rounds

func getGF() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var root := tree.get_root()  # this is a Node (Viewport)
	gf = root.get_node_or_null("/root/ModLoader/alder-GreenFolio/GFglobal")
	if gf:
		print("gf test, ", gf.atomic_effect)

func expire() -> void:
	print("atomic expired")
	
	# Check if cog died and trigger damage effects if they haven't been triggered yet
	if target and target.stats.hp <= 0 and not damage_effect_triggered and gf:
		match gf.atomic_effect:
			"thorium":
				print("force triggering thorium with rounds, ", rounds)
				await manager.sleep(1.0)
				await trigger_thorium_effect()
			"curium":
				#await manager.sleep(1.0)
				#await trigger_curium_effect()
				pass
	
	revert_stat_modifications()
	
	if is_instance_valid(particles):
		particles.queue_free()
	
	if BattleService.s_round_ended.is_connected(shift_atomic_effect):
		BattleService.s_round_ended.disconnect(shift_atomic_effect)

func get_player_stats() -> PlayerStats:
	if is_instance_valid(BattleService.ongoing_battle):
		return BattleService.ongoing_battle.battle_stats[Util.get_player()]
	else:
		return Util.get_player().stats

func get_status_name() -> String:
	getGF()
	
	if gf and gf.atomic_effect:
		return "Atom - " + gf.atomic_effect.capitalize()
	return "ATOM"

func get_description() -> String:
	if not description == "":
		return description
	var full_description = ""
	
	getGF()
	
	var effect_cycle := ["plutonium", "actinium", "curium", "thorium"]
	var next_effect := ""
	
	if gf and gf.atomic_effect:
		var drenched_power = get_player_stats().get_stat('squirt_defense_boost')
		var current_index := effect_cycle.find(gf.atomic_effect)
		if current_index != -1:
			next_effect = effect_cycle[(current_index + 1) % effect_cycle.size()]
		
		var base_description := ""
		match gf.atomic_effect:
			"plutonium":
				var reduction_percent: int = roundi((-0.25*drenched_power) * (rounds+1) * 100)
				base_description = "-%d%% damage this round" % reduction_percent
			"actinium":
				var reduction_percent: int = roundi((-0.5*drenched_power) * (rounds+1) * 100)
				base_description = "-%d%% accuracy this round" % reduction_percent
			"curium":
				var damage_amount: int = (amount * (rounds + 1)*5)*drenched_power
				base_description = "Taking %d self damage this round" % damage_amount
			"thorium":
				var damage_amount: int = (((amount * (rounds + 1)) / 2)*5)*drenched_power
				base_description = "Dealing %d damage to other cogs this round" % damage_amount
		
		full_description = base_description
		full_description += "\nUsing squirt will cause an Atomic Blast, dealing %dx the gag's damage and replicating atoms to adjacent cogs!" % (rounds + 1)
		full_description += "\nCycling to %s next round!" % next_effect.capitalize()
		
	return full_description

func combine(effect: StatusEffect) -> bool:
	print("atomics combined")
	
	revert_stat_modifications() #revert or Terror
	
	fresh_applied = true
	rounds = min(effect.rounds + rounds, 4)
	
	if is_instance_valid(particles):
		particles.amount = rounds
	
	apply_atomic_modifications()
	
	return true
	
func get_icon() -> Texture2D:
	getGF()
	return ATOMIC_ICONS[gf.atomic_effect]
