extends StatBoost

func get_icon() -> Texture2D:
	if boost <= 0:
		return GameLoader.load("res://ui_assets/battle/statuses/wheelhouse.png")
	else:
		return GameLoader.load("res://ui_assets/battle/statuses/wheelhouse.png")

func get_status_name() -> String:
	if boost <= 0:
		return "Dissension"
	else:
		return "Desperation"

func get_quality() -> EffectQuality:
	if boost <= 0.0:
		return EffectQuality.NEGATIVE
	return EffectQuality.POSITIVE

func combine(effect: StatusEffect) -> bool:
	if effect.get_script() == get_script() and rounds == effect.rounds:
		expire()
		boost += effect.boost
		apply()
		return true
	return false
