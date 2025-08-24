extends Object

func action(chain: ModLoaderHookChain) -> void:
	var fire := chain.reference_object as ToonAttackFire
	var manager := fire.manager
	var user: Player = fire.user
	var target: Cog = fire.targets[0]

	manager.s_focus_char.emit(user)

	var book_res := load("res://models/props/toon_props/shticker_book/shticker_bookopen.fbx")
	var book: Node3D = book_res.instantiate()
	user.toon.right_hand_bone.add_child(book)
	user.set_animation("book_open")
	book.get_node("AnimationPlayer").play("open")
	await user.animator.animation_finished
	user.set_animation("book_neutral")
	user.toon.speak("*Reads spell that instantly kills opponent*")
	await manager.sleep(4.0)
	if fire.cog_has_tenure(target):
		await fire.miss(target)
		return
	manager.s_focus_char.emit(target)
	target.speak("There is no way that is going to-")
	await manager.sleep(1.0)
	target.stats.hp = 0
	manager.someone_died(target)
	target.queue_free()
	await manager.sleep(2.0)

	book.queue_free()

func miss(chain: ModLoaderHookChain, cog: Cog) -> void:
	var fire := chain.reference_object as ToonAttackFire
	var manager := fire.manager
	var miss_tween := manager.create_tween()
	miss_tween.tween_callback(manager.battle_node.focus_character.bind(cog))
	miss_tween.tween_callback(manager.battle_text.bind(cog, 'MISSED'))
	miss_tween.tween_callback(cog.speak.bind("I know Counterspell, toon."))
	miss_tween.tween_interval(3.0)
	await miss_tween.finished
	miss_tween.kill()
