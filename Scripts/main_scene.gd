extends Node2D

var paused: bool = false

func _ready() -> void:
	$gover.hide()
	$gover2.hide()
	$Drums.play()
	$Slow.play()
	$Normal.play()
	get_tree().paused = false
	$Slow.volume_db-=100
	$Drums.volume_db = -15

func _process(delta: float) -> void:
	var speedpercent = Global.player_speed/60.0 * 100
	$Drums.volume_db = -15 + speedpercent/10.0 
	if(Global.player_speed < 9.0):
		$Slow.volume_db = 0
		$Normal.volume_db = -100
	else:
		$Slow.volume_db = -100
		$Normal.volume_db = 0
	if Input.is_action_pressed("ui_cancel"):
		if Global.paused:
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func toggle_pause() -> void:
	paused = !paused
	get_tree().paused = paused
	print("Game Paused: ", paused)


func _on_drums_finished() -> void:
	$Drums.play() 

func _on_slow_finished() -> void:
	$Slow.play() 

func _on_normal_finished() -> void:
	$Normal.play()


func _on_timer_timeout() -> void:
	$overr.play()
	$gover.show()
	$gover2.show()
	$Drums.stop()
	$Slow.stop() 
	$Normal.stop()
	$CanvasLayer/TimerNode/Timer.stop()
	Global.paused = true
