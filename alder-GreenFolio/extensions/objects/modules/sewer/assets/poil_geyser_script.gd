extends Node3D
@export var delay: float = 1.0
@export var offset: float = 0.0
@export var hold_time: float = 2.0
@export var speed: float = 2.0
@export var bounce_amount: int = 2
@export var bounce_height_percent: float = 0.05
@export var trans_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
var rest_position: Vector3
var max_position: Vector3
var travel_distance: float
func _ready() -> void:
	max_position = position
	
	var geyser_mesh: MeshInstance3D = $geyserRise
	var aabb: AABB = geyser_mesh.get_aabb()
	
	# Use local transform for scale calculation and multiply by 4 for geyser scale
	var scale: Vector3 = geyser_mesh.transform.basis.get_scale()
	travel_distance = aabb.size.y * scale.y * 4.0
	
	rest_position = max_position - Vector3(0, travel_distance, 0)
	
	position = rest_position
	
	if offset > 0.0:
		await get_tree().create_timer(offset).timeout
	
	start_tween_loop()
func start_tween_loop() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(trans_type)
	
	tween.tween_property(self, "position", max_position, speed).set_ease(Tween.EaseType.EASE_IN_OUT)
	
	if hold_time > 0.0 and bounce_amount > 0:
		var bounce_height: float = travel_distance * bounce_height_percent
		var bounce_duration: float = hold_time / bounce_amount
		create_bounces(tween, bounce_height, bounce_duration)
	elif hold_time > 0.0:
		tween.tween_interval(hold_time)
	
	tween.tween_property(self, "position", rest_position, speed).set_ease(Tween.EaseType.EASE_IN_OUT)
	
	if delay > 0.0:
		tween.tween_interval(delay)
func create_bounces(tween: Tween, bounce_height: float, bounce_duration: float) -> void:
	var bounce_time_per_direction = bounce_duration * 0.5  # Half for up, half for down
	
	for i in bounce_amount:
		# Bounce down
		var down_position = Vector3(max_position.x, max_position.y - bounce_height, max_position.z)
		tween.tween_property(self, "position", down_position, bounce_time_per_direction).set_ease(Tween.EaseType.EASE_IN_OUT)
		
		# Bounce back up
		tween.tween_property(self, "position", max_position, bounce_time_per_direction).set_ease(Tween.EaseType.EASE_IN_OUT)
