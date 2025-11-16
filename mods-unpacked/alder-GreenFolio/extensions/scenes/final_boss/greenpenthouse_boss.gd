extends Node3D
class_name GreenFinalBossScene

#like most things in this mod, PLEASE AVERT YOUR EYES

const TITLE_SCREEN_SCENE := "res://scenes/title_screen/title_screen.tscn"
const SKY_SPEED := 3.0
var COG_SCENE: PackedScene
var gfp : Node = null
var gf : Node = null

const SFX_CAGE_LOWER := preload("res://audio/sfx/misc/CHQ_SOS_cage_lower.ogg")
const SFX_CAGE_LAND := preload("res://audio/sfx/misc/CHQ_SOS_cage_land.ogg")

var WANT_DEBUG_BOSSES := false
var DEBUG_FORCE_BOSS_ONE: CogDNA = load("res://objects/cog/presets/lawbot/whistleblower.tres")
var DEBUG_FORCE_BOSS_TWO: CogDNA = load("res://objects/cog/presets/bossbot/union_buster.tres")
var DEBUG_FORCE_BOSS_THREE: CogDNA = load("res://objects/cog/presets/sellbot/traffic_manager.tres")
var DEBUG_FORCE_BOSS_FOUR: CogDNA = load("res://objects/cog/presets/cashbot/bookkeeper.tres")

var MUSIC_TRACK: AudioStream = load("res://audio/music/Bossbot_Entry_v2.ogg")

@export var possible_bosses: Array[CogDNA] = []

@onready var battle: BattleNode = $BattleNode
@onready var caged_toon: Toon = $Grp_animation/toonCage/CagedToon
@onready var boss_cog: Cog = $BattleNode/BossCog
@onready var boss_cog_2: Cog = $BattleNode/BossCog2
@onready var boss_cog_3: Cog = $BattleNode/BossCog3
@onready var boss_cog_4: Cog = $BattleNode/BossCog4
@onready var toon_cage: MeshInstance3D = $Grp_animation/toonCage

@onready var scene_animator: AnimationPlayer = $SceneAnimator

## Elevators
@onready var elevator_in: Elevator = $ElevatorEntrance
@onready var elevator_out: Elevator = $ElevatorExit

var unlock_toon := false
var unlock_mystery := false

## For battle tracking
const COG_LEVEL_RANGE := Vector2i(9, 14)
var boss_one_choice: CogDNA
var boss_two_choice: CogDNA
var boss_three_choice: CogDNA
var boss_four_choice: CogDNA

var boss_one_alive := true
var boss_two_alive := true
var boss_three_alive := true
var boss_four_alive := true

var total_boss_max_hp := 0

var darkened_sky := false

var triggered_75_percent := false
var triggered_50_percent := false
var triggered_25_percent := false

func _init():
	# GameLoader Requirement:
	# - cog.tscn has a very large dependency chain.
	#   Since this script extends Node and has a class_name, the editor will try
	#   to load all dependencies of it. This causes a large lag spike if preloaded.
	GameLoader.queue_into(GameLoader.Phase.GAMEPLAY, self, {
		'COG_SCENE': 'res://objects/cog/cog.tscn'
	})


