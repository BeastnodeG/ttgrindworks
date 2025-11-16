extends Node

const CUSTOM_MODS: Array[StatusEffect] = [
	preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/mod_cog_dragon_king.tres"),
	preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/mod_cog_phisher.tres"),
]

const ADMIN_BANNED_MODS: Array[String] = [
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_investment.tres", # dps check, not fun.
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_embezzler.tres", # misery since you cant stop damage
	"res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/mod_cog_dragon_king.tres", # too variable for an admin mod
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_wheelhouse.tres", #similar to dragon king ban
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_toxic.tres", #too strong
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_backtalker.tres", #too strong especially for low damage builds
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_diverse_portfolio.tres" #too strong
]

const BANNED_EFFECTS: Array[String] = [ #banned effects for floor 0/6
	"res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/mod_cog_dragon_king.tres",
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_toxic.tres",
	"res://objects/battle/battle_resources/status_effects/resources/mod_cog_backtalker.tres",
]

func apply(chain: ModLoaderHookChain) -> void:
	var obj := chain.reference_object as StatusEffect
	
	if not StatusEffectModCog.MOD_EFFECTS.has(CUSTOM_MODS[0]):
		StatusEffectModCog.MOD_EFFECTS += CUSTOM_MODS
		print("Added custom mod cogs to MOD_EFFECTS")
	
	var all_effects: Array[StatusEffect] = StatusEffectModCog.MOD_EFFECTS.duplicate(true)
	
	if obj.target.dna.is_admin:
		print("Target is admin, filtering banned effects")
		all_effects = all_effects.filter(func(effect: StatusEffect) -> bool:
			return not ADMIN_BANNED_MODS.has(effect.resource_path)
		)
	
	if Util.floor_number == 0 or Util.floor_number == 6:
		print("Floor 0/6 detected, filtering banned effects")
		all_effects = all_effects.filter(func(effect: StatusEffect) -> bool:
			return not BANNED_EFFECTS.has(effect.resource_path)
		)
	
	var original_effects := StatusEffectModCog.MOD_EFFECTS
	StatusEffectModCog.MOD_EFFECTS = all_effects
	
	chain.execute_next()
	
	StatusEffectModCog.MOD_EFFECTS = original_effects
