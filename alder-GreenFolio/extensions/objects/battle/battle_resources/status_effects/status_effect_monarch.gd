@tool
extends StatEffectRegeneration
class_name StatEffectMonarch

const MonarchButterflyData := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/monarch_butterfly_data.gd")

@export var SpecialEffect: String = "Basic"
@export var ButterflyPower: int = 1
@export var TrueButterflyAmount: int = 1

const PARTICLE := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchorbit.tscn")
const MonarchParticleFollow := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchparticlefollow.gd")
var particles : GPUParticles3D
var _dapper_hp_snapshot: int = -1


func apply():
	call_deferred("_create_particles")
	if SpecialEffect == "Lightning":
		manager.s_round_started.connect(_on_round_started)
	if SpecialEffect == "Dapper":
		manager.s_round_started.connect(_on_dapper_round_started)


func _create_particles():
	# make particle
	particles = PARTICLE.instantiate() as GPUParticles3D
	target.body.head_bone.add_child(particles)
	particles.transform.origin = Vector3.ZERO
	particles.amount = TrueButterflyAmount
	particles.local_coords = false
	
	# make icon texture
	var mat = particles.draw_pass_1.material as StandardMaterial3D
	var shader = particles.process_material as ShaderMaterial
	shader.set_shader_parameter("seed", int(RandomService.randf_range_channel("true_random", 1, 50000)))
	mat.albedo_texture = MonarchButterflyData.BUTTERFLY_ICONS.get(SpecialEffect, MonarchButterflyData.BUTTERFLY_ICONS["Default"])

	# make helper
	var follow_helper = MonarchParticleFollow.new()
	follow_helper.particle_node = particles
	follow_helper.target_bone = target.body.head_bone
	particles.add_child(follow_helper)

func renew() -> void:
	if SpecialEffect == "Lightning":
		return
	if SpecialEffect == "Dapper":
		# Inject the hit into round_end_actions, which runs after ALL status effects renew.
		# _dapper_hp_snapshot was set at round start; _dapper_hit will compare it to HP then.
		if _dapper_hp_snapshot >= 0 and is_instance_valid(target) and target.stats.hp > 0:
			var action: ActionScriptCallable = ActionScriptCallable.new()
			action.callable = _dapper_hit
			action.user = manager.battle_node
			action.targets = [target]
			action.action_name = "Dapper Butterfly"
			action.special_action_exclude = true
			manager.round_end_actions.append(action)
		return
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return

	manager.battle_node.focus_character(target)

	var final_damage := amount
	print("effecting target with: ", final_damage)
	manager.affect_target(target, final_damage)

	apply_special_effects_on_hit(final_damage)
	
	target.set_animation("neutral")
	
	if target is Player:
		target.set_animation("cringe")
	else:
		target.set_animation("pie-small")

	await manager.sleep(1.3)
	await manager.check_pulses([target])

func apply_special_effects_on_hit(_damage: int) -> void:
	var player: Player = Util.get_player()

	match SpecialEffect:
		"Cash":
			if player:
				for i in ButterflyPower:
					if RandomService.randf_channel("true_random") <= 0.35:
						player.stats.add_money(1)
		"Hex":
			var stat = RandomService.array_pick_random("true_random", ["damage", "defense"])
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate(true)
			effect.stat = stat
			effect.boost = (-0.05 * ButterflyPower)
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			manager.add_status_effect(effect)
		"Princess":
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate(true)
			effect.stat = "damage"
			effect.boost = (-0.2)
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			manager.add_status_effect(effect)
		"Fedora":
			var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate(true)
			effect.stat = "defense"
			effect.boost = (-0.2)
			effect.rounds = 0
			effect.target = target
			effect.manager = manager
			effect.quality = StatusEffect.EffectQuality.NEGATIVE
			manager.add_status_effect(effect)
		"Vampire":
			if player:
				if RandomService.randf_channel("true_random") <= (0.05*ButterflyPower):
					var sfx := [
						"res://audio/sfx/battle/gags/toonup/AA_single_pixiedust_1.ogg",
						"res://audio/sfx/battle/gags/toonup/AA_single_pixiedust_2.ogg",
						"res://audio/sfx/battle/gags/toonup/AA_single_pixiedust_3.ogg",
						]
					var random_sfx: String = sfx.pick_random()
					AudioManager.play_sound.bind(load(random_sfx))
					var healing: int = int(ceil(_damage * 0.2 * player.stats.healing_effectiveness))
					player.stats.hp = min(player.stats.hp + healing, player.stats.max_hp)
					print("Vampire butterfly healed for", healing)
		"Soak":
			if player:
				var effect: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_drenched.tres").duplicate(true)
				effect.target = target
				effect.rounds = floori(ButterflyPower*0.5)
				effect.boost = player.stats.get_stat("squirt_defense_boost")
				manager.add_status_effect(effect)
		"Aftershock":
			if player:
				var effect := load("res://objects/battle/battle_resources/status_effects/resources/status_effect_aftershock.tres").duplicate(true)
				effect.target = target
				effect.amount = ceili(_damage * 0.25 + (ButterflyPower*0.05))
				if player.stats.get_stat("drop_aftershock_round_boost") != 0:
					effect.rounds += player.stats.get_stat("drop_aftershock_round_boost")
				manager.add_status_effect(effect)
		"Poison":
			if player:
				var effect := load("res://objects/battle/battle_resources/status_effects/resources/status_effect_poison.tres").duplicate(true)
				effect.target = target
				effect.rounds = -1
				effect.amount = ceili(_damage * 0.25)
				effect.icon = load("res://ui_assets/battle/statuses/poison.png")
					
				manager.add_status_effect(effect)
		"Booming":
			var splash_damage := ceili(_damage * 0.5 + (ButterflyPower*0.075))
			var other_cogs := manager.cogs.filter(func(c): return c != target and c.stats.hp > 0)
			if other_cogs.is_empty():
				return
			manager.battle_node.focus_cogs()
			for cog in other_cogs:
				manager.affect_target(cog, splash_damage)
				cog.set_animation("pie-small")
			await manager.check_pulses(other_cogs)
			await manager.sleep(1.3)
		_:
			pass