func _ready() -> void:
	Globals.s_entered_barrel_room.emit()
	
	set_caged_toon_dna(get_caged_toon_dna())
	AudioManager.set_music(MUSIC_TRACK)
	
	# Pick all four bosses
	var boss_choices := possible_bosses.duplicate(true)
	
	# Boss 1
	if DEBUG_FORCE_BOSS_ONE != null and OS.is_debug_build() and WANT_DEBUG_BOSSES:
		boss_one_choice = DEBUG_FORCE_BOSS_ONE
	else:
		boss_one_choice = RNG.channel(RNG.ChannelBaseSeed).pick_random(boss_choices)
	boss_cog.set_dna(boss_one_choice)
	boss_choices.erase(boss_one_choice)

	# Boss 2
	if DEBUG_FORCE_BOSS_TWO != null and OS.is_debug_build() and WANT_DEBUG_BOSSES:
		boss_two_choice = DEBUG_FORCE_BOSS_TWO
	else:
		boss_two_choice = RNG.channel(RNG.ChannelBaseSeed).pick_random(boss_choices)
	boss_cog_2.set_dna(boss_two_choice)
	boss_choices.erase(boss_two_choice)
	
	# Boss 3
	if DEBUG_FORCE_BOSS_THREE != null and OS.is_debug_build() and WANT_DEBUG_BOSSES:
		boss_three_choice = DEBUG_FORCE_BOSS_THREE
	else:
		boss_three_choice = RNG.channel(RNG.ChannelBaseSeed).pick_random(boss_choices)
	boss_cog_3.set_dna(boss_three_choice)
	boss_choices.erase(boss_three_choice)
	
	# Boss 4
	if DEBUG_FORCE_BOSS_FOUR != null and OS.is_debug_build() and WANT_DEBUG_BOSSES:
		boss_four_choice = DEBUG_FORCE_BOSS_FOUR
	else:
		boss_four_choice = RNG.channel(RNG.ChannelBaseSeed).pick_random(boss_choices)
	boss_cog_4.set_dna(boss_four_choice)

	# Nerf their damage got damn!!!
	# nerfed again via our debuff (to 1.3 - 1.5 - 1.8 - 2.0)
	boss_cog.stats.damage = 1.8
	boss_cog_2.stats.damage = 1.8
	boss_cog_3.stats.damage = 1.8
	boss_cog_4.stats.damage = 1.8

	# Start the battle
	Util.get_player().state = Player.PlayerState.WALK
	battle.player_entered(Util.get_player())

	if not BattleService.ongoing_battle:
		await BattleService.s_battle_started

	# Every 2 rounds, starting on round 2: Spawn in 2 more cogs
	BattleService.ongoing_battle.s_round_started.connect(try_add_cogs)
	BattleService.ongoing_battle.s_participant_died.connect(participant_died)
	BattleService.ongoing_battle.s_battle_ending.connect(battle_ending)

	boss_cog.stats.hp_changed.connect(on_boss_hp_changed)
	boss_cog_2.stats.hp_changed.connect(on_boss_hp_changed)
	boss_cog_3.stats.hp_changed.connect(on_boss_hp_changed)
	boss_cog_4.stats.hp_changed.connect(on_boss_hp_changed)
	
	total_boss_max_hp = boss_cog.stats.max_hp + boss_cog_2.stats.max_hp + boss_cog_3.stats.max_hp + boss_cog_4.stats.max_hp
	
	apply_dissension(-0.5)
	
	BattleService.ongoing_battle.s_actions_ended.connect(func():
		print("========== ACTIONS ENDED - round_end_actions size: ", BattleService.ongoing_battle.round_end_actions.size())
)

	BattleService.ongoing_battle.s_round_ended.connect(func():
		print("========== ROUND ENDED - round_end_actions size: ", BattleService.ongoing_battle.round_end_actions.size())
)
	
func apply_dissension(boost_value: float) -> void:
	var manager = BattleService.ongoing_battle
	if not manager:
		return
	
	var alive_bosses: Array[Cog] = []
	if boss_one_alive and is_instance_valid(boss_cog):
		alive_bosses.append(boss_cog)
	if boss_two_alive and is_instance_valid(boss_cog_2):
		alive_bosses.append(boss_cog_2)
	if boss_three_alive and is_instance_valid(boss_cog_3):
		alive_bosses.append(boss_cog_3)
	if boss_four_alive and is_instance_valid(boss_cog_4):
		alive_bosses.append(boss_cog_4)
	
	for boss in alive_bosses:
		var dissension: StatBoost = load("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/directorboost/status_effect_dissension.tres").duplicate(true)
		dissension.boost = boost_value
		dissension.target = boss
		manager.add_status_effect(dissension)

func try_add_cogs(_actions: Array[BattleAction]) -> void: #i literally do not want to talk about this at all - not having access to classes makes things miserable and this was the best i could come up with
	var cooldown := 2
	for cog: Cog in battle.cogs:
		if cog.dna.cog_name == "Union Buster":
			cooldown = 1
	
	if BattleService.ongoing_battle.current_round % cooldown == 0 and get_alive_boss_count() > 0:
		print("PENTHOUSE REINFORCEMENT: trying to add cogs")
		var new_reinforcements := GreenElevatorReinforcements.new()
		new_reinforcements.user = self
		new_reinforcements.manager = BattleService.ongoing_battle
		new_reinforcements.battle_node = battle
		
		await BattleService.ongoing_battle.s_actions_ended
		
		await new_reinforcements.action()
		
		print("round_end_actions size after append: ", BattleService.ongoing_battle.round_end_actions.size())
		

func participant_died(who: Node3D) -> void:
	if who == boss_cog:
		boss_one_alive = false
		check_boss_defeat()
	elif who == boss_cog_2: 
		boss_two_alive = false
		check_boss_defeat()
	elif who == boss_cog_3:
		boss_three_alive = false
		check_boss_defeat()
	elif who == boss_cog_4:
		boss_four_alive = false
		check_boss_defeat()

