extends Object

func play_pressed(chain: ModLoaderHookChain) -> void:
	var self_ref = chain.reference_object
	self_ref.get_node("GUI/Logo").hide()
	self_ref.state = self_ref.MenuState.TRANSITIONING
	var center_tween: Tween = self_ref.create_tween()
	center_tween.set_trans(Tween.TRANS_QUAD)
	center_tween.tween_property(self_ref.spring_arm, 'rotation_degrees', Vector3(-10.0, 0, 0), 1.0)
	center_tween.parallel().tween_property(self_ref.spring_arm, 'position', Vector3(0.0, 1.75, 5.0), 1.0)
	center_tween.parallel().tween_property(self_ref.spring_arm, 'spring_length', 2.5, 1.0)
	await center_tween.finished
	print("hijacked tween done")
	center_tween.kill()
	self_ref.state = self_ref.MenuState.NEW_GAME
	self_ref.new_game_menu.show()
	
