extends ItemScript

var MONARCH_STATUS := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/status_effect_monarch.tres")

const QUALITOON_DAMAGE := [4, 5, 7, 10, 13, 16] # q5 doesn't exist but we include it for safety... don't i sound so smart

var player: Player
var gf : Node = null

const PARTICLE := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchorbit.tscn")
const MonarchParticleFollow := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchparticlefollow.gd")

var player_particles: Array[GPUParticles3D] = []
var is_battle_active: bool = false

const BUTTERFLY_ICONS := {
	"Vampire": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_throw.png"),
	"Soak": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_squirt.png"),
	"Aftershock": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_drop.png"),
	"Hex": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_toonup.png"),
	"Cash": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_lure.png"),
	"Dragon": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_dragon.png"),
	"Poison": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_witch.png"),
	"Princess": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_princess.png"),
	"Fedora": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_fedora.png"),
	"Default": preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")
}

const EFFECT_MAP := {
	"Jellybean": { effect = "Cash", damage_multiplier = 0.5 },
	"Super Candy": { effect = "Hex", damage_multiplier = 1 },
	"Candy": { effect = "Hex", damage_multiplier = 0.75 },
	"Treasure": { effect = "Vampire", damage_multiplier = 0.5 },
	"Laff Boost": { effect = "Vampire", damage_multiplier = 0.75 },
	"Random": { effect = "Random", damage_multiplier = 1.25},
	"Task Reroll": { effect = "Random", damage_multiplier = 1 },
	"Toonup": { effect = "Hex", damage_multiplier = 0.75 },
	"Squirt": { effect = "Soak", damage_multiplier = 0.5 },
	"Trap": { effect = "Basic", damage_multiplier = 1.15 },
	"Lure": { effect = "Hex", damage_multiplier = 0.75 },
	"Sound": { effect = "Basic", damage_multiplier = 1.15 },
	"Throw": { effect = "Vampire", damage_multiplier = 0.9 },
	"Drop": { effect = "Aftershock", damage_multiplier = 0.75 },
	
	#start of specific accessories
	"Dragon Wings": { effect = "Dragon", damage_multiplier = 1.75 },
	"Dragonfly Wings": { effect = "Dragon", damage_multiplier = 1.5 },
	"Toonosaur Hat": { effect = "Dragon", damage_multiplier = 0.25},
	
	"Fedora": { effect = "Fedora", damage_multiplier = 2.5 },
	
	"Witch Hat": { effect = "Poison", damage_multiplier = 2.5 },
	"Green Deal": { effect = "Poison", damage_multiplier = 1.75 },
	"Space Helmet": { effect = "Poison", damage_multiplier = 2.5},
	
	"Princess Hat": { effect = "Princess", damage_multiplier = 3 },
	"Crown": { effect = "Princess", damage_multiplier = 1.5 },
	"Tiara": { effect = "Princess", damage_multiplier = 1.5 },
	"Opossum Charm": { effect = "Princess", damage_multiplier = 1.5},
	
	"Chef Hat": { effect = "Vampire", damage_multiplier = 1.1 },
	"Pixie Wings": { effect = "Vampire", damage_multiplier = 1.25 },
	"Bat Wings": { effect = "Vampire", damage_multiplier = 3 },
	"Heart Glasses": { effect = "Vampire", damage_multiplier = 1.25 },
	"Heart Headband": { effect = "Vampire", damage_multiplier = 1.25 },
	"Sandwich": { effect = "Vampire", damage_multiplier = 1 },
	"Emergency Unite": {effect = "Vampire", damage_multiplier = 1.5},
	"Smooch Glasses": {effect = "Vampire", damage_multiplier = 1.5},
	"Watering Can": {effect = "Vampire", damage_multiplier = 1.25},
	
	"Baseball Cap": { effect = "Basic", damage_multiplier = 2 },
	"Roman Helmet": { effect = "Basic", damage_multiplier = 1.1 },
	"Toys Backpack": { effect = "Basic", damage_multiplier = 1.1 },
	"Viking Helmet": { effect = "Basic", damage_multiplier = 1.1 },
	"Wooden Sword": { effect = "Basic", damage_multiplier = 1.75 },
	"Aviators": { effect = "Basic", damage_multiplier = 1.5 },
	
	"Bowler Hat": { effect = "Cash", damage_multiplier = 1.25 },
	"Fez": { effect = "Cash", damage_multiplier = 2 },
	"Fruit Hat": { effect = "Cash", damage_multiplier = 1.5 },
	"Pirate Hat": { effect = "Cash", damage_multiplier = 1.5 },
	"Jellybean Jar": { effect = "Cash", damage_multiplier = 1.5 },
	"Golden Jellybean": { effect = "Cash", damage_multiplier = 1.5 },
	"Tax Write-Off": { effect = "Cash", damage_multiplier = 1.5 },
	"Cash Register": { effect = "Cash", damage_multiplier = 1.5 },
	"Calculator": { effect = "Cash", damage_multiplier = 1.25 },
	
	"Gag Attack Pack": { effect = "Random", damage_multiplier = 1.25 },
	"Medium Pouch": { effect = "Random", damage_multiplier = 1.25 },
	"Celebrity Shades": { effect = "Random", damage_multiplier = 1.25 },
	"Star Glasses": { effect = "Random", damage_multiplier = 1.25 },
	"Mini Blinds": { effect = "Random", damage_multiplier = 2 },
	"Goggles": { effect = "Random", damage_multiplier = 1.5 },
	"Alien Glasses": { effect = "Random", damage_multiplier = 2 },
	"White-Out": { effect = "Random", damage_multiplier = 1 },
	"Paint Bucket": { effect = "Random", damage_multiplier = 1.5 },
	"Paint Brush": { effect = "Random", damage_multiplier = 1.25 },
	"Paintball": { effect = "Random", damage_multiplier = 0.5 },
	"Angel Wings": { effect = "Random", damage_multiplier = 1.25},
	"Butterfly Wings": { effect = "Random", damage_multiplier = 3 },
	"Philosopher's Stone": { effect = "Random", damage_multiplier = 1 },
	"Dilly Dial": { effect = "Random", damage_multiplier = 1 },
	"Moneybags Coin": { effect = "Random", damage_multiplier = 1 },
	"Spinning Top": { effect = "Random", damage_multiplier = 2 },
	"Alien Glasses?": { effect = "Random", damage_multiplier = 1.25 },
	"More Choices": { effect = "Random", damage_multiplier = 1.25 },
	"More Options": { effect = "Random", damage_multiplier = 1.25 },
	
	"Scuba Tank": { effect = "Soak", damage_multiplier = 1.25 },
	"Shark Fin": { effect = "Soak", damage_multiplier = 1.1 },
	"Scuba Mask": { effect = "Soak", damage_multiplier = 2 },
	"Fire Hydrant": { effect = "Soak", damage_multiplier = 1.1 },
	
	"Anvil Hat": { effect = "Aftershock", damage_multiplier = 1.2 },
	"Big Weight Hat": { effect = "Aftershock", damage_multiplier = 1.2 },
	"Bird Nest": { effect = "Aftershock", damage_multiplier = 1.2 },
	"Flowerpot Hat": { effect = "Aftershock", damage_multiplier = 1.2 },
	"Taser": { effect = "Aftershock", damage_multiplier = 1 },
	"Joybuzzer": { effect = "Aftershock", damage_multiplier = 1 },
	"Lightbulb": { effect = "Aftershock", damage_multiplier = 1 },
	
	"3D Glasses": { effect = "Hex", damage_multiplier = 1.1 },
	"Jester Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Police Hat": { effect = "Hex", damage_multiplier = 1.1 },
	"Pompadour Hairdo": { effect = "Hex", damage_multiplier = 1.1 },
	"Propeller Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Rainbow Wig": { effect = "Hex", damage_multiplier = 1.25 },
	"Wizard Hat": { effect = "Hex", damage_multiplier = 1.25 },
	"Toy Hammer": { effect = "Hex", damage_multiplier = 1.1 },
	"Groucho Glasses": { effect = "Hex", damage_multiplier = 1.1 },
	"Pink Slip": { effect = "Hex", damage_multiplier = 1.5 },
}