func get_alive_boss_count() -> int:
	var count := 0
	if boss_one_alive: count += 1
	if boss_two_alive: count += 1
	if boss_three_alive: count += 1
	if boss_four_alive: count += 1
	return count

func battle_ending() -> void:
	Util.get_player().game_timer_tick = false
	Util.get_player().lock_game_timer = true
	Util.get_player().game_timer.become_full_visible()
	var win_time : float = Util.get_player().game_timer.time
	if win_time < 3600.0:
		Globals.s_one_hour_win.emit()
	if win_time < SaveFileService.progress_file.best_time or is_equal_approx(0.0, SaveFileService.progress_file.best_time):
		SaveFileService.progress_file.best_time = Util.get_player().game_timer.time

func to_dusk() -> void:
	$WorldEnvironment.environment = $WorldEnvironment.environment.duplicate(true)
	var env: Environment = $WorldEnvironment.environment
	
	var dusk_tween := create_tween()
	dusk_tween.tween_property(env, "ambient_light_energy", 0.7, 15.0)
	dusk_tween.parallel().tween_property(env, "ambient_light_color", Color("c3a192"), 15.0)
	dusk_tween.finished.connect(dusk_tween.kill)

func check_boss_defeat() -> void:
	var alive_count := get_alive_boss_count()
	
	if alive_count == 3 and not triggered_75_percent:
		on_75_percent_threshold()
	
	if alive_count == 2 and not triggered_50_percent:
		on_50_percent_threshold()
	
	if alive_count == 1 and not triggered_25_percent:
		on_25_percent_threshold()

func on_boss_hp_changed(_hp) -> void:
	if triggered_25_percent: return
	
	var current_hp := 0
	
	if boss_one_alive and is_instance_valid(boss_cog):
		current_hp += boss_cog.stats.hp
	
	if boss_two_alive and is_instance_valid(boss_cog_2):
		current_hp += boss_cog_2.stats.hp
	
	if boss_three_alive and is_instance_valid(boss_cog_3):
		current_hp += boss_cog_3.stats.hp
	
	if boss_four_alive and is_instance_valid(boss_cog_4):
		current_hp += boss_cog_4.stats.hp
	
	var hp_percent := float(current_hp) / float(total_boss_max_hp)
	
	print("PENTHOUSE FINAL: total hp is ", current_hp, "/", total_boss_max_hp, "(", hp_percent, ")")
	
	if hp_percent <= 0.70 and not triggered_75_percent:
		on_75_percent_threshold()
	
	if hp_percent <= 0.45 and not triggered_50_percent:
		on_50_percent_threshold()
	
	if hp_percent <= 0.15 and not triggered_25_percent:
		on_25_percent_threshold()

func on_75_percent_threshold() -> void:
	triggered_75_percent = true
	print("75% threshold triggered")
	apply_dissension(0.15)

func on_50_percent_threshold() -> void:
	triggered_50_percent = true
	print("50 threshold triggered")
	apply_dissension(0.25)
	if not darkened_sky:
		darkened_sky = true
		to_dusk()
		AudioManager.set_clip(2)

func on_25_percent_threshold() -> void:
	triggered_25_percent = true
	print("25% threshold triggered")
	apply_dissension(0.35)

func set_caged_toon_dna(dna: ToonDNA) -> void:
	caged_toon.construct_toon(dna)
	caged_toon.set_animation('neutral')

func get_caged_toon_dna() -> ToonDNA:
	var unlock_index: int = SaveFileService.progress_file.characters_unlocked
	var can_unlock: bool = unlock_index < 5
	if not SaveFileService.is_achievement_unlocked(ProgressFile.GameAchievement.UNLOCK_RANDOM):
		if Util.get_player().character.character_id == PlayerCharacter.Character.MOE:
			unlock_mystery = true
	if not can_unlock:
		var dna := ToonDNA.new()
		dna.randomize_dna()
		return dna
	unlock_toon = true
	return Globals.fetch_toon_unlock_order()[unlock_index].dna

func on_battle_finished() -> void:
	getGFP()
	getGF()
	if gfp.folio_unlocked <= gf.folio_level:
		gfp.folio_unlocked += 1
		print("folio level increased!")
	if unlock_toon:
		Globals.s_character_unlocked.emit(Globals.fetch_toon_unlock_order()[SaveFileService.progress_file.characters_unlocked])
		SaveFileService.progress_file.characters_unlocked += 1
	if unlock_mystery:
		SaveFileService.progress_file.unlock_achievement(ProgressFile.GameAchievement.UNLOCK_RANDOM)
	win_game()

