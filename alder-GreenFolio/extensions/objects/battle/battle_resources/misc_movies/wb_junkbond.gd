extends CogAttack
class_name WasteBrokerJunkBond

const PHRASES := [
	"Let's put this trash to good use.",
	"Let's not let this opportunity go to waste.",
	"What's investing without a little risk?",
	"From rags to riches.",
]

const REINFORCEMENTS := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/misc_movies/call_reinforcementswb.tres")

#const BUCKET := preload("res://models/props/facility_objects/factory/paint_bucket/Bucket.fbx")
const BUCKET := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/modules/sewer/assets/trashbag.tscn")
const BucketPos = Vector3(0.735, 0.661, -0.653)
const BucketRot = Vector3(-2.3, 46.8, 58.2)

const DUST_CLOUD := preload("res://objects/props/etc/dust_cloud/dust_cloud.tscn")

#const SFX_PAINT_SPLASH := preload("res://audio/sfx/battle/cogs/attacks/special/CHQ_FACT_paint_splash.ogg")
const SFX_PAINT_HIT := preload("res://audio/sfx/battle/gags/drop/AA_drop_flowerpot_miss.ogg")

func action() -> void:
	if (not is_instance_valid(user)) or user.stats.hp <= 0:
		return
	#if len(manager.cogs) <= 1:
		#return
		
	var valid_targets: Array[Cog] = []
	for cogcheck in manager.cogs:
		if cogcheck == user:
			continue
		var statuses: Array[StatusEffect] = manager.get_statuses_for_target(cogcheck)
		var has_liability := false
		for status in statuses:
			if status.status_name == "Liability":
				has_liability = true
				break
		if not has_liability:
			valid_targets.append(cogcheck)
	print(valid_targets)
	if valid_targets.is_empty():
		print("printing cogs size: ", manager.cogs.size())
		if manager.cogs.size() >= 4:
			return
		var action := REINFORCEMENTS.duplicate(true)
		action.user = user
		if manager.cogs.size() >= 2:
			action.cog_amount = 1
		else:
			action.cog_amount = 2
		action.targets = [user]
		BattleService.ongoing_battle.round_actions.append(action)
		return
	else:
		print("targets not empty")
		
	manager.show_action_name("Junk Bond!", "Loan a attack and defense buff!")
	var new_target: Cog = RandomService.array_pick_random('true_random', valid_targets)
	targets = [new_target]
	var target: Cog = targets[0]
	
	var paint_bucket := BUCKET.instantiate()
	user.body.right_hand_bone.add_child(paint_bucket)
	paint_bucket.position = BucketPos
	paint_bucket.rotation_degrees = BucketRot
	
	battle_node.focus_character(user)
	user.speak(RandomService.array_pick_random('true_random', PHRASES))
	user.set_animation('throw-paper')
	await Task.delay(2.4)
	paint_bucket.reparent(battle_node)
	await user.get_tree().process_frame
	var new_pos: Vector3 = target.body.nametag_node.global_position + Vector3(0, 3, 0)
	var final_pos: Vector3 = target.body.nametag_node.global_position + Vector3(0, -2, 0)
	var projectile := Sequence.new([
		LerpProperty.new(paint_bucket, ^"global_position", 1.0, new_pos).interp(Tween.EASE_OUT, Tween.TRANS_QUAD),
		Parallel.new([
			LerpProperty.new(paint_bucket, ^"global_rotation", 0.4, Vector3(90, 0, 0)).interp(Tween.EASE_IN, Tween.TRANS_QUAD),
			LerpProperty.new(paint_bucket, ^"global_position", 0.6, final_pos).interp(Tween.EASE_IN, Tween.TRANS_QUAD)
		]),
	]).as_tween(user)
	await Task.delay(0.5)
	battle_node.focus_character(target)
	await manager.barrier(projectile.finished, 1.0)
	paint_bucket.queue_free()
	AudioManager.play_sound(SFX_PAINT_HIT)
	var dust_cloud = DUST_CLOUD.instantiate()
	target.add_child(dust_cloud)
	dust_cloud.scale *= target.scale
	dust_cloud.global_position = target.global_position
	var missing_hp: int = target.stats.max_hp - target.stats.hp
	if missing_hp >= 1:
		var heal_amount: int = int(ceil(missing_hp * -0.33))
		manager.affect_target(target, heal_amount, true)
		await Task.delay(0.3)
	await Task.delay(0.3)
	manager.battle_text(target, "Defense Up!", BattleText.colors.orange[0], BattleText.colors.orange[1])
	await Task.delay(0.6)
	manager.battle_text(target, "Attack Up!", BattleText.colors.orange[0], BattleText.colors.orange[1])
	
	var def_boost: StatBoost = load("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres").duplicate(true)
	def_boost.stat = "defense"
	def_boost.boost = 0.25
	def_boost.rounds = -1
	def_boost.quality = StatusEffect.EffectQuality.POSITIVE
	def_boost.target = target
	manager.add_status_effect(def_boost)
	
	var atk_boost: StatBoost = def_boost.duplicate(true)
	atk_boost.stat = "damage"
	atk_boost.boost = 0.25
	atk_boost.rounds = -1
	atk_boost.quality = StatusEffect.EffectQuality.POSITIVE
	atk_boost.target = target
	manager.add_status_effect(atk_boost)
	
	var liability: StatusEffect = load("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/status_effect_liability.tres").duplicate(true)
	liability.target = target
	manager.add_status_effect(liability)
	
	await Task.delay(1.4)
