extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$play/Label.hide()
	$play2.disabled = true
	$salillmenu/deadwife.hide()
	$salillmenu/TextureRect.show()
	if Global.storyDone:
		$salillmenu/deadwife.show()
		$salillmenu/TextureRect.hide()
		$salillmenu/Label.text = "Salil says:
My wife is dead"
		$play2.disabled = false
	if Global.quitted:
		$quit.disabled = true
	$NO.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:	
	get_tree().change_scene_to_file("res://Scenes/Cutscenes/Intro.tscn")
	Global.paused = false
	Global.isEndless = false

func _on_kys_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/FUNNYY.tscn")


func _on_quit_pressed() -> void:
	Global.quitted = true
	$NO.show()
	$loudbUZZER.play()
	$quit.disabled = true
	await get_tree().create_timer(1.0).timeout
	$NO.hide()


func _on_play_mouse_entered() -> void:
	$hober.play()
	$play/Label.show()
	print("baaaaaaaaaaaaaAAAAAAAAAAAAAAAA")


func _on_kys_mouse_entered() -> void:
	$hober.play()
	print("baaaaaaaaaaaaaAAAAAAAAAAAAAAAA")


func _on_quit_mouse_entered() -> void:
	if $quit.disabled == false : 
		$hober.play()
		print("baaaaaaaaaaaaaAAAAAAAAAAAAAAAA")


func _on_play_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	Global.isEndless = true


func _on_play_2_mouse_entered() -> void:
	if Global.storyDone:
		$hober.play()


func _on_play_mouse_exited() -> void:
	$play/Label.hide()


func _on_mainambience_finished() -> void:
	$mainambience.play()