func end_game() -> void:
	match Util.get_player().character.character_id:
		PlayerCharacter.Character.MYSTERY:
			if not SaveFileService.progress_file.mystery_toon_win:
				Globals.s_mystery_win.emit()
				SaveFileService.make_progress('mystery_toon_win', true)

	Globals.s_game_win.emit()
	for partner in Util.get_player().partners:
		partner.queue_free()
	Util.get_player().queue_free()
	SaveFileService.delete_run_file()
	SaveFileService._save_progress()
	SceneLoader.load_into_scene(TITLE_SCREEN_SCENE)

func fill_elevator(cog_count: int, dna: CogDNA = null) -> Array[Cog]:
	var roll_for_proxies : bool = SaveFileService.progress_file.proxies_unlocked and darkened_sky
	var new_cogs: Array[Cog]
	for i in cog_count:
		var cog := COG_SCENE.instantiate()
		cog.custom_level_range = COG_LEVEL_RANGE
		if dna: cog.dna = dna
		elif roll_for_proxies and RNG.channel(RNG.ChannelModCogChance).randf() < 0.25:
			cog.use_mod_cogs_pool = true
		battle.add_child(cog)
		cog.global_position = get_char_position("CogPos%d" % (i + 1))
		new_cogs.append(cog)
	return new_cogs

func get_char_position(pos: String) -> Vector3:
	return $CharPositions.get_node(pos).global_position

#region Final sequence

signal s_player_finished_walking
signal s_caged_toon_finished_walking

const FinalSpd := 3.0

func win_game() -> void:
	AudioManager.set_music(load("res://audio/music/encntr_hall_of_fame.ogg"))
	var player := Util.get_player()
	player.state = Player.PlayerState.STOPPED
	player.set_animation("neutral")
	var scene := create_tween()
	scene.tween_callback(player.set_global_position.bind(get_char_position('PlayerWinPos')))
	scene.tween_callback(player.face_position.bind(caged_toon.global_position))
	scene.tween_callback($CameraAngles.get_node('GameWin').make_current)
	scene.tween_callback(AudioManager.play_snippet.bind(SFX_CAGE_LOWER, 0.0, 1.0))
	scene.tween_property(toon_cage, 'position:y', -3.49, 1.0)
	scene.tween_callback(AudioManager.play_sound.bind(SFX_CAGE_LAND))
	scene.tween_property(toon_cage.get_node('cage_door'), 'rotation_degrees:x', 90.0, 0.5)
	scene.tween_callback(caged_toon.speak.bind("Whew, thanks for the rescue!"))
	
	if unlock_toon and SaveFileService.progress_file.characters_unlocked < 6:
		scene.tween_interval(4.0)
		scene.tween_callback(caged_toon.speak.bind("I think it's time I give the Cogs a little payback."))
		scene.tween_interval(4.0)
		scene.tween_callback(caged_toon.speak.bind("The least I could do is join you in taking them down!"))
	
	scene.tween_interval(4.0)
	scene.tween_callback(caged_toon.speak.bind("We should really get out of here, though."))
	scene.tween_interval(4.0)
	scene.tween_callback(caged_toon.speak.bind("The Cogs will have those big bads rebuilt in no time!"))
	scene.tween_interval(4.0)
	scene.tween_callback(caged_toon.speak.bind("."))
	await scene.finished

	CameraTransition.from_current(self, %GameWinElevator, 4.0, Tween.EASE_IN_OUT, Tween.TRANS_QUAD)
	elevator_out.open()
	do_move_player_seq()
	do_move_caged_toon_seq()
	await SignalBarrier.new([s_player_finished_walking, s_caged_toon_finished_walking]).s_complete
	elevator_out.close()
	# Fade out the victory music
	Sequence.new([
		LerpFunc.new(AudioManager.set_music_volume, 3.0, 0.0, -80.0)
	]).as_tween(self)
	await CameraTransition.from_current(self, %PaintingFocus, 3.0).s_done
	await Task.delay(1.0)
	%FadeOutLayer.show()
	await Sequence.new([
		LerpProperty.new(%BlackFade, ^"color:a", 2.0, 1.0).interp(Tween.EASE_IN, Tween.TRANS_QUAD)
	]).as_tween(self).finished
	await Task.delay(1.75)

	AudioManager.stop_music()
	AudioManager.set_music_volume(0.0)
	scene.kill()
	end_game()