func get_icon() -> Texture2D:
	return MonarchButterflyData.BUTTERFLY_ICONS.get(SpecialEffect, MonarchButterflyData.BUTTERFLY_ICONS["Default"])
	
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
		"Lightning":
			return "Lightningfly"
		"Dapper":
			return "Dapper Butterfly"
		"Booming":
			return "Booming Butterfly"
		_:
			return "Monarch Butterfly"

func get_description() -> String:
	if SpecialEffect == "Dapper":
		return "Deals %d%% of ALL damage this cog takes." % (5 * ButterflyPower)

	var desc := "%d damage incoming" % amount

	match SpecialEffect:
		"Vampire":
			desc += "\n%d%% chance to lifesteal on hit" % min(100, roundi(ButterflyPower * 5))
		"Hex":
			desc += "\nApplies a random stat down"
		"Cash":
			desc += "\nChance to generate beans on hit"
		"Soak":
			desc += "\nApplies drenched on hit"
		"Aftershock":
			desc += "\nApplies aftershock on hit"
		"Dragon":
			desc += "\nYour wealth is it's power"
		"Princess":
			desc += "\nApplies damage down on hit"
		"Poison":
			desc += "\nApplies poison on hit"
		"Fedora":
			desc += "\nApplies defense down on hit"
		"Lightning":
			desc += "\nStrikes before cogs attack"
		"Booming":
			desc += "\nDeals %d damage to other cogs" % roundi(amount*0.5)
		_:
			pass

	return desc

func combine(effect: StatusEffect) -> bool:
	if effect.rounds == rounds and effect.SpecialEffect == SpecialEffect:
		amount += effect.amount
		ButterflyPower += effect.ButterflyPower
		TrueButterflyAmount += effect.TrueButterflyAmount
		print(TrueButterflyAmount)
		return true
	return false


func cleanup():
	if particles:
		particles.queue_free()
		particles = null
	if SpecialEffect == "Lightning" and manager.s_round_started.is_connected(_on_round_started):
		manager.s_round_started.disconnect(_on_round_started)
	if SpecialEffect == "Dapper" and manager.s_round_started.is_connected(_on_dapper_round_started):
		manager.s_round_started.disconnect(_on_dapper_round_started)
	pass

func randomize_effect() -> void:
	super()

func _on_round_started(actions: Array[BattleAction]) -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	var lightningfly := ActionScriptCallable.new()
	lightningfly.callable = _lightning_hit
	lightningfly.user = manager.battle_node
	lightningfly.targets = [target]
	lightningfly.action_name = "Lightningfly"
	lightningfly.special_action_exclude = true
	var inject_index := _find_inject_pos(actions)
	manager.round_actions.insert(inject_index, lightningfly)

func _find_inject_pos(actions: Array[BattleAction]) -> int:
	var index := 0
	var found_player := false
	while index < actions.size():
		var action: BattleAction = actions[index]
		if action is ToonAttack:
			found_player = true
		if action is CogAttack and found_player:
			break
		index += 1
	if not found_player:
		index = 0
		while index < actions.size() and BattleAction.ActionTag.PRIORITY_ACTION in actions[index].action_tags:
			index += 1
	return index

func _lightning_hit() -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	manager.battle_node.focus_character(target)
	var final_damage := amount
	print("effecting target with: ", final_damage)
	target.stats.hp -= final_damage
	manager.battle_text(target, str(-final_damage), Color('ff0000'), Color('7a0000'))
	apply_special_effects_on_hit(final_damage)
	
	target.set_animation("neutral")
	
	if target is Player:
		target.set_animation("cringe")
	else:
		target.set_animation("pie-small")
	await manager.sleep(1.3)
	await manager.check_pulses([target])

func _on_dapper_round_started(_actions: Array[BattleAction]) -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	_dapper_hp_snapshot = target.stats.hp

func _dapper_hit() -> void:
	if not is_instance_valid(target) or target.stats.hp <= 0:
		return
	if _dapper_hp_snapshot < 0:
		return
	var hp_lost: int = _dapper_hp_snapshot - target.stats.hp
	_dapper_hp_snapshot = -1
	if hp_lost <= 0:
		return
	var dapper_damage: int = ceili(hp_lost * 0.05 * ButterflyPower)
	manager.battle_node.focus_character(target)
	manager.affect_target(target, dapper_damage)
	target.set_animation("pie-small")
	await manager.sleep(1.3)
	await manager.check_pulses([target])
