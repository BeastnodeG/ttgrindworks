extends BattleStartMovie
class_name GreenFinalBossIntro

const DEBUG_SKIP := false
const TM := preload('res://objects/cog/presets/sellbot/traffic_manager.tres')
const BK := preload('res://objects/cog/presets/cashbot/bookkeeper.tres')
const WB := preload('res://objects/cog/presets/lawbot/whistleblower.tres')
const UB := preload('res://objects/cog/presets/bossbot/union_buster.tres')

var directory: FinalBossScene:
	get: return battle_node.get_parent()
var boss1: Cog 
var boss2: Cog
var boss3: Cog
var boss4: Cog
var boss_cogs: Array[Cog]:
	get: return [boss1, boss2, boss3, boss4]

func play() -> Tween:
	boss1 = battle_node.cogs[0]
	boss2 = battle_node.cogs[1]
	boss3 = battle_node.cogs[2]
	boss4 = battle_node.cogs[3]
	for cog in battle_node.cogs:
		cog.set_animation('neutral')
	movie = get_four_boss_scene()
	return movie

func get_four_boss_scene() -> Tween: #not sure if this writing will stick but its what i could come up with... im no writer!!!!
	var tm := get_cog('Traffic Manager')
	var bk := get_cog('Bookkeeper') 
	var wb := get_cog('Whistleblower')
	var ub := get_cog('Union Buster')
	var player: Player = Util.get_player()
	
	var scene := create_tween()
	
	append_toon_elevator_shot(scene)
	scene.tween_callback(tween_buffer)
	
	append_char_move(scene, player, get_char_position('WalkInPos'), 3.0, true)
	scene.parallel().set_trans(Tween.TRANS_QUAD).tween_property(camera, 'global_transform', get_camera_angle('FocusBoss'), 3.0)
	
	if tm: append_char_turn(scene, tm, get_char_position('WalkInPos'), 3.0, true)
	if bk: append_char_turn(scene, bk, get_char_position('WalkInPos'), 3.0, true)
	if wb: append_char_turn(scene, wb, get_char_position('WalkInPos'), 3.0, true)
	if ub: append_char_turn(scene, ub, get_char_position('WalkInPos'), 3.0, true)
	
	scene.parallel().tween_callback(ub.speak.bind("So... the pest returns.")).set_delay(2.0)
	scene.tween_interval(3.5)
	
	append_cog_speak_shot(scene, bk, "Right on schedule, just as my projections indicated.", 4.0)
	
	append_cog_speak_shot(scene, ub, "Unlike our previous... mishaps, we've been coordinating.", 4.5)
	append_cog_speak_shot(scene, bk, "We've calculated this encounter, Toon.")
	
	scene.parallel().tween_callback(start_music)
	scene.set_trans(Tween.TRANS_QUAD).tween_property(camera, 'global_transform', get_camera_angle('FocusBoss'), 2.0)
	append_cog_speak_shot(scene, ub, "You've defeated us in pairs before...", 3, false)
	append_cog_speak_shot(scene, tm, "But now our schedules are all coordinated.", 3.5, false)
	append_cog_speak_shot(scene, bk, "With us unified, your odds of success have been reduced to zero!", 4.0, false)
	append_cog_speak_shot(scene, wb, "Your streak of success ends here.", 3, false)
	
	var give_em_the_works = RandomService.randi_channel('vile_writing') % 10 == 0
	if give_em_the_works:
		append_cog_speak_shot(scene, tm, "Let's give 'em the works...", 3.0, false)
		
		scene.tween_callback(battle_node.reposition_cogs)
		scene.set_trans(Tween.TRANS_QUAD).tween_property(camera, 'global_transform', get_camera_angle('BattleFocus'), 2.0)
		scene.tween_interval(0.5)
		scene.tween_callback(ub.set_animation.bind('buffed'))
		scene.parallel().tween_callback(ub.speak.bind("...the GRINDWORKS!")).set_delay(0)
		scene.tween_callback(wb.set_animation.bind('buffed'))
		scene.parallel().tween_callback(wb.speak.bind("...the GRINDWORKS!")).set_delay(0)
		scene.tween_callback(tm.set_animation.bind('buffed'))
		scene.parallel().tween_callback(tm.speak.bind("...the GRINDWORKS!")).set_delay(0)
		scene.tween_callback(bk.set_animation.bind('buffed'))
		scene.parallel().tween_callback(bk.speak.bind("...the GRINDWORKS!")).set_delay(0)
		scene.tween_interval(3.0)
	else:
		scene.tween_callback(battle_node.reposition_cogs)
		scene.set_trans(Tween.TRANS_QUAD).tween_property(camera, 'global_transform', get_camera_angle('BattleFocus'), 2.0)
		scene.tween_interval(0.5)
		append_cog_speak_shot(scene, tm, "It's time for you to clock out.", 3.0, false)
	
	return scene

