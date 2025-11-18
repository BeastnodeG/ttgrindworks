extends ItemScript

const ATOMIC_EFFECT := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/status_effect_atom.tres")
const POISON_EFFECT := preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_poison.tres")
var gf : Node = null
const ATOMIC_EFFECTS := ["plutonium", "actinium", "curium", "thorium"]

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	getGF()
	BattleService.s_round_started.connect(on_round_started)
	BattleService.s_round_ended.connect(on_round_end)

func on_round_started(actions : Array[BattleAction]) -> void:
	for action in actions:
		if action is GagSquirt:
			action.s_hit.connect(squirt_hit.bind(action))

func on_round_end(manager: BattleManager) -> void:
	print("shifting atomic effect")
	
	var current_index := ATOMIC_EFFECTS.find(gf.atomic_effect)
	if current_index == -1:
		current_index = 0
	
	var next_index := (current_index + 1) % ATOMIC_EFFECTS.size()
	gf.atomic_effect = ATOMIC_EFFECTS[next_index]
	
	print("new atomic effect is ", gf.atomic_effect)


func get_gag_level(action: ToonAttack) -> int:
	var loadout: GagLoadout = Util.get_player().stats.character.gag_loadout
	for track in loadout.loadout:
		for i in track.gags.size():
			if track.gags[i].action_name == action.action_name:
				return i
	return -1

func squirt_hit(action : GagSquirt) -> void:
	var gag_damage := action.damage
	print("squirt hit for! ", gag_damage)
	var cog: Cog = action.targets[0]
	
	if true: #cog.stats.hp > 0:
		var manager := BattleService.ongoing_battle
		var existing_atomic_status = null
		for status in manager.get_statuses_for_target(cog):
			if status.id == 664: #i guess you could say... this is its ATOMIC NUMBER
				existing_atomic_status = status
				break
		
		if existing_atomic_status:
			print("has existing atomic status, EXPLODING")
			trigger_atomic_blast(cog, existing_atomic_status, manager.get_damage(gag_damage, manager.current_action, cog))
		else:
			# Apply new atomic effect with 2 rounds - change 2 to something else once we work out squirt levels
			if cog.stats.hp > 0:
				print("doesn't have existing atomic status, not exploding")
				
				#i wonder if theres an existing way to do this... oh well!
				var gag_level := get_gag_level(action)
				print("Squirt gag level:", gag_level)
				
				var atomic_stacks := floori(gag_level / 2) + 1
				
				apply_atomic_effect(cog, manager.get_damage(gag_damage, manager.current_action, cog), atomic_stacks)

func trigger_atomic_blast(cog: Cog, atomic_status, base_damage: int) -> void:
	var manager := BattleService.ongoing_battle
	var atomic_rounds : int = atomic_status.rounds
	var bonus : int = 0
	if atomic_status.fresh_applied == false: #add a bonus so the atomic blast strength isn't a lie, fresh applied dont need this since they dont tick down on application
		bonus = 1
		print("applying bonus")
	var blast_damage : int = base_damage * (atomic_rounds + bonus)
	var adjacent_cogs: Array = []
	var cog_index := manager.cogs.find(cog)
	
	manager.expire_status_effect(atomic_status)
	play_explosion_effect(cog)
	
	if cog_index == -1:
		print("Cog %s not found in BattleManager." % cog.name)
		return
	
	for offset in [-1, 1]:
		var idx: int = cog_index + offset
		if idx >= 0 and idx < manager.cogs.size():
			var adjacent_cog := manager.cogs[idx]
			if adjacent_cog and adjacent_cog.stats.hp > 0:
				adjacent_cogs.append(adjacent_cog)
	
	for adjacent_cog in adjacent_cogs:
		print("Spreading Atomic from %s -> %s (%d rounds)" % [cog.name, adjacent_cog.name, atomic_rounds + bonus])
		apply_atomic_effect(adjacent_cog, base_damage, atomic_rounds + bonus)
		if Util.get_player().stats.has_item("Witch Hat"):
				print("has witch hat spreading poison")
				var poison_effect := POISON_EFFECT.duplicate(true)
				poison_effect.target = adjacent_cog
				poison_effect.amount = ceil(blast_damage*0.2)
				poison_effect.rounds = -1
				poison_effect.icon = load("res://ui_assets/battle/statuses/poison.png")
				BattleService.ongoing_battle.add_status_effect(poison_effect)
				#blast_damage * 0.2
	
	
	print("atomic blast %s takes %d damage (%d base * %d rounds)" % [cog.name, blast_damage, base_damage, atomic_rounds + bonus])
	#skip this section and skip to splitting the effect if cog hp is 0
	if cog.stats.hp >= 0:
		print("waiting for first animation, ", cog.stats.hp)
		#await manager.barrier(cog.animator.animation_finished, 4.0)
		await manager.sleep(0.25)
		await Util.s_process_frame
		manager.battle_node.focus_character(cog)
		manager.affect_target(cog, blast_damage, true)
		cog.set_animation("pie-small")
		print("dealt damage, waiting for second animation")
		await manager.barrier(cog.animator.animation_finished, 4.0)
		print("final animation complete")
		await manager.check_pulses([cog])
		
		
	#await manager.check_pulses([cog])

func apply_atomic_effect(cog : Cog, damage : int, rounds : int = 1) -> void:
	var atomic_effect := ATOMIC_EFFECT.duplicate(true)
	atomic_effect.target = cog
	atomic_effect.rounds = rounds
	atomic_effect.icon = load("res://ui_assets/battle/statuses/poison.png")
	BattleService.ongoing_battle.add_status_effect(atomic_effect)

func play_explosion_effect(cog: Node3D) -> void:
	AudioManager.play_sound(load("res://audio/sfx/battle/cogs/ENC_cogfall_apart.ogg"))
	var kaboom := Sprite3D.new()
	kaboom.render_priority = 1
	kaboom.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	kaboom.texture = load("res://models/props/gags/tnt/kaboom.png")
	cog.body.head_bone.add_child(kaboom)
	print("printing explosion info", kaboom.global_position, " ", cog.body.head_bone.global_position)
	kaboom.scale *= 2.5
	var kaboom_tween := create_tween()
	kaboom_tween.tween_property(kaboom, "pixel_size", 0.05, 0.25)
	await kaboom_tween.finished
	kaboom_tween.kill()
	kaboom.queue_free()

func get_damage(gag_damage : int) -> int:
	return ceili(gag_damage)

func getGF() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	if get_tree().get_root().has_node(path):
		gf = get_tree().get_root().get_node(path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", path)


func on_collect(_item : Item, model : Node3D) -> void:
	setup()

func onload(_item : Item) -> void:
	setup()
