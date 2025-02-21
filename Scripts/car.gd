extends Node2D

@export var acceleration_rate: float = 300.0
@export var deceleration_rate: float = 300.0
@export var vertical_frictiona: float = 80.0
@export var vertical_frictiond: float = 60.0
@export var max_speed: float = 70.0
@export var min_speed: float = 10.0
var speed: float = 0.0

@export var lateral_acceleration: float = 2000.0
@export var lateral_friction: float = 1500.0
var lateral_velocity: float = 0.0
var lateral_offset: float = 0.0

@export var max_tilt_angle: float = deg_to_rad(10.0)
@export var max_wobble_angle: float = deg_to_rad(5.0)
@export var wobble_frequency: float = 5.0

@export var sway_amplitude: float = 7.0
@export var sway_frequency: float = 1.0

@export var bottom_bound: float = 900.0
var time_passed: float = 0.0

var is_in_dirt: bool = false
var base_max_speed: float = 60.0

var is_borasc: bool = false
var collision_area: Area2D

# Sway effect variables
var original_sway_frequency: float = 1.0
var original_sway_amplitude: float = 10.0
var hit_effect_timer: Timer

# NEW: Adjustable duration for the 360° hit rotation (in seconds)
@export var hit_rotation_duration: float = 1.0

func _ready() -> void:
	$MainCar.play("idle")
	var viewport_size = get_viewport_rect().size
	position.x = viewport_size.x / 2
	speed = (min_speed + max_speed) / 2
	Global.player_speed = speed
	_update_vertical_position(0)
	
	original_sway_frequency = sway_frequency
	original_sway_amplitude = sway_amplitude
	
	hit_effect_timer = Timer.new()
	hit_effect_timer.one_shot = true
	add_child(hit_effect_timer)
	hit_effect_timer.timeout.connect(_reset_sway_effects)
	
	# Collision setup
	collision_area = Area2D.new()
	collision_area.collision_layer = 16
	collision_area.collision_mask = 2
	add_child(collision_area)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20, 35)
	collision.shape = shape
	collision_area.add_child(collision)
	
	collision_area.connect("area_entered", Callable(self, "_on_area_entered"))
	SignalBus.connect("BORASC", Callable(self, "on_borasc"))

func _process(delta: float) -> void:
	if Global.paused:
		return
	if is_borasc:
		$cargopants.stop()
		$MainCar/PointLight2D.show()
		$MainCar/PointLight2D2.show()
		$MainCar.play("idle")
		return
	if is_in_dirt:
		max_speed = 10
	else:
		max_speed = base_max_speed
		
	time_passed += delta
	
	# Speed management
	if speed < min_speed:
		$MainCar.speed_scale = 19
		speed += vertical_frictiona * delta * 0.009
	else:
		$MainCar.speed_scale = 9
		if Input.is_action_pressed("ui_up") and not is_in_dirt:
			speed += acceleration_rate * delta
		else:
			if speed > min_speed:
				speed = max(speed - vertical_frictiond * delta, min_speed)
				
	speed = clamp(speed, 0, max_speed)
	Global.player_speed = speed
	
	# Lateral movement
	if Input.is_action_pressed("ui_left"):
		lateral_velocity -= lateral_acceleration * delta
	elif Input.is_action_pressed("ui_right"):
		lateral_velocity += lateral_acceleration * delta
	else:
		if lateral_velocity > 0:
			lateral_velocity = max(lateral_velocity - lateral_friction * delta, 0)
		elif lateral_velocity < 0:
			lateral_velocity = min(lateral_velocity + lateral_friction * delta, 0)
			
	lateral_offset += lateral_velocity * delta
	var max_offset = get_viewport_rect().size.x / 2
	lateral_offset = clamp(lateral_offset, -max_offset, max_offset)
	
	_update_vertical_position(delta)
	
	var center_x = get_viewport_rect().size.x / 2
	var speed_factor = (speed - min_speed) / (max_speed - min_speed)
	var dynamic_sway = 0.0
	if not is_in_dirt:
		dynamic_sway = sway_amplitude * (1 + speed_factor * 10) * sin(time_passed * TAU * sway_frequency)
		
	position.x = center_x + lateral_offset + dynamic_sway
	
	# Rotation effects
	var tilt_ratio = clamp(lateral_velocity / lateral_acceleration, -1, 1)
	var base_rotation = tilt_ratio * max_tilt_angle
	var dynamic_wobble = speed_factor * max_wobble_angle * sin(time_passed * TAU * wobble_frequency)
	rotation = base_rotation + dynamic_wobble

func _update_vertical_position(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var top_position = viewport_size.y / 2 + viewport_size.y / 5
	var bottom_position = bottom_bound
	if is_in_dirt:
		var target_y = bottom_bound - 50
		position.y = lerp(position.y, target_y, 5.0 * delta)
	else:
		var t = (speed - min_speed) / (max_speed - min_speed)
		var target_y = lerp(top_position, bottom_position, t)
		position.y = lerp(position.y, target_y, 5.0 * delta)

func _on_area_entered(area: Area2D) -> void:
	_on_obstacle_hit(area)

func _on_obstacle_hit(area: Area2D) -> void:
	# If the collided obstacle is flagged as a powerup, ignore hit effects.
	if area.get_parent() and area.get_parent().has_meta("is_powerup") and area.get_parent().get_meta("is_powerup"):
		return
	if is_in_dirt:
		return
	
	if not is_borasc:
		$MainCar/PointLight2D.hide()
		$MainCar/PointLight2D2.hide()
		$MainCar.play("OWIE")
		$cargopants.play()

	# Apply other hit effects after the animation finishes.
	speed = min_speed * 0.5
	Global.player_speed = speed
	lateral_velocity = 0
	time_passed = 0
	
	# Increase sway effects as visual feedback.
	sway_frequency = 3.0
	sway_amplitude = 800.0
	hit_effect_timer.start(1.0)

	

func _reset_sway_effects() -> void:
	sway_frequency = original_sway_frequency
	sway_amplitude = original_sway_amplitude

func _on_dirt_area_entered(area: Area2D) -> void:
	speed = min_speed * 0.5
	Global.player_speed = speed
	is_in_dirt = true

func _on_dirt_area_exited(area: Area2D) -> void:
	is_in_dirt = false

func on_borasc() -> void:
	is_borasc = true
	collision_area.monitoring = false
	speed = 0
	lateral_velocity = 0
	lateral_offset = 0
	Global.player_speed = 0
	var viewport_size = get_viewport_rect().size
	position.x = viewport_size.x - 50
	await get_tree().create_timer(2.0).timeout
	position.x = viewport_size.x / 2
	speed = (min_speed + max_speed) / 2
	Global.player_speed = speed
	collision_area.monitoring = true
	is_borasc = false
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _on_main_car_animation_finished() -> void:
	$MainCar/PointLight2D.show()
	$MainCar/PointLight2D2.show()
	$MainCar.play("idle") # Replace with function body.