func do_move_player_seq() -> void:
	var player: Player = Util.get_player()
	await player.turn_to_position(%InFrontElevatorPos.global_position, 1.0)
	await player.move_to(%InFrontElevatorPos.global_position, FinalSpd).finished
	# player.toon.global_rotation.y += TAU
	await player.turn_to_position(%ElevatorLeftPos.global_position, 1.0)
	await player.move_to(%ElevatorLeftPos.global_position, FinalSpd).finished
	await player.turn_to_position(Vector3.ZERO, 1.5)
	s_player_finished_walking.emit()

func do_move_caged_toon_seq() -> void:
	await Task.delay(0.5)
	await caged_toon.move_to(%PlayerWinPos.global_position, FinalSpd).finished
	await caged_toon.turn_to_position(%InFrontElevatorPos.global_position, 1.0)
	await caged_toon.move_to(%InFrontElevatorPos.global_position, FinalSpd).finished
	await caged_toon.turn_to_position(%ElevatorRightPos.global_position, 1.0)
	await caged_toon.move_to(%ElevatorRightPos.global_position, FinalSpd).finished
	await caged_toon.turn_to_position(Vector3.ZERO, 1.5)
	s_caged_toon_finished_walking.emit()
	
func getGFP() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFprogress"
	if get_tree().get_root().has_node(path):
		gfp = get_tree().get_root().get_node(path)
		print("Loaded GFprogress")
	else:
		print("GFprogress not found at", path)

func getGF() -> void:
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	if get_tree().get_root().has_node(path):
		gf = get_tree().get_root().get_node(path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", path)


# inline reinforcements because screw modloader
class GreenElevatorReinforcements extends ActionScript:
	func action() -> void:
		var alive_bosses : int = user.get_alive_boss_count()
		
		var max_cogs := 4
		if alive_bosses >= 3:
			max_cogs = 5
		
		var cogs_needed := mini(max_cogs - manager.cogs.size(), 2)
		print("PENTHOUSE REINFORCEMENT: printing cogs needed: ", cogs_needed)
		if cogs_needed <= 0:
			return
		
		var elevator: Elevator = user.elevator_out
		var new_cogs: Array[Cog] = user.fill_elevator(cogs_needed)
		
		battle_node.battle_cam.global_transform = elevator.elevator_cam.global_transform
		elevator.open()
		await manager.sleep(3.0)
		
		# theres probably a more direct way to do this but whatever its 1 am
		var boss_positions: Array[int] = []
		for i in range(manager.cogs.size()):
			if manager.cogs[i].stats.max_hp >= 2500:
				boss_positions.append(i)
		
		var boss_count := boss_positions.size()
		var insert_positions: Array[int] = []
		
		#yes this is hardcoded. no i dont want to talk about it.
		match boss_count:
			4:  # XXXX -> XXxXX
				if new_cogs.size() >= 1:
					insert_positions.append(2)
			3:  # XXX -> XxXxX (or from XxXX / XXxX)
				var gap1 := boss_positions[1] - boss_positions[0] - 1
				var gap2 := boss_positions[2] - boss_positions[1] - 1 
				
				if gap1 == 0 and gap2 > 0:
					insert_positions.append(1)
					if new_cogs.size() >= 2:
						insert_positions.append(3)
				elif gap2 == 0 and gap1 > 0:
					insert_positions.append(3) 
					if new_cogs.size() >= 2:
						insert_positions.append(1)
				else:
					insert_positions.append(1)
					if new_cogs.size() >= 2:
						insert_positions.append(3) 
			2:  # XX -> XxxX or XxxxX (or from XXx / xXX)
				var gap := boss_positions[1] - boss_positions[0] - 1
				
				if gap == 0:
					for i in range(new_cogs.size()):
						insert_positions.append(1 + i)
				else:
					for i in range(new_cogs.size()):
						insert_positions.append(1 + i)
			1:  # X -> xxXxx (or Xxxx / xxxX in rare cases)
				var boss_pos := boss_positions[0]
				var cogs_before := boss_pos
				var cogs_after := manager.cogs.size() - boss_pos - 1
				
				if cogs_before <= cogs_after:
					for i in range(new_cogs.size()):
						insert_positions.append(boss_pos)
				else:
					for i in range(new_cogs.size()):
						insert_positions.append(boss_pos + 1 + i)
			_:
				for i in range(new_cogs.size()):
					insert_positions.append(i)
		
		for i in range(new_cogs.size()):
			var cog = new_cogs[i]
			var pos = insert_positions[i] if i < insert_positions.size() else insert_positions[-1]
			manager.add_cog(cog, pos)
			cog.battle_start()
		
		battle_node.focus_cogs()
		battle_node.reposition_cogs()
		await manager.sleep(1.0)
		elevator.close()
		await manager.sleep(3.0)

#endregion

#endregion
