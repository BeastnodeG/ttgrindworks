@tool
extends StatusEffect

const GAG_BAN_EFFECT := preload('res://objects/battle/battle_resources/status_effects/resources/status_effect_gag_order.tres')

var logic_effect: StatusEffect
var player: Player:
	get: return target
var track_list: Array[Track]:
	get: return player.stats.character.gag_loadout.loadout
var trimmed_list: Array[Track] = []
var required_tracks: Array[Track] = []
var ban_effects: Array[StatusEffect] = []
var expires_this_round := false

var traffic_man: Cog


func vanilla_2136549973_apply() -> void:
	traffic_man = logic_effect.traffic_man
	trimmed_list = track_list.duplicate(true)
	manager.s_round_ended.connect(require_random_track)
	manager.s_round_started.connect(on_round_started)
	BattleService.s_battle_participant_died.connect(participant_died)

func vanilla_2136549973_cleanup() -> void:
	for ban_effect: StatusEffect in ban_effects:
		if ban_effect and is_instance_valid(ban_effect):
			manager.expire_status_effect(ban_effect)

	manager.s_round_ended.disconnect(require_random_track)
	manager.s_round_started.disconnect(on_round_started)
	BattleService.s_battle_participant_died.disconnect(participant_died)

func vanilla_2136549973_participant_died(who: Node3D) -> void:
	if who == traffic_man:
		manager.expire_status_effect(self)

func vanilla_2136549973_require_random_track() -> void:
	if expires_this_round:
		return
	trimmed_list.shuffle()
	var new_track: Track = trimmed_list.pop_back()
	required_tracks.append(new_track)
	var new_effect := make_banned_effect(new_track.gags)
	manager.add_status_effect(new_effect)
	ban_effects.append(new_effect)

func vanilla_2136549973_get_description() -> String:
	var desc := "Not using "
	for i in required_tracks.size():
		if i == required_tracks.size() - 1:
			if required_tracks.size() > 1: desc += " and "
			desc += required_tracks[i].track_name + " "
		elif i == 0:
			desc += required_tracks[i].track_name
		else: 
			desc += ", " + required_tracks[i].track_name
	desc += "will result in harsh retaliation"
	return desc

func vanilla_2136549973_make_banned_effect(gags: Array[ToonAttack]) -> StatusEffect:
	var banned_effect := GAG_BAN_EFFECT.duplicate(true)
	banned_effect.rounds = rounds
	banned_effect.target = player
	banned_effect.banned_color = Color.DARK_GREEN
	banned_effect.gags = gags
	return banned_effect

func vanilla_2136549973_on_round_started(actions: Array[BattleAction]) -> void:
	if rounds == 0:
		expires_this_round = true
	for effect in ban_effects:
		if not effect.is_banned_gag_used(actions):
			logic_effect.queue_retaliation()
			return


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func apply():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2136549973_apply, [], 3305407899)
	else:
		vanilla_2136549973_apply()


func cleanup():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2136549973_cleanup, [], 2819553885)
	else:
		vanilla_2136549973_cleanup()


func participant_died(who: Node3D):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2136549973_participant_died, [who], 355506153)
	else:
		vanilla_2136549973_participant_died(who)


func require_random_track():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2136549973_require_random_track, [], 1077520294)
	else:
		vanilla_2136549973_require_random_track()


func get_description() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2136549973_get_description, [], 1775261688)
	else:
		return vanilla_2136549973_get_description()


func make_banned_effect(gags: Array[ToonAttack]) -> StatusEffect:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2136549973_make_banned_effect, [gags], 2596687238)
	else:
		return vanilla_2136549973_make_banned_effect(gags)


func on_round_started(actions: Array[BattleAction]):
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2136549973_on_round_started, [actions], 473806447)
	else:
		vanilla_2136549973_on_round_started(actions)
