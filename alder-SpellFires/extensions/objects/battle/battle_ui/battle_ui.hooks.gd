extends Object

func _ready(chain: ModLoaderHookChain) -> void:
	var ui := chain.reference_object as BattleUI
	chain.execute_next()

	if ui and ui.fire_action:
		ui.fire_action.icon = load("res://ui_assets/misc/BookIcon_OPEN_old.png")
		ui.fire_action.action_name = "The Murder Spell"
		
		var button_text := ui.fire_button.get_node("ButtonText") as Label
		if button_text:
			button_text.text = "SPELL"

	ui.check_pink_slips()
