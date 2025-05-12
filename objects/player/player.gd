extends Actor
class_name Player

var PAUSE_MENU : PackedScene
const DEATH_THRESHOLD := -20.0
const COYOTE_TIME := 0.07
const IFRAME_TIME := 3.0

## Object states
enum PlayerState {
	WALK,
	STOPPED,
	SAD
}
@export var state := PlayerState.STOPPED:
	set(x):
		if state == PlayerState.SAD:
			# No more state transitions are allowed if you're sad.
			return
		state = x

## Preloads
const SFX_WALK := preload('res://audio/sfx/toon/AV_footstep_walkloop.ogg')
const SFX_RUN := preload('res://audio/sfx/toon/AV_footstep_runloop.ogg')
const DEBUG_COLLISION_PRINT := false

## Exports
@export var stats: PlayerStats:
	set(x):
		stats = x
		print('stats set')
@export var head_node: Node3D
@export var partners: Array[CharacterBody3D] = []

## Child References
@onready var camera := %PlayerCamera
@onready var camera_dist: float:
	set(x):
		var cam_tween := create_tween()
		cam_tween.tween_property(camera, 'spring_length', x, 0.1)
	get:
		return camera.spring_length
@onready var move_sfx := $MoveSFX
@onready var laff_meter := %LaffMeter
@onready var bean_jar := %BeanJar
@onready var toon: Toon = $Toon
@onready var character: PlayerCharacter:
	get:
		if not is_node_ready():
			await ready
		if not stats:
			return null
		return stats.character
@onready var item_node := $Items
@onready var boost_queue: BoostQueue = %BoostTextQueue

@onready var game_timer: Control = %GameTimer
var game_timer_tick := false:
	set(x):
		if not lock_game_timer:
			game_timer_tick = x
var lock_game_timer := false
@onready var active_item_ui : Control = %ActiveItemUI



## Misc.
var run_speed := 8.0
var speed = 0.0
var can_sprint := true
var can_jump := true
var jump_velocity := 7.0
var sprint: bool
var gravity := 16.0
var last_floor_time: float = 0.0
var last_damage_source: String = "Something"
const TURN_SPEED := 90.0
var control_style: bool:
	get: return SaveFileService.settings_file.control_style
var moving := false:
	set(x):
		moving = x
		if control_style:
			assess_anim()
var base_anim := 'neutral'
var animator: AnimationPlayer

## Item-Manipulated Values
var see_descriptions: bool = false:
	set(x):
		see_descriptions = x
		%ItemDescriptions.visible = x
var random_cog_heals := false
var custom_gag_order := false
var less_shop_items := false
var better_battle_rewards := false
var no_negative_anomalies := false
var throw_heals := true
var trap_needs_lure := true
var inverted_sound_damage := false
var obscured_anomalies := false
## Damage immunity from light-based obstacles, such as spotlights and goon beams.
var immune_to_light_damage := false
## Damage immunity from stompers and other crush-based obstacles
var immune_to_crush_damage := false
## Used in battle to override Gag prices
var free_gags : Array[ToonAttack] = []

var laff_lock_enabled := false:
	set(x):
		laff_lock_enabled = x
		if is_instance_valid(laff_meter):
			laff_meter.lock_enabled = x

var laff_lock := false:
	set(x):
		laff_lock = x
		if is_instance_valid(laff_meter):
			laff_meter.locked = x


signal s_fell_out_of_world(player: Player)
signal s_died
signal s_jumped
signal s_stats_connected(stats: PlayerStats)

func vanilla_3143482626__init() -> void:
	GameLoader.queue_into(GameLoader.Phase.GAMEPLAY, self, {
		'PAUSE_MENU': "res://objects/pause_menu/pause_menu.tscn",
	})

func vanilla_3143482626__ready() -> void:
	# Make player globally accessible
	Util.player = self
	
	# Construct the toon from the character DNA
	toon.construct_toon(character.dna)
	print('toon constructed')
	animator = toon.body.animator
	laff_meter.set_meter(character.dna)
	
	# Set to the neutral anim
	set_animation('neutral')
	
	# Correct rotation
	camera.rotate_y(rotation.y)
	toon.rotation.y = camera.rotation.y
	rotation = Vector3(0, 0, 0)
	
	# Hook up stats
	connect_stats()

