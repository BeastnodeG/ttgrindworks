extends Node3D


@onready var entrance_elevator : Elevator = $EntranceElevator
@onready var exit_elevator : Elevator = $ExitElevator
@onready var intro_camera : Camera3D = $ElevatorCam
@onready var walk_pos : Node3D = $PlayerWalkPos

func vanilla_4197637939__ready() -> void:
	intro_camera.make_current()
	var player := Util.get_player()
	player.game_timer_tick = false
	player.global_position = entrance_elevator.player_pos.global_position
	player.toon.rotation_degrees.y = 180.0
	
	play_intro(player)
	
	Globals.s_entered_barrel_room.emit()
	
	player.stats.clear_quests()
	clear_items_in_play(player.stats)

func vanilla_4197637939_play_intro(player : Player) -> void:
	var intro_tween := create_tween()
	intro_tween.tween_callback(AudioManager.stop_music.bind(true))
	intro_tween.tween_callback(AudioManager.set_music.bind(load("res://audio/music/encntr_penultimate/pre_getw.ogg")))
	intro_tween.tween_interval(5.0)
	intro_tween.tween_callback(entrance_elevator.open)
	intro_tween.tween_interval(2.0)
	intro_tween.tween_callback(player.set_animation.bind('walk'))
	intro_tween.tween_property(player,'global_position',walk_pos.global_position,3.0)
	intro_tween.tween_callback(player.set_animation.bind('neutral'))
	intro_tween.parallel().tween_callback(entrance_elevator.close).set_delay(2.0)
	intro_tween.tween_interval(1.5)
	await intro_tween.finished
	intro_tween.kill()
	player.camera.make_current()
	player.state = Player.PlayerState.WALK
	player.game_timer_tick = true


## Attempt to clean out any remaining, unretrievable items
func vanilla_4197637939_clear_items_in_play(stats: PlayerStats) -> void:
	var safe_items: Array[Item] = []
	for quest: Quest in stats.quests:
		safe_items.append(quest.item_reward)
	for item in ItemService.items_in_play.duplicate(true):
		if not item in safe_items:
			ItemService.item_removed(item)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4197637939__ready, [], 2388280039)
	else:
		vanilla_4197637939__ready()


func play_intro(player: Player):
	if _ModLoaderHooks.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_4197637939_play_intro, [player], 3920213300)
	else:
		await vanilla_4197637939_play_intro(player)


func clear_items_in_play(stats: PlayerStats):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_4197637939_clear_items_in_play, [stats], 1535800902)
	else:
		vanilla_4197637939_clear_items_in_play(stats)
