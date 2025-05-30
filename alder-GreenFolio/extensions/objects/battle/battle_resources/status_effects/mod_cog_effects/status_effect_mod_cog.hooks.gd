extends Node

const CUSTOM_MOD_EFFECTS: Array[StatusEffect] = [
	preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/battle_resources/status_effects/resources/mod_cog_phisher.tres"),
]

func apply(chain: ModLoaderHookChain) -> void:
	print("running mod cog effect hook")
	var obj := chain.reference_object as StatusEffect

	var all_effects: Array[StatusEffect] = []
	var script := obj.get_script() as Script
	all_effects = script.MOD_EFFECTS.duplicate()

	all_effects += CUSTOM_MOD_EFFECTS

	if not all_effects.is_empty():
		var chosen: StatusEffect = RandomService.array_pick_random("mod_cog_effects", all_effects).duplicate()
		chosen.target = obj.target
		obj.manager.add_status_effect(chosen)