func vanilla_3143482626__physics_process(delta: float) -> void:
	if state == PlayerState.WALK:
		_physics_process_walk(delta)
	
	# Movement SFX
	if get_animation() == 'walk':
		if move_sfx.stream != SFX_WALK:
			move_sfx.stream = SFX_WALK
			move_sfx.play()
	elif get_animation() == 'run':
		if move_sfx.stream != SFX_RUN:
			move_sfx.stream = SFX_RUN
			move_sfx.play()
	elif move_sfx.stream:
		move_sfx.stop()
		move_sfx.stream = null
	
	# Temp
	if Input.is_action_just_pressed('ui_focus_next') and laff_lock_enabled:
		laff_lock = not laff_lock

func vanilla_3143482626__physics_process_walk(delta: float) -> void:
	# Ensure mouse is captured while moving
	if Util.window_focused and not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Jump/Gravity
	var curr_time: float = Time.get_unix_time_from_system()
	var _floored: bool = is_on_floor()
	if _floored or (curr_time - last_floor_time) < COYOTE_TIME:
		if _floored:
			last_floor_time = curr_time
		if Input.is_action_just_pressed('jump') and can_jump:
			velocity.y = get_platform_velocity().y + jump_velocity
			s_jumped.emit()
			if moving: 
				set_animation('leap')
			else: 
				set_animation('jump')
	if not _floored:
		velocity.y -= gravity * delta
	
	# Get current movement speed
	var target_speed = run_speed
	sprint = should_sprint()
	if not sprint: target_speed /= 2.0
	target_speed *= stats.get_stat('speed')
	
	if speed != target_speed:
		speed = lerp(speed, target_speed, 0.2)
	
	if control_style:
		# Get the input/direction vectors
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction = direction.rotated(Vector3(0, 1, 0), camera.rotation.y)
		if direction:
			moving = true
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			moving = false
			speed = 0.0
			velocity.x = 0.0
			velocity.z = 0.0
	
		# Turn to face moving direction
		if direction:
			toon.rotation.y = lerp_angle(toon.rotation.y, atan2(direction.x, direction.z), .3)
	else:
		var input_dir := Input.get_axis('move_back','move_forward')
		if input_dir == -1 and sprint: 
			speed = (run_speed * stats.get_stat('speed')) / 2.0
		var direction = (toon.transform.basis * Vector3(0, 0, input_dir)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		var input_turn := Input.get_axis("move_left", "move_right")
		toon.rotation.y += (deg_to_rad(TURN_SPEED * delta) * -input_turn)
		recenter_camera()
		
		moving = (direction or input_turn)
		
		if is_on_floor() and not Input.is_action_just_pressed("jump") and can_jump:
			if input_dir == 1 and sprint:
				set_animation('run')
			elif input_turn or input_dir:
				set_animation('walk')
			else:
				set_animation('neutral')
	
	move_and_slide()

	if DEBUG_COLLISION_PRINT and OS.is_debug_build():
		var kc3d: KinematicCollision3D = get_last_slide_collision()
		if kc3d:
			print(get_tree().root.get_path_to(kc3d.get_collider(0)))

	# Camera zoom
	if Input.is_action_just_pressed('zoom_in'):
		camera_dist = max(camera_dist-0.5,1.5)
	elif Input.is_action_just_pressed('zoom_out'):
		camera_dist = min(camera_dist+0.5,4.0)
	
	# Camera sprint FOV
	if sprint:
		if camera.fov < 60:
			camera.fov = lerp(camera.fov,60.0,0.15)
	elif camera.fov > 52:
		camera.fov = lerp(camera.fov,52.0,0.15)
	
	# Emit signal when player is under death threshold
	if global_position.y < DEATH_THRESHOLD:
		s_fell_out_of_world.emit(self)
	
	if Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().get_root().add_child(PAUSE_MENU.instantiate())
	
	if Input.is_action_just_pressed('toggle_freecam') and SaveFileService.settings_file.dev_tools:
		var cam := PlayerFreeCam.new(self)
		cam.fov = camera.fov
		add_child(cam)
		cam.global_transform = camera.camera.global_transform
		set_animation('neutral')

func vanilla_3143482626_should_sprint() -> bool:
	if not can_sprint:
		return false
	
	if SaveFileService.settings_file.auto_sprint:
		return not Input.is_action_pressed('sprint')
	else:
		return Input.is_action_pressed('sprint')

func vanilla_3143482626_assess_anim() -> void:
	var anim := base_anim
	if is_on_floor() and not Input.is_action_just_pressed('jump'):
		if moving:
			if sprint:
				anim = 'run'
			else:
				anim = 'walk'
		if not get_animation() == anim:
			set_animation(anim)

func vanilla_3143482626_move_to(new_pos: Vector3, spd: float = run_speed, override_anim := "") -> Tween:
	# Stop player if not already
	if state == PlayerState.WALK:
		state = PlayerState.STOPPED
	# Calculate move time
	var time = new_pos.distance_to(global_position) / spd
	# Set movement anim
	if time > 0.5:
		set_animation('run')
	else:
		set_animation('walk')
	if override_anim != "":
		set_animation(override_anim)
	# Look at new position
	face_position(new_pos)
	# Use tween to move
	var move_tween = create_tween()
	move_tween.tween_property(self, 'global_position', new_pos, time)
	move_tween.finished.connect(move_tween_finished.bind(move_tween))
	return move_tween

func vanilla_3143482626_move_tween_finished(tween: Tween):
	set_animation('neutral')
	tween.kill()

func vanilla_3143482626_face_position(pos: Vector3):
	toon.look_at(Vector3(pos.x, global_position.y, pos.z), Vector3.UP, true)

func vanilla_3143482626_turn_to_position(pos: Vector3, time: float):
	set_animation('walk')
	var toon_scale: Vector3 = toon.scale
	var cur_rot: Vector3 = toon.global_rotation
	face_position(pos)
	var new_rot: Vector3 = toon.global_rotation
	toon.global_rotation = cur_rot
	
	var turn_tween := create_tween()
	turn_tween.set_parallel(true)
	turn_tween.tween_method(toon_lerp_angle.bind(cur_rot.y, new_rot.y, toon_scale), 0.0, 1.0, time)
	await turn_tween.finished
	turn_tween.kill()
	set_animation('neutral')

func vanilla_3143482626_toon_lerp_angle(weight: float, start_angle: float, end_angle: float, toon_scale: Vector3) -> void:
	toon.rotation.y = lerp_angle(start_angle, end_angle, weight)
	toon.set_scale(toon_scale)

func vanilla_3143482626_set_animation(anim : String):
	if not get_animation() == anim:
		toon.body.set_animation(anim)

func vanilla_3143482626_get_animation() -> String:
	return animator.current_animation

func vanilla_3143482626_lose():
	if state == PlayerState.SAD:
		# Thog don't care if we're already in the sad state
		return
	
	SaveFileService.on_game_over()
	state = PlayerState.SAD
	Util.stuck_lock = false
	set_animation('lose')
	await Task.delay(2.0)
	AudioManager.play_sound(load('res://audio/sfx/toon/ENC_Lose.ogg'))
	await Task.delay(2.0)
	var shrink_tween := create_tween()
	shrink_tween.tween_property(toon, 'scale', Vector3(.01, .01, .01), 2.0)
	await shrink_tween.finished
	shrink_tween.kill()
	SaveFileService.progress_file.deaths += 1
	s_died.emit()

func vanilla_3143482626_speak(phrase: String) -> void:
	toon.speak(phrase)

func vanilla_3143482626_teleport_in(set_to_walk := false) -> void:
	state = PlayerState.STOPPED
	await toon.teleport_in()
	if set_to_walk:
		state = PlayerState.WALK

func vanilla_3143482626_teleport_out() -> void:
	state = PlayerState.STOPPED
	await toon.teleport_out()

func vanilla_3143482626_fall_in(set_to_walk := false) -> void:
	state = PlayerState.STOPPED
	toon.position.y = 50.0
	toon.set_animation('slip_forwards')
	var fall_tween := create_tween()
	fall_tween.tween_property(toon, 'position:y', 0.0, 0.5)
	await fall_tween.finished
	AudioManager.play_sound(load("res://audio/sfx/toon/MG_cannon_hit_dirt.ogg"))
	await animator.animation_finished
	fall_tween.kill()
	if set_to_walk:
		state = PlayerState.WALK

func vanilla_3143482626_reset_stats() -> void:
	var newstats := PlayerStats.new()
	newstats.character = stats.character
	newstats.quests = stats.quests
	stats = newstats
	# Delete items if they exist
	if item_node:
		for item in item_node.get_children():
			item.queue_free()
	# Delete any accessory items
	if toon:
		var bones := [toon.body.hat_bone, toon.body.glasses_bone, toon.body.backpack_bone]
		for bone in bones:
			for child in bone.get_children():
				child.queue_free()
	
	if newstats.character:
		newstats.set_loadout(newstats.character.gag_loadout)
		newstats.first_time_setup()
		newstats.character.character_setup(self)
	if laff_meter:
		connect_stats()
	

func vanilla_3143482626_connect_stats() -> void:
	# Update laff meter on hp/max hp update
	laff_meter.max_laff = stats.max_hp
	laff_meter.laff = stats.hp
	laff_meter.extra_lives = stats.extra_lives
	laff_meter.lock_enabled = laff_lock_enabled
	bean_jar.bean_count = stats.money
	stats.hp_changed.connect(laff_meter.set_laff)
	stats.max_hp_changed.connect(laff_meter.set_max_laff)
	stats.s_money_changed.connect(func(x: int): bean_jar.bean_count = x)
	stats.s_gained_money.connect(bean_jar.scale_pop)
	stats.hp_changed.connect(check_hp)
	stats.s_extra_lives_changed.connect(func(x: int): laff_meter.extra_lives = x)
	# Regenerate points at end of round
	if not BattleService.s_round_ended.is_connected(stats.on_round_end):
		BattleService.s_round_ended.connect(stats.on_round_end)
	if not BattleService.s_battle_started.is_connected(stats.on_battle_started):
		BattleService.s_battle_started.connect(stats.on_battle_started)
	stats.s_active_item_changed.connect(func(newitem): active_item_ui.item = newitem)
	stats.current_active_item = stats.current_active_item
	if stats.current_active_item and not stats.current_active_item.node:
		stats.current_active_item.apply_item(self)
	s_stats_connected.emit(stats)

var prev_hp := -1
func vanilla_3143482626_check_hp(hp : int) -> void:
	if prev_hp > -1 and laff_lock and hp > prev_hp:
		stats.hp = prev_hp
	
	if hp == 0 and not BattleService.ongoing_battle:
		lose()
	prev_hp = stats.hp

func vanilla_3143482626_quick_heal(amount: int) -> void:
	var pre_hp := stats.hp
	# Apply healing effectiveness if we have it
	if amount > 0 and not is_equal_approx(stats.healing_effectiveness, 1.0):
		amount = roundi(amount * stats.healing_effectiveness)

	stats.hp += amount
	var diff := stats.hp - pre_hp
	if diff == 0:
		return
	if sign(diff) == -1:
		if state == PlayerState.WALK:
			do_invincibility_frames()
		Util.do_3d_text(self,str(diff))
	else:
		Util.do_3d_text(self, "+" + str(diff), Color.GREEN, Color.DARK_GREEN)

func vanilla_3143482626_recenter_camera(instant := true) -> void:
	if instant:
		camera.rotation = Vector3.ZERO
		camera.rotation_degrees.y = toon.rotation_degrees.y + 180.0

func vanilla_3143482626_do_invincibility_frames(time := IFRAME_TIME) -> void:
	set_collision_mask_value(Globals.HAZARD_COLLISION_LAYER, false)
	set_collision_layer_value(Globals.HAZARD_COLLISION_LAYER, false)
	await do_iframe_tween(time).finished
	set_collision_layer_value(Globals.HAZARD_COLLISION_LAYER, true)
	set_collision_mask_value(Globals.HAZARD_COLLISION_LAYER, true)

var iframe_tween : Tween
func vanilla_3143482626_do_iframe_tween(time := IFRAME_TIME) -> Tween:
	if iframe_tween:
		iframe_tween.kill()
	iframe_tween = create_tween()
	var delay := 0.25
	var delay_dec := 0.05
	var delay_mininmum := 0.1
	var blink_time := 0.0
	while delay > delay_mininmum:
		iframe_tween.tween_interval(delay)
		iframe_tween.tween_callback(swap_toon_visibility)
		blink_time += delay
		delay -= delay_dec
	delay = delay_mininmum
	while blink_time < time:
		iframe_tween.tween_interval(delay)
		iframe_tween.tween_callback(swap_toon_visibility)
		blink_time += delay
	iframe_tween.tween_callback(toon.body.show)
	return iframe_tween

func vanilla_3143482626_is_invincible() -> bool:
	return (iframe_tween and iframe_tween.is_running())

func vanilla_3143482626_swap_toon_visibility() -> void:
	toon.body.visible = not toon.body.visible

func vanilla_3143482626_update_accessories() -> void:
	var hat : ItemAccessory
	var glasses : ItemAccessory
	var backpack : ItemAccessory
	for item : Item in stats.items:
		if item is ItemAccessory:
			match item.slot:
				Item.ItemSlot.HAT: hat = item
				Item.ItemSlot.GLASSES: glasses = item
				Item.ItemSlot.BACKPACK: backpack = item
	if hat: hat.place_accessory(self)
	else: Util.free_all_children(toon.hat_bone)
	
	if glasses: glasses.place_accessory(self)
	else: Util.free_all_children(toon.glasses_bone)
	
	if backpack: backpack.place_accessory(self)
	else: Util.free_all_children(toon.backpack_bone)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _init():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626__init, [], 1209580501)
	else:
		vanilla_3143482626__init()


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626__ready, [], 1271791606)
	else:
		vanilla_3143482626__ready()


