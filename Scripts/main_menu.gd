extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:	
	#get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	get_tree().change_scene_to_file("res://Scenes/Cutscenes/Outro.tscn")

func _on_kys_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/FUNNYY.tscn")


func _on_quit_button_down() -> void:
	pass # Replace with function body.
