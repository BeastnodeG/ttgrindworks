extends FloorModifier

const BUDGET_TRACKS := ["Drop", "Lure", "Sound", "Squirt", "Throw", "Trap"]
const STATUS_EFFECT := preload('res://objects/battle/battle_resources/status_effects/resources/status_effect_budget_cuts.tres')

var removed_penalty := 0
var removed_track := ""

func modify_floor() -> void:
	BattleService.s_battle_started.connect(on_battle_start)
	BattleService.s_battle_ended.connect(remove_budget_cut)
	print("connected things for budget cuts")

func on_battle_start(battle : BattleManager) -> void:
	var player := Util.get_player()
	apply_budget_cut(player)
	await Util.s_process_frame
	BattleService.s_refresh_statuses.emit()

func remove_budget_cut() -> void:
	#print("trying to restore generation for ", removed_track, " penalty: ", removed_penalty)
	#var player := Util.get_player()
	#player.stats.gag_regeneration[removed_track] += (removed_penalty*-1)
	pass
		
func apply_budget_cut(player: Player) -> void:
	var effect := STATUS_EFFECT.duplicate(true)
	effect.target = player
	effect.track_name = RandomService.array_pick_random('true_random', BUDGET_TRACKS)
	effect.penalty = 1
	effect.rounds = -1
	effect.quality = "Positive"
	effect.status_name = "Budget Surplus"
	
	# Store info to revert later
	#removed_penalty = effect.penalty
	#removed_track = effect.track_name
	
	BattleService.ongoing_battle.add_status_effect(effect)

func get_mod_name() -> String:
	return "Budget Surplus"

func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/budget.png")

func get_description() -> String:
	return "A random gag track will regenerate +1 gag points each battle"

func get_mod_quality() -> ModType:
	return ModType.POSITIVE
