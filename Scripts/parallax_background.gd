extends ParallaxBackground

@export var base_scroll_speed: float = 100.0
var frozen_scroll_y: float = 0.0
var is_borasc_active: bool = false

func _ready() -> void:
	SignalBus.connect("BORASC", Callable(self, "on_borasc"))

func _process(delta: float) -> void:
	Global.distance = scroll_offset.y/100
	if not is_borasc_active:
		scroll_offset.y += base_scroll_speed * Global.player_speed * delta

func on_borasc() -> void:
	if is_borasc_active:
		return
	is_borasc_active = true
	frozen_scroll_y = scroll_offset.y
	await get_tree().create_timer(2.0).timeout
	is_borasc_active = false
