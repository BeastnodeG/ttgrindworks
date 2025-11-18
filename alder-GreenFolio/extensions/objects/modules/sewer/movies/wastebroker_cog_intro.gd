extends BattleStartMovie
class_name WasteBrokerIntro

var directory: Node3D
var cog: Cog
var player

func play() -> Tween:
	directory = battle_node.get_parent()
	player = Util.get_player()
	cog = directory.cog
	
	movie = create_tween()
	
	# Camera 1 intro
	movie.tween_callback(directory.first_cam.make_current)
	movie.tween_callback(player.set_global_position.bind(directory.first_pos.global_position))
	movie.tween_callback(player.face_position.bind(directory.second_pos.global_position))
	movie.tween_callback(player.set_animation.bind("walk"))
	movie.tween_property(player, "global_position", directory.second_pos.global_position, 4.0)
	
	# Camera 1 push-in
	movie.parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var cam_forward = directory.first_cam.global_transform.basis * Vector3(0, 0, -15)
	movie.parallel().tween_property(
		directory.first_cam, "global_position",
		directory.first_cam.global_position + cam_forward, 4.0
	)
	
	movie.tween_callback(player.set_animation.bind("neutral"))
	movie.tween_callback(player.set_global_position.bind(directory.third_pos.global_position))
	movie.tween_callback(cog.speak.bind("Take a good look, everyone. Every piece of waste is dividend well earned."))
	movie.tween_interval(3.5)
	
	# Camera 2 rise
	movie.tween_callback(directory.second_cam.make_current)
	movie.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var cam_up = directory.second_cam.global_transform.basis * Vector3(0, 10, 0)
	movie.tween_property(
		directory.second_cam, "global_position",
		directory.second_cam.global_position + cam_up, 4.0
	)
	
	#Switch to third camera
	movie.tween_callback(directory.third_cam.make_current)
	movie.tween_callback(cog.speak.bind("Something smells funny..."))
	movie.tween_interval(2.25)
	
	#Waste Broker turns 180
	movie.tween_callback(directory.fourth_cam.make_current)
	movie.tween_callback(cog.set_animation.bind("walk"))
	movie.tween_property(cog, "global_rotation_degrees:y", cog.global_rotation_degrees.y + 180.0, 2.0)
	movie.tween_callback(cog.set_animation.bind("neutral"))
	movie.tween_callback(cog.speak.bind("Fresh garbage! Just in time for my next investment."))
	movie.tween_interval(2.5)
	
	movie.tween_callback(battle_node.battle_cam.make_current)
	movie.tween_callback(start_music)
	
	return movie

func _skip() -> void:
	if movie and movie.is_running():
		movie.custom_step(1000000.0)
		movie.finished.emit()
		movie.kill()