func _physics_process(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626__physics_process, [delta], 1680014018)
	else:
		vanilla_3143482626__physics_process(delta)


func _physics_process_walk(delta: float):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626__physics_process_walk, [delta], 1049757680)
	else:
		vanilla_3143482626__physics_process_walk(delta)


func should_sprint() -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_should_sprint, [], 3047102736)
	else:
		return vanilla_3143482626_should_sprint()


func assess_anim():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_assess_anim, [], 1600957688)
	else:
		vanilla_3143482626_assess_anim()


func move_to(new_pos: Vector3, spd: float=run_speed, override_anim: ="") -> Tween:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_move_to, [new_pos, spd, override_anim], 4117992443)
	else:
		return vanilla_3143482626_move_to(new_pos, spd, override_anim)


func move_tween_finished(tween: Tween):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_move_tween_finished, [tween], 989883460)
	else:
		return vanilla_3143482626_move_tween_finished(tween)


func face_position(pos: Vector3):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_face_position, [pos], 3456955813)
	else:
		return vanilla_3143482626_face_position(pos)


func turn_to_position(pos: Vector3, time: float):
	if _ModLoaderHooks.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_turn_to_position, [pos, time], 3764807969)
	else:
		return await vanilla_3143482626_turn_to_position(pos, time)


