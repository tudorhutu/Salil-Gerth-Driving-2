extends Control

func _ready() -> void:
	$AnimatedSprite2D.play("INSTR")

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
