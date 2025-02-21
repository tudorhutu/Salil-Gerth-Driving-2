extends Control

@export var bar_margin: int = 20
@export var bar_height: float = 10.0
@export var min_value: float = 0.0
@export var max_value: float = 1000.0

var current_progress: float = 0.0

func _draw() -> void:
	var screen_size = get_viewport_rect().size
	var y = screen_size.y - bar_margin
	var start_point = Vector2(bar_margin, y)
	var end_point = Vector2(screen_size.x - bar_margin, y)
	draw_line(start_point, end_point, Color(0.3, 0.3, 0.3), bar_height)
	var filled_end_x = lerp(start_point.x, end_point.x, current_progress)
	var filled_end_point = Vector2(filled_end_x, y)
	draw_line(start_point, filled_end_point, Color.GREEN, bar_height)

func _process(delta: float) -> void:
	if Global.paused or Global.borasc:
		return
	current_progress = (Global.distance - min_value) / (max_value - min_value)
	current_progress = clamp(current_progress, 0.0, 1.0)
	# Check if the progress is full (i.e., 100%)
	if current_progress >= 1.0:
		get_tree().change_scene_to_file("res://Scenes/Cutscenes/Outro.tscn")
	
	queue_redraw()
