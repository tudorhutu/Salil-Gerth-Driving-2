extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("outro")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_down"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_timer_timeout() -> void:
	Global.storyDone = true
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
