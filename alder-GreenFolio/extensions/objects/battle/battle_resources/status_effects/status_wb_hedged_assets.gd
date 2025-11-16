@tool
extends StatBoost
class_name StatusEffectWBHedgedAssets

const SFX := preload("res://audio/sfx/battle/cogs/attacks/SA_audit.ogg")

const PHRASES := [
	"Risk has it's benefits.",
	"A little bit of trash can make your portfolio quite pristine.",
	"As long as I still have trash I'm still insured."
]

const CALCULATOR := preload("res://models/props/cog_props/calculator/calculator.glb")

var boost_amount := 0
const DEFENSE_PER_LIABILITY := 1.0

func apply():
	force_no_combine = true
	manager.s_status_effect_added.connect(update_defense)
	manager.s_participant_died.connect(update_defense)
	update_defense()

func update_defense(_arg = null) -> void:
	# Ensure cog exists
	var cog: Cog = target
	if not is_instance_valid(cog):
		return
	
	# Count liabilities on other cogs
	var liability_count := 0
	for cogcheck in manager.cogs:
		if cogcheck != cog:
			var statuses: Array[StatusEffect] = manager.get_statuses_for_target(cogcheck)
			for status in statuses:
				if status.status_name == "Liability":
					liability_count += 1
	
	# Reset defense to base value (StatBoost handles stacking cleanly)
	var battle_stats: BattleStats = manager.battle_stats.get(cog)
	if not battle_stats:
		return
		
	if liability_count > 0:
		visible = true
	else:
		visible = false
	
	boost = 1.0 + (liability_count * DEFENSE_PER_LIABILITY)
	battle_stats.set("defense", boost)
	print("Updated defense for %s: %s (Liabilities: %s)" % [cog.name, boost, liability_count])

func renew() -> void:
	var battle_node := manager.battle_node
	var cog: Cog = target

	# wow you're dead (?)
	if not is_instance_valid(cog) or cog.stats.hp == 0:
		return
	
	#status check
	var user = cog
	var heal_amount := 0
	
	for cogcheck in manager.cogs:
		if cogcheck != user:
			var statuses: Array[StatusEffect] = manager.get_statuses_for_target(cogcheck)
			var has_liability := false
			print("Cog:", cogcheck.name)
			for status in statuses:
				print("    Status Name:", status.status_name)
				if status.status_name == "Liability":
					has_liability = true
			if has_liability and cog.stats.hp < cog.stats.max_hp:
				heal_amount += ceil(cogcheck.stats.hp * 0.15)

	# If there’s healing to do, play animation
	if heal_amount > 0:
		# Movie Start
		var movie := manager.create_tween()
		
		var calculator : Node3D = CALCULATOR.instantiate()
		cog.body.left_hand_bone.add_child(calculator)
		calculator.rotation_degrees = Vector3(-60, 45, 130)
		
		# Focus Cog
		movie.tween_callback(battle_node.focus_character.bind(cog))
		
		movie.tween_callback(cog.speak.bind(RandomService.array_pick_random("true_random", PHRASES)))
		movie.tween_callback(cog.set_animation.bind("phone"))
		movie.tween_interval(2.0)
		movie.tween_callback(manager.affect_target.bind(cog, -heal_amount))
		movie.tween_interval(4.0)

		await Task.delay(0.4)
		AudioManager.play_sound(SFX)

		await movie.finished
		movie.kill()
		calculator.queue_free()

func get_icon() -> Texture2D:
	return load("res://ui_assets/battle/statuses/liability_waiver.png")
	
func get_status_name() -> String:
	return "Hedged Assets"

func get_description() -> String:
	var user: Cog = target
	var liability_count := 0
	
	for cogcheck in manager.cogs:
		if cogcheck != user:
			var statuses: Array[StatusEffect] = manager.get_statuses_for_target(cogcheck)
			for status in statuses:
				if status.status_name == "Liability":
					liability_count += 1

	var defense_bonus := liability_count * DEFENSE_PER_LIABILITY * 100
	var desc := "wow you shouldn't see this"
	if liability_count > 0:
		desc = "Regenerating HP equal to 15% of each Liable cog's current HP."
		desc += "\n+%d%% Defense" % defense_bonus
	return desc