const RANDOM_EFFECT := {
	"Vampire": 0.75,
	"Hex": 0.75,
	"Soak": 0.75,
	"Aftershock": 1,
	"Basic": 1.25,
	"Cash": 0.75
}

func on_collect(_item: Item, _object: Node3D) -> void:
	var _player: Player
	if not Util.get_player():
		_player = await Util.s_player_assigned
	else:
		_player = Util.get_player()
	setup(_player)

func on_load(item: Item) -> void:
	on_collect(item, null)

func setup(_player: Player) -> void:
	player = _player
	getGF()
	BattleService.s_battle_started.connect(sendtheswarm)
	BattleService.s_round_ended.connect(sendtheswarm)
	BattleService.s_battle_started.connect(_on_battle_started)
	BattleService.s_battle_ended.connect(_on_battle_ended)
	
	call_deferred("_update_player_particles")
	# Start polling for absorbed item changes since no signal exists and im too lazy/dont think i can add one
	call_deferred("_start_polling_timer")

func getGF() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	if get_tree().get_root().has_node(path):
		gf = get_tree().get_root().get_node(path)
	else:
		pass

func _on_battle_started(manager: BattleManager) -> void:
	is_battle_active = true
	_hide_player_particles()

func _on_battle_ended() -> void:
	is_battle_active = false
	call_deferred("_update_player_particles")

func _start_polling_timer() -> void:
	if not gf or not gf.monarch_absorbed_items:
		return
		
	last_item_count = gf.monarch_absorbed_items.size()
	
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_check_for_item_changes)
	timer.start()

