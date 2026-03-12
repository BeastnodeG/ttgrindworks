extends ItemScript
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")
const MonarchButterflyData := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/monarch_butterfly_data.gd")

var MONARCH_STATUS := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/status_effect_monarch.tres")
var player: Player

var gf: Node = null

const PARTICLE := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchorbit.tscn")
const RAINBOW_SHADER := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarch_rainbow.gdshader")
const RAINBOW_BUTTERFLY_TEXTURE := preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")
const RAINBOW_MASK_TEXTURE := preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_butterfly_colormask.png")

var player_particles: Dictionary = {}
var particle_seeds: Dictionary = {}

var is_battle_active: bool = false
var _poll_timer: Timer = null

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
	gf = GFUTIL.get_gf()
	BattleService.s_battle_started.connect(sendtheswarm)
	BattleService.s_round_ended.connect(sendtheswarm)
	BattleService.s_battle_started.connect(_on_battle_started)
	BattleService.s_battle_ended.connect(_on_battle_ended)
	
	call_deferred("_update_player_particles")
	call_deferred("_start_polling_timer")

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
	
	_poll_timer = Timer.new()
	add_child(_poll_timer)
	_poll_timer.wait_time = 1.0
	_poll_timer.timeout.connect(_check_for_item_changes)
	_poll_timer.start()

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
	for particles in player_particles.values():
		if is_instance_valid(particles):
			particles.visible = false

func _show_player_particles() -> void:
	for particles in player_particles.values():
		if is_instance_valid(particles):
			particles.visible = true

func _clear_player_particles() -> void:
	for particles in player_particles.values():
		if is_instance_valid(particles):
			particles.queue_free()
	player_particles.clear()

func _count_butterfly_types() -> Dictionary:
	var butterfly_counts := {}
	
	if not gf or not gf.monarch_absorbed_items:
		return butterfly_counts
	
	for item in gf.monarch_absorbed_items:
		var base_info: Dictionary = MonarchButterflyData.EFFECT_MAP.get(item.name, { effect = "Basic", damage_multiplier = 1.0 })
		var effect_type: String = base_info.effect
		butterfly_counts[effect_type] = butterfly_counts.get(effect_type, 0) + 1
	
	return butterfly_counts

func _update_player_particles() -> void:
	if not player or not player.head_node:
		print("Player or head_node not available for particles")
		return
	
	var butterfly_counts := _count_butterfly_types()

	for effect_type in player_particles.keys():
		if not butterfly_counts.has(effect_type):
			if is_instance_valid(player_particles[effect_type]):
				player_particles[effect_type].queue_free()
			player_particles.erase(effect_type)

	for effect_type in butterfly_counts.keys():
		var count: int = butterfly_counts[effect_type]
		if player_particles.has(effect_type) and is_instance_valid(player_particles[effect_type]):
			player_particles[effect_type].amount = count
		else:
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
	
	var shader = particles.process_material as ShaderMaterial
	
	if not particle_seeds.has(effect_type):
		particle_seeds[effect_type] = int(RandomService.randf_range_channel("true_random", 1, 50000))
	shader.set_shader_parameter("seed", particle_seeds[effect_type])

	if effect_type == "Random":
		var rainbow_mat := ShaderMaterial.new()
		rainbow_mat.shader = RAINBOW_SHADER
		rainbow_mat.set_shader_parameter("albedo_texture", RAINBOW_BUTTERFLY_TEXTURE)
		rainbow_mat.set_shader_parameter("mask_texture", RAINBOW_MASK_TEXTURE)
		particles.draw_pass_1.material = rainbow_mat
	else:
		var mat = particles.draw_pass_1.material as StandardMaterial3D
		mat.albedo_texture = MonarchButterflyData.BUTTERFLY_ICONS.get(effect_type, MonarchButterflyData.BUTTERFLY_ICONS["Default"])
	
	player_particles[effect_type] = particles

func sendtheswarm(manager: BattleManager) -> void:
	if not player:
		return
	
	var absorbed_items = gf.monarch_absorbed_items
	print("Butterflies we're using: " + str(absorbed_items))
	
	if not manager.cogs or manager.cogs.is_empty():
		print("No cogs available to apply effects to.")
		return
	
	var atkstat: float = float(player.stats.damage)

	for item in absorbed_items:
		var effect_info := MonarchButterflyData.get_special_effect(item.name)

		var damage: int
		if effect_info.effect == "Dragon":
			var money_bonus := int((player.stats.money * 2) / 5)
			damage = MonarchButterflyData.calculate_damage(item, effect_info.damage_multiplier, atkstat) + money_bonus
		else:
			damage = MonarchButterflyData.calculate_damage(item, effect_info.damage_multiplier, atkstat)
		
		var cog: Cog = RandomService.array_pick_random('true_random', manager.cogs)
		var status := MONARCH_STATUS.duplicate(true)
		status.target = cog
		status.amount = damage
		status.ButterflyPower = MonarchButterflyData.get_butterfly_power(item)
		status.SpecialEffect = effect_info.effect
		manager.add_status_effect(status)
