@tool
extends Control

const HOVER_SFX := preload("res://audio/sfx/ui/GUI_rollover.ogg")

const QualityColors := {
	FloorModifier.ModType.POSITIVE: Color(0.488, 1, 0.456),
	FloorModifier.ModType.NEUTRAL: Color("5190ff"),
	FloorModifier.ModType.NEGATIVE: Color(1, 0.336, 0.27),
}

@export var anomaly: GDScript:
	set(x):
		anomaly = x
		await NodeGlobals.until_ready(self)
		if anomaly:
			instantiated_anomaly = anomaly.new()
		else:
			instantiated_anomaly = null
var instantiated_anomaly: FloorModifier:
	set(x):
		instantiated_anomaly = x
		await NodeGlobals.until_ready(self)
		update_anomaly()

var quality: FloorModifier.ModType:
	get:
		if not instantiated_anomaly:
			return FloorModifier.ModType.NEGATIVE
		return instantiated_anomaly.get_mod_quality()

var obscured: bool:
	get:
		if not Util.get_player(): return false
		return Util.get_player().obscured_anomalies and not Util.get_player().see_anomalies

@onready var background: TextureRect = %Background
@onready var icon: TextureRect = %Icon
@onready var obscured_label: Label = %QuestionMark

var hover_seq: Tween:
	set(x):
		if hover_seq and hover_seq.is_valid():
			hover_seq.kill()
		hover_seq = x

func vanilla_1444728763__ready() -> void:
	if Engine.is_editor_hint():
		return

	mouse_entered.connect(hover)
	mouse_exited.connect(stop_hover)

func vanilla_1444728763_update_anomaly() -> void:
	if not instantiated_anomaly:
		return
	
	if not obscured:
		background.self_modulate = QualityColors[quality]
		icon.texture = instantiated_anomaly.get_mod_icon()
		icon.position = instantiated_anomaly.get_icon_offset()
	else:
		icon.hide()
		background.self_modulate = Color.DIM_GRAY
		obscured_label.show()

func vanilla_1444728763_hover() -> void:
	if not instantiated_anomaly:
		return

	HoverManager.hover(get_anomaly_description(), 18, 0.025, get_anomaly_name(), get_anomaly_color())
	hover_seq = Sequence.new([
		LerpProperty.new(self, ^"scale", 0.1, Vector2.ONE * 1.15).interp(Tween.EASE_IN_OUT, Tween.TRANS_QUAD),
	]).as_tween(self)
	AudioManager.play_sound(HOVER_SFX, 6.0)

func vanilla_1444728763_stop_hover() -> void:
	HoverManager.stop_hover()
	hover_seq = Parallel.new([
		LerpProperty.new(self, ^"scale", 0.1, Vector2.ONE).interp(Tween.EASE_IN_OUT, Tween.TRANS_QUAD),
	]).as_tween(self)


func vanilla_1444728763_get_anomaly_name() -> String:
	if not instantiated_anomaly:
		return ""
	
	if obscured: return "???"
	else: return instantiated_anomaly.get_mod_name()

func vanilla_1444728763_get_anomaly_description() -> String:
	if not instantiated_anomaly:
		return ""
	
	if obscured: return "???"
	else: return instantiated_anomaly.get_description()

func vanilla_1444728763_get_anomaly_color() -> Color:
	if obscured or not instantiated_anomaly: return Color.BLACK
	else: return QualityColors[quality].darkened(0.5)


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1444728763__ready, [], 4075321711)
	else:
		vanilla_1444728763__ready()


func update_anomaly():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1444728763_update_anomaly, [], 4244030446)
	else:
		vanilla_1444728763_update_anomaly()


func hover():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1444728763_hover, [], 524530303)
	else:
		vanilla_1444728763_hover()


func stop_hover():
	if _ModLoaderHooks.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_1444728763_stop_hover, [], 2797545316)
	else:
		vanilla_1444728763_stop_hover()


func get_anomaly_name() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1444728763_get_anomaly_name, [], 1984427531)
	else:
		return vanilla_1444728763_get_anomaly_name()


func get_anomaly_description() -> String:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1444728763_get_anomaly_description, [], 726032814)
	else:
		return vanilla_1444728763_get_anomaly_description()


func get_anomaly_color() -> Color:
	if _ModLoaderHooks.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_1444728763_get_anomaly_color, [], 1049056425)
	else:
		return vanilla_1444728763_get_anomaly_color()