func toon_lerp_angle(weight: float, start_angle: float, end_angle: float, toon_scale: Vector3):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_toon_lerp_angle, [weight, start_angle, end_angle, toon_scale], 2173715834)
	else:
		vanilla_3143482626_toon_lerp_angle(weight, start_angle, end_angle, toon_scale)


func set_animation(anim: String):
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_set_animation, [anim], 2426314029)
	else:
		return vanilla_3143482626_set_animation(anim)


func get_animation() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_get_animation, [], 3626642209)
	else:
		return vanilla_3143482626_get_animation()


func lose():
	if _ModLoaderHooks.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_lose, [], 2119536213)
	else:
		return await vanilla_3143482626_lose()


func speak(phrase: String):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_speak, [phrase], 1233540406)
	else:
		vanilla_3143482626_speak(phrase)


func teleport_in(set_to_walk: =false):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_teleport_in, [set_to_walk], 4000431655)
	else:
		await vanilla_3143482626_teleport_in(set_to_walk)


func teleport_out():
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_teleport_out, [], 3165232616)
	else:
		await vanilla_3143482626_teleport_out()


func fall_in(set_to_walk: =false):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_fall_in, [set_to_walk], 3108147735)
	else:
		await vanilla_3143482626_fall_in(set_to_walk)


