extends Sprite2D

@export var movement_direction: Vector2 = Vector2.DOWN
@export var speed: float = 400.0

func _ready() -> void:
	# Set rotation if moving down
	if movement_direction == Vector2.DOWN:
		rotation_degrees = 0
	
	play_car_horn_once()

func play_car_horn_once() -> void:
	if Global.playerposition <= 950.0 and movement_direction == Vector2.DOWN:
		# Create a new AudioStreamPlayer2D node
		var audio_player = AudioStreamPlayer2D.new()
		# Load the sound from the given path and assign it
		audio_player.stream = load("res://Sounds/705723__mudflea2__double-car-horn.wav") as AudioStream
		
		# Add the audio player as a child so it becomes part of the scene
		add_child(audio_player)
		
		# Set additional properties
		audio_player.volume_db = -9
		audio_player.panning_strength = 3
		audio_player.attenuation = 5.0

		# Generate a random pitch variance between 0.95 and 1.05:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var pitch_variance = rng.randf_range(0.85, 1.15)
		audio_player.pitch_scale = pitch_variance
		
		# Play the sound once (ensure looping is off in the resource or by default)
		audio_player.play()
		
		# Free the audio node after the sound finishes playing:
		var duration: float = 2.0  # default duration
		if audio_player.stream.has_method("get_length"):
			duration = audio_player.stream.get_length()
		get_tree().create_timer(duration).connect("timeout", Callable(audio_player, "queue_free"))


func _on_area_entered_obstacle(other_area: Area2D) -> void:
	SignalBus.emit_signal("obstacle_hit", other_area)
	queue_free()

func _process(delta: float) -> void:
	if Global.paused:
		return
	
	var effective_speed = speed
	if movement_direction == Vector2.DOWN:
		effective_speed = speed + 60 + Global.player_speed * 75
	elif movement_direction == Vector2.UP:
		effective_speed = speed - 60 - Global.player_speed * 5
	
	position += movement_direction.normalized() * effective_speed * delta * 2
	
	var viewport_size = get_viewport_rect().size
	if texture:
		if movement_direction == Vector2.DOWN:
			if position.y > viewport_size.y + 700 or position.x < -texture.get_width() or position.x > viewport_size.x + texture.get_width():
				queue_free()
		elif movement_direction == Vector2.UP:
			if position.y < -700 or position.x < -texture.get_width() or position.x > viewport_size.x + texture.get_width():
				queue_free()
