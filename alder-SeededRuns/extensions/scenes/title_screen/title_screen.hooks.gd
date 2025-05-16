extends Node

var seed_input: LineEdit

func begin_game(chain: ModLoaderHookChain, character: PlayerCharacter, falling_scene := false) -> void:
	var self_ref = chain.reference_object

	if seed_input and seed_input.text.strip_edges() != "":
		var user_seed_text := seed_input.text.strip_edges()
		var user_seed: int
		if user_seed_text.is_valid_int():
			user_seed = int(user_seed_text)
			print("using numeric seed", user_seed_text, " > ", user_seed)
		else:
			user_seed = user_seed_text.hash()
			print("using hashed seed", user_seed_text, " > ", user_seed)
		RandomService.base_seed = user_seed
		seed(user_seed)
	else:
		print("we straight up doing normal gen!")
		RandomService.generate_seed()
	
	
	#reimplement existing logic
	if self_ref.has_existing_run:
		SaveFileService.progress_file.win_streak = 0
	
	SaveFileService.delete_run_file()
	Util.floor_number = -1
	await GameLoader.wait_for_phase(GameLoader.Phase.PLAYER)
	# Create the player object
	var player: Player = self_ref.PLAYER.instantiate()
	player.stats = PlayerStats.new()
	player.stats.character = character.duplicate(true)
	player.reset_stats()
	SceneLoader.add_persistent_node(player)
	player.stats.max_out()
	SaveFileService.progress_file.new_games += 1
	if falling_scene:
		SceneLoader.load_into_scene("res://scenes/falling_scene/falling_scene.tscn", GameLoader.Phase.FALLING_SEQ)
	else:
		SceneLoader.load_into_scene("res://scenes/cog_building/cog_building_floor.tscn", GameLoader.Phase.COG_BLDG_FLOOR)

func set_selected_toon(chain: ModLoaderHookChain, character: PlayerCharacter) -> void:
	var self_ref = chain.reference_object
	if not seed_input:
		seed_input = LineEdit.new()
		seed_input.placeholder_text = "Enter Seed"
		seed_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seed_input.anchor_left = 0.25
		seed_input.anchor_right = 0.75
		seed_input.anchor_top = 0.85
		seed_input.anchor_bottom = 0.90
		self_ref.add_child(seed_input)
	seed_input.show()
	chain.execute_next([character])

func toon_canceled(chain: ModLoaderHookChain) -> void:
	if seed_input:
		seed_input.hide()
	chain.execute_next()

func back_pressed(chain: ModLoaderHookChain) -> void:
	if seed_input:
		seed_input.hide()
	chain.execute_next()

func new_game(chain: ModLoaderHookChain) -> void:
	if seed_input:
		seed_input.hide()
	await chain.execute_next_async([])
