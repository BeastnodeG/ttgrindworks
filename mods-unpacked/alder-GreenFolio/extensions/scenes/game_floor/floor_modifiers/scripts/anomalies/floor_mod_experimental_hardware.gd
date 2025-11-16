extends FloorModifier

const RANDOM_EFFECTS : Array[StatusEffect] =[
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_stat_boost.tres"),
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_poison.tres"),
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_aftershock.tres"),
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_drenched.tres"),
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_regeneration.tres"),
	preload("res://objects/battle/battle_resources/status_effects/resources/status_effect_gag_immunity.tres"),
]

func modify_floor() -> void:
	BattleService.s_battle_started.connect(on_battle_start)

func on_battle_start(battle : BattleManager) -> void:
	for cog in battle.cogs:
		apply_random_effect(cog) # Apply random status immediately
	battle.s_participant_joined.connect(func(participant):
		if participant is Cog:
			apply_random_effect(participant) # New cog joining mid-battle also gets effect
	)
	#battle.s_status_effect_added.connect(on_status_effect_added)
	
	await Util.s_process_frame
	
	BattleService.s_refresh_statuses.emit()
	BattleService.ongoing_battle.battle_ui.cog_panels.reset(0)
	BattleService.ongoing_battle.battle_ui.cog_panels.assign_cogs(BattleService.ongoing_battle.cogs)

func apply_random_effect(cog : Cog) -> void:
	var effect : StatusEffect = RandomService.array_pick_random('true_random', RANDOM_EFFECTS).duplicate(true)
	effect.target = cog
	effect.randomize_effect()
	if effect is StatBoost:
		tweak_stat_boost(effect)
	if effect is StatEffectRegeneration:
		effect.instant_effect = false
	await Util.s_process_frame
	BattleService.ongoing_battle.add_status_effect(effect)

func tweak_stat_boost(effect : StatBoost) -> void:
	var valid_effects := ["defense", "damage"]
	if effect.stat not in valid_effects:
		effect.stat = RandomService.array_pick_random('true_random', valid_effects)

func on_status_effect_added(effect : StatusEffect) -> void:
	if effect is StatusLured:
		apply_random_effect(effect.target)

func get_mod_name() -> String:
	return "Experimental Hardware"

func get_mod_icon() -> Texture2D:
	return load("res://ui_assets/player_ui/pause/mixed_bag.png")

func get_description() -> String:
	return "Cogs start the battle with a random status effect."

func get_mod_quality() -> ModType:
	return ModType.NEUTRAL
