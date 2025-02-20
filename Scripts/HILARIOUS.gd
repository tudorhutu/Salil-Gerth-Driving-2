extends Node2D

# Preload resources
var marcel_texture: Texture = preload("res://Textures/marcel.JPG")
var funny_sound: AudioStream = preload("res://Sounds/thefunny.mp3")

# Timers for spawning sprites and playing sound
var sprite_timer: Timer
var sound_timer: Timer

# Variables for flash mode
var flash_timer: Timer
var flash_time_elapsed: float = 0.0
const FLASH_DURATION: float = 5.0
var flash_sprite: Sprite2D

func _ready() -> void:
	# Create and configure sprite spawn timer
	sprite_timer = Timer.new()
	sprite_timer.one_shot = true
	sprite_timer.wait_time = randf_range(0.001, 0.01)
	sprite_timer.timeout.connect(_on_sprite_timer_timeout)
	add_child(sprite_timer)
	sprite_timer.start()
	
	# Create and configure sound spawn timer with nearly immediate intervals
	sound_timer = Timer.new()
	sound_timer.one_shot = true
	sound_timer.wait_time = randf_range(0.001, 0.01)
	sound_timer.timeout.connect(_on_sound_timer_timeout)
	add_child(sound_timer)
	sound_timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_on_escape_pressed()

func _on_escape_pressed() -> void:
	# Clean up all current child nodes
	for child in get_children():
		child.queue_free()
	
	# Set up full-screen flash using marcel_texture
	flash_sprite = Sprite2D.new()
	flash_sprite.texture = marcel_texture
	var viewport_size: Vector2 = get_viewport_rect().size
	var tex_size: Vector2 = marcel_texture.get_size()
	# Scale the texture to fill the screen
	flash_sprite.scale = Vector2(viewport_size.x / tex_size.x, viewport_size.y / tex_size.y)
	flash_sprite.position = viewport_size * 0.5
	add_child(flash_sprite)
	
	# Create a timer to toggle flash visibility rapidly
	flash_timer = Timer.new()
	flash_timer.wait_time = 0.05
	flash_timer.one_shot = false
	flash_timer.timeout.connect(_on_flash_timer_timeout)
	add_child(flash_timer)
	flash_timer.start()

func _on_flash_timer_timeout() -> void:
	flash_time_elapsed += flash_timer.wait_time
	flash_sprite.visible = not flash_sprite.visible  # toggle flash visibility
	if flash_time_elapsed >= FLASH_DURATION:
		get_tree().quit()

func _on_sprite_timer_timeout() -> void:
	_spawn_marcel_sprite()
	# Restart timer with a new random interval for sprite spawning
	sprite_timer.wait_time = randf_range(0.001, 0.01)
	sprite_timer.start()

func _spawn_marcel_sprite() -> void:
	# Use Sprite2D in Godot 4
	var sprite = Sprite2D.new()
	sprite.texture = marcel_texture
	
	# Determine screen bounds
	var screen_rect: Rect2 = get_viewport_rect()
	# Choose a random position within the screen
	sprite.position = Vector2(
		randf_range(0, screen_rect.size.x),
		randf_range(0, screen_rect.size.y)
	)
	
	# Set random rotation and scale
	sprite.rotation = randf_range(0, TAU)
	var random_scale: float = randf_range(0.01, 0.2)
	sprite.scale = Vector2(random_scale, random_scale)
	
	# Add the sprite so it persists
	add_child(sprite)

func _on_sound_timer_timeout() -> void:
	_play_funny_sound()
	# Restart timer with a new random interval for sound playback
	sound_timer.wait_time = randf_range(0.001, 0.01)
	sound_timer.start()

func _play_funny_sound() -> void:
	# Create an AudioStreamPlayer for overlapping sounds
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = funny_sound
	# Lower the volume (in decibels) to limit overall loudness
	audio_player.volume_db = -25.0
	add_child(audio_player)
	audio_player.play()
	
	# Create a cleanup timer to free the AudioStreamPlayer after playback
	var cleanup_timer = Timer.new()
	cleanup_timer.one_shot = true
	cleanup_timer.wait_time = funny_sound.get_length() if funny_sound.has_method("get_length") else 1.0
	# Connect the timeout signal using a lambda to pass extra arguments
	cleanup_timer.timeout.connect(func() -> void:
		_on_cleanup_audio(audio_player, cleanup_timer)
	)
	add_child(cleanup_timer)
	cleanup_timer.start()

func _on_cleanup_audio(audio_player: AudioStreamPlayer, cleanup_timer: Timer) -> void:
	if is_instance_valid(audio_player):
		audio_player.queue_free()
	cleanup_timer.queue_free()
