extends Sprite2D

@export var speed_multiplier: float = 100.0
var is_borasc_active: bool = false

func _ready() -> void:
	SignalBus.connect("BORASC", Callable(self, "_on_borasc"))

func _on_area_entered_obstacle(other_area: Area2D) -> void:
	if get_meta("is_powerup", false):
		SignalBus.emit_signal("powerup_hit", other_area)
	else:
		SignalBus.emit_signal("obstacle_hit", other_area)
	queue_free()

func _process(delta: float) -> void:
	if not is_borasc_active:
		position.y += Global.player_speed * speed_multiplier * delta
	else:
		queue_free()
	
	if texture and position.y > get_viewport_rect().size.y + texture.get_height():
		queue_free()

func _on_borasc() -> void:
	if is_borasc_active:
		queue_free()
		return
	is_borasc_active = true
	await get_tree().create_timer(2.0).timeout
	is_borasc_active = false
