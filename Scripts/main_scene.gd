extends Node2D

var paused: bool = false

func _ready() -> void:
	Global.storyDone = false
	$livesLeft/DISCLAIMER.hide()
	$gover.hide()
	$gover2.hide()
	$Drums.play()
	$Slow.play()
	$Normal.play()
	get_tree().paused = false
	$Slow.volume_db-=100
	$Drums.volume_db = -15
	$EndlessScore.hide()
	$Distance.show()
	$livesLeft.hide()
	if Global.isEndless:
		Global.endlessLives = 3
		$livesLeft.show()
		$EndlessScore.show()
		$Distance.hide()
		$CanvasLayer/TimerNode.hide()
		$CanvasLayer/TimerNode/Timer.stop()
		
		

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
	if Global.isEndless:
		$EndlessScore.text = "%.02f" %Global.distance
		if Global.endlessLives == 3:
			$livesLeft.text = '3 Lives left'
		if Global.endlessLives == 2:
			$livesLeft.text = '2 Lives left'
		if Global.endlessLives == 1:
			$livesLeft.text = '1 Life left'
		if Global.endlessLives == 0:
			$livesLeft.text = 'Don \'t puke!'
		if Global.endlessLives < 0:
			Global.storyDone = true
			$gover.show()
			$gover2.show()
			$Drums.stop()
			$Slow.stop() 
			$Normal.stop()
			$CanvasLayer/TimerNode/Timer.stop()
			Global.paused = true
			$livesLeft/DISCLAIMER.show()


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
