extends Node2D

var paused: bool = false

func _ready() -> void:
	$Drums.play()
	$Slow.play()
	$Normal.play()
	process_mode = PROCESS_MODE_ALWAYS
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

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
