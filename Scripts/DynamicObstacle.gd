extends Sprite2D

@export var movement_direction: Vector2 = Vector2.DOWN
@export var speed: float = 400.0

func _ready() -> void:
	if movement_direction == Vector2.DOWN:
		rotation_degrees = 0

func _on_area_entered_obstacle(other_area: Area2D) -> void:
	SignalBus.emit_signal("obstacle_hit", other_area)
	queue_free()

func _process(delta: float) -> void:
	if Global.paused:
		return
	var effective_speed = speed 
	if movement_direction == Vector2.DOWN:
		effective_speed = speed + 60 + Global.player_speed * 75
	elif movement_direction == Vector2.UP:
		effective_speed = speed - 60 - Global.player_speed * 5
	position += movement_direction.normalized() * effective_speed * delta * 2
	
	var viewport_size = get_viewport_rect().size
	if texture:
		if movement_direction == Vector2.DOWN:
			if position.y > viewport_size.y + 700 or position.x < -texture.get_width() or position.x > viewport_size.x + texture.get_width():
				queue_free()
		elif movement_direction == Vector2.UP:
			if position.y < -700 or position.x < -texture.get_width() or position.x > viewport_size.x + texture.get_width():
				queue_free()
