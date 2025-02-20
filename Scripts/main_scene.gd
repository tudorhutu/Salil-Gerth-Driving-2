extends Node2D

var paused := false
var drums_player: AudioStreamPlayer
var harmony_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = false


	drums_player = AudioStreamPlayer.new()
	harmony_player = AudioStreamPlayer.new()
	

	drums_player.stream = preload("res://Sounds/drumss.wav")
	harmony_player.stream = preload("res://Sounds/drumss.wav")
	

	drums_player.volume_db = calculate_drums_volume()
	harmony_player.volume_db = -25.0  
	drums_player.finished.connect(_on_drums_finished)
	harmony_player.finished.connect(_on_harmony_finished)
	

	add_child(drums_player)
	add_child(harmony_player)
	
	drums_player.play()
	harmony_player.play()

func _on_drums_finished() -> void:
	drums_player.play()

func _on_harmony_finished() -> void:
	harmony_player.play()

func _process(delta: float) -> void:
	drums_player.volume_db = calculate_drums_volume()

func calculate_drums_volume() -> float:
	var min_speed = 10.0
	var max_speed = 70.0
	var min_volume = -35.0
	var max_volume = -5.0 
	var speed = clamp(Global.player_speed, min_speed, max_speed)
	return lerp(min_volume, max_volume, (speed - min_speed) / (max_speed - min_speed))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	paused = !paused
	get_tree().paused = paused
	print("Game Paused: ", paused)