func set_camera_angle(angle: String) -> void:
	camera.global_transform = get_camera_angle(angle)

func get_camera_angle(angle: String) -> Transform3D:
	return directory.get_node('CameraAngles/' + angle).global_transform

func get_char_position(pos: String) -> Vector3:
	return directory.get_node('CharPositions/'+ pos).global_position

func get_cog(cog_name: String) -> Cog:
	for cog in boss_cogs:
		if cog.dna.cog_name == cog_name:
			return cog
	return null

## USE THIS IF THE BOSS COGS' POSITIONS NEED TO BE SWAPPED BEFORE STARTING
func swap_cog_positions() -> void:
	var prev_pos = boss1.position
	boss1.position = boss2.position
	boss2.position = prev_pos

func debug_skip() -> Tween:
	var scene := create_tween()
	scene.tween_interval(2.0)
	battle_node.cogs.append_array(battle_node.get_parent().fill_elevator(2))
	scene.tween_callback(battle_node.reposition_cogs)
	return scene

func append_cog_speak_shot(tween : Tween, cog : Cog, phrase : String, time := 3.0, focus_character := true) -> void:
	if focus_character:
		tween.tween_callback(battle_node.focus_character.bind(cog))
	tween.tween_callback(cog.speak.bind(phrase))
	tween.tween_interval(time)

func append_toon_elevator_shot(tween : Tween, time := 3.0) -> void:
	tween.tween_callback(Util.get_player().set_global_position.bind(get_char_position("StartPos")))
	tween.tween_callback(Util.get_player().face_position.bind(battle_node.global_position))
	tween.tween_callback(camera.set_global_transform.bind(directory.elevator_in.elevator_cam.global_transform))
	tween.tween_callback(directory.elevator_in.open)
	tween.tween_interval(time)

func append_char_move(tween : Tween, character : Actor, pos : Vector3, time : float, parallel := false) -> void:
	if parallel:
		tween.set_parallel(true)
	tween.tween_callback(character.face_position.bind(pos))
	tween.tween_callback(character.set_animation.bind('walk'))
	tween.tween_property(character, 'global_position', pos, time)
	tween.tween_callback(character.set_animation.bind('neutral')).set_delay(time)
	if parallel:
		tween.set_parallel(false)

func append_char_turn(tween : Tween, character : Actor, pos : Vector3, time : float, parallel := false) -> void:
	if parallel:
		tween.set_parallel(true)
	var current_rotation := character.rotation.y
	character.face_position(pos)
	var goal_rotation := character.rotation.y
	character.rotation.y = current_rotation
	
	tween.tween_callback(character.set_animation.bind('walk'))
	tween.tween_property(character, 'rotation:y', goal_rotation, time).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_callback(character.set_animation.bind('neutral')).set_delay(time)
	if parallel:
		tween.set_parallel(false)

func tween_buffer() -> void:
	print("Tween Buffer")
