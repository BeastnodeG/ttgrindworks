extends Resource
class_name BattleStartMovie

# Not preloaded bc it shouldn't be needed
const FALLBACK_MUSIC := "res://audio/music/encntr_general_bg.ogg"

@export var skippable := false
@export var override_music : AudioStream

var battle_node : BattleNode
var camera : Camera3D
var focus_cog : Cog
var cogs : Array[Cog] = []
var override_shaking := false

var movie : Tween


## Run this to start the movie
## Default battle start movie example
func vanilla_188295339_play() -> Tween:
	movie = create_tween()
	movie.tween_callback(battle_node.focus_character.bind(focus_cog))
	movie.tween_callback(focus_cog.speak.bind(focus_cog.dna.battle_phrases.pick_random()))
	
	# Start the battle music
	movie.tween_callback(start_music)
	
	movie.tween_interval(2.0)
	
	return movie

func vanilla_188295339__skip() -> void:
	if movie and movie.is_running():
		movie.custom_step(1000000.0)
		movie.kill()

func vanilla_188295339_focus_random_cog(dial := "") -> Cog:
	if cogs.size() == 0:
		return null
	var cog: Cog = cogs.pick_random()
	battle_node.focus_character(cog, -4.01)
	if not dial == "":
		cog.speak(dial)
	return cog

## Attempts to start music, if correct music cannot be found, returns false.
func vanilla_188295339_start_music(music : AudioStream = null) -> bool:
	# If music is directly specified, use that.
	if music:
		AudioManager.set_music(music)
		return true
	# If there is override music specified in the resource, use that.
	elif override_music:
		AudioManager.set_music(override_music)
		return true
	# If all else fails, try the default battle track for the game floor
	elif Util.floor_manager and Util.floor_manager.floor_rooms.battle_music:
		AudioManager.set_music(load(Util.floor_manager.floor_rooms.battle_music))
		return true
	# If no track can be specified, use the fallback track
	AudioManager.set_music(load(FALLBACK_MUSIC))
	return false

## It's a resource so it can't tween by default
func vanilla_188295339_create_tween() -> Tween:
	var new_tween := battle_node.create_tween()
	new_tween.finished.connect(func(): new_tween.kill())
	return new_tween

## Runs look at on an object
func vanilla_188295339_face_object_towards(object_from : Node3D, object_to : Node3D) -> void:
	object_from.look_at(object_to.global_position)

func vanilla_188295339_face_character(character_from : Actor, node_to : Node3D) -> void:
	character_from.face_position(node_to.global_position)

## USEFUl UNIVERSAL CUTSCENE FUNCTIONS ## 
func vanilla_188295339_shake_camera(cam : Camera3D, time : float, offset : float, taper := true, x := true, y := true, z := true) -> void:
	var base_pos := cam.global_position
	var shaking := true
	
	var timer := cam.get_tree().create_timer(time)
	
	while shaking and not override_shaking:
		await Util.s_process_frame
		var new_offset : float
		if taper:
			new_offset = offset * timer.time_left/time
		else:
			new_offset = offset
		if x:
			cam.global_position.x = base_pos.x + randf_range(-new_offset,new_offset)
		if y:
			cam.global_position.y = base_pos.y + randf_range(-new_offset,new_offset)
		if z:
			cam.global_position.z = base_pos.z + randf_range(-new_offset,new_offset)
		
		if timer.time_left <= 0 or override_shaking:
			shaking = false


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func play() -> Tween:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_188295339_play, [], 3756181761)
	else:
		return vanilla_188295339_play()


func _skip():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_188295339__skip, [], 3675015201)
	else:
		vanilla_188295339__skip()


func focus_random_cog(dial: ="") -> Cog:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_188295339_focus_random_cog, [dial], 1693721251)
	else:
		return vanilla_188295339_focus_random_cog(dial)


func start_music(music: AudioStream=null) -> bool:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_188295339_start_music, [music], 2342157849)
	else:
		return vanilla_188295339_start_music(music)


func create_tween() -> Tween:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_188295339_create_tween, [], 3859218561)
	else:
		return vanilla_188295339_create_tween()


func face_object_towards(object_from: Node3D, object_to: Node3D):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_188295339_face_object_towards, [object_from, object_to], 3281170163)
	else:
		vanilla_188295339_face_object_towards(object_from, object_to)


func face_character(character_from: Actor, node_to: Node3D):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_188295339_face_character, [character_from, node_to], 4055522118)
	else:
		vanilla_188295339_face_character(character_from, node_to)


func shake_camera(cam: Camera3D, time: float, offset: float, taper: =true, x: =true, y: =true, z: =true):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_188295339_shake_camera, [cam, time, offset, taper, x, y, z], 2660128927)
	else:
		await vanilla_188295339_shake_camera(cam, time, offset, taper, x, y, z)