var last_item_count := 0
func _check_for_item_changes() -> void:
	if not gf or not gf.monarch_absorbed_items:
		return
	
	var current_count: int = gf.monarch_absorbed_items.size()
	if current_count != last_item_count:
		last_item_count = current_count
		if not is_battle_active:
			_update_player_particles()

func _hide_player_particles() -> void:
	for particle in player_particles:
		if particle and is_instance_valid(particle):
			particle.visible = false

func _show_player_particles() -> void:
	for particle in player_particles:
		if particle and is_instance_valid(particle):
			particle.visible = true

func _clear_player_particles() -> void:
	for particle in player_particles:
		if particle and is_instance_valid(particle):
			particle.queue_free()
	player_particles.clear()

func _count_butterfly_types() -> Dictionary:
	var butterfly_counts := {}
	
	if not gf or not gf.monarch_absorbed_items:
		return butterfly_counts
	
	for item in gf.monarch_absorbed_items:
		var effect_info := get_special_effect(item.name)
		var effect_type: String = effect_info.effect
		
		if effect_type == "Random":
			var random_effects := RANDOM_EFFECT.keys()
			effect_type = RandomService.array_pick_random('true_random', random_effects)
		
		butterfly_counts[effect_type] = butterfly_counts.get(effect_type, 0) + 1
	
	return butterfly_counts

func _update_player_particles() -> void:
	if not player or not player.head_node:
		print("Player or head_node not available for particles")
		return
	
	print("Updating player particles - battle active: %s" % str(is_battle_active))
	
	_clear_player_particles()
	
	var butterfly_counts := _count_butterfly_types()
	
	if butterfly_counts.is_empty():
		print("No butterflies to display")
		return
	
	print("Butterfly counts: %s" % str(butterfly_counts))
	
	var keys = butterfly_counts.keys()
	for i in range(keys.size()):
		var effect_type: String = keys[i]
		var count: int = butterfly_counts[effect_type]
		if count > 0:
			_create_player_particle(effect_type, count)
	
	if is_battle_active:
		_hide_player_particles()
	else:
		_show_player_particles()

func _create_player_particle(effect_type: String, count: int) -> void:
	var particles = PARTICLE.instantiate() as GPUParticles3D
	player.head_node.add_child(particles)
	particles.transform.origin = Vector3.ZERO
	particles.amount = count
	
	print("Creating %d particles for effect type: %s" % [count, effect_type])
	
	var mat = particles.draw_pass_1.material as StandardMaterial3D
	var shader = particles.process_material as ShaderMaterial
	
	shader.set_shader_parameter("seed", int(RandomService.randf_range_channel("true_random", 1, 50000)))
	mat.albedo_texture = BUTTERFLY_ICONS.get(effect_type, BUTTERFLY_ICONS["Default"])
	
	var follow_helper = MonarchParticleFollow.new()
	follow_helper.particle_node = particles
	follow_helper.target_bone = player.head_node
	particles.add_child(follow_helper)
	
	player_particles.append(particles)

func sendtheswarm(manager: BattleManager) -> void:
	if not player:
		return
	
	var absorbed_items = gf.monarch_absorbed_items
	print("Butterflies we're using: " + str(absorbed_items))
	
	if not manager.cogs or manager.cogs.is_empty():
		print("No cogs available to apply effects to.")
		return
	
	for item in absorbed_items:
		var qualitoon := int(item.get("qualitoon", 2))
		var base_damage: int = QUALITOON_DAMAGE[clamp(qualitoon, 0, 5)]
		var player_damage := player.stats.damage
		var total_damage: int = round(base_damage + player_damage)
		
		var cog: Cog = RandomService.array_pick_random('true_random', manager.cogs)
		var status := MONARCH_STATUS.duplicate(true)
		status.target = cog
		status.ButterflyAmount = qualitoon + 1
		
		var effect_info := get_special_effect(item.name)
		if effect_info.effect == "Dragon":
			var money_bonus := int((player.stats.money*2) / 5)
			status.amount = total_damage + money_bonus
		else:
			status.amount = round(total_damage * effect_info.damage_multiplier)
		
		status.SpecialEffect = effect_info.effect
		manager.add_status_effect(status)

func get_special_effect(item_name: String) -> Dictionary:
	for keyword in EFFECT_MAP.keys():
		if item_name == keyword:
			var base_info = EFFECT_MAP[keyword]
			var base_multiplier: float = float(base_info.damage_multiplier)
			
			if base_info.effect == "Random":
				var random_effects := RANDOM_EFFECT.keys()
				var chosen_effect: String = RandomService.array_pick_random('true_random', random_effects)
				var chosen_multiplier: float = float(RANDOM_EFFECT.get(chosen_effect, 1.0))
				var final_multiplier: float = base_multiplier * chosen_multiplier
				print("Random effect selected: %s (%.2f x %.2f = %.2f)" % [chosen_effect, base_multiplier, chosen_multiplier, final_multiplier])
				return {
					effect = chosen_effect,
					damage_multiplier = final_multiplier
				}
			return base_info
	
	return { effect = "Basic", damage_multiplier = 1.0 }