func reset_stats():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_reset_stats, [], 566752787)
	else:
		vanilla_3143482626_reset_stats()


func connect_stats():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_connect_stats, [], 2065532378)
	else:
		vanilla_3143482626_connect_stats()


func check_hp(hp: int):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_check_hp, [hp], 649490519)
	else:
		vanilla_3143482626_check_hp(hp)


func quick_heal(amount: int):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_quick_heal, [amount], 2181087384)
	else:
		vanilla_3143482626_quick_heal(amount)


func recenter_camera(instant: =true):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_recenter_camera, [instant], 1458936994)
	else:
		vanilla_3143482626_recenter_camera(instant)


func do_invincibility_frames(time: =IFRAME_TIME):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_3143482626_do_invincibility_frames, [time], 1196069518)
	else:
		await vanilla_3143482626_do_invincibility_frames(time)


func do_iframe_tween(time: =IFRAME_TIME) -> Tween:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_do_iframe_tween, [time], 1670482154)
	else:
		return vanilla_3143482626_do_iframe_tween(time)


func is_invincible() -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_3143482626_is_invincible, [], 2866396608)
	else:
		return vanilla_3143482626_is_invincible()


func swap_toon_visibility():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_swap_toon_visibility, [], 1027412899)
	else:
		vanilla_3143482626_swap_toon_visibility()


func update_accessories():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_3143482626_update_accessories, [], 1225728184)
	else:
		vanilla_3143482626_update_accessories()
