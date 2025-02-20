extends Node2D

@export var spawn_interval: float = 1.5
@export var powerup_spawn_interval: float = 1.0  # Separate interval for powerup spawns
@export var obstacle_texture: Texture2D = preload("res://Textures/Obstacles/cone.png")
var obstacle_textures: Array[String] = []

var time_since_spawn: float = 0.0
var time_since_powerup_spawn: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawnAllowed: bool = true
var is_borasc_active: bool = false
var _borasc_timer: Timer

@export var cone_occluder_polygon: OccluderPolygon2D = preload("res://Textures/Obstacles/lightblockers/cone_occluder.tres")

func _ready() -> void:
	_borasc_timer = Timer.new()
	_borasc_timer.one_shot = true
	add_child(_borasc_timer)
	
	if SignalBus.has_signal("BORASC"):
		SignalBus.connect("BORASC", Callable(self, "_on_borasc"))
	else:
		push_error("BORASC signal missing in SignalBus!")
	
	rng.randomize()
	var dir = DirAccess.open("res://Textures/Obstacles/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				obstacle_textures.append("res://Textures/Obstacles/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func _process(delta: float) -> void:
	time_since_spawn += delta
	time_since_powerup_spawn += delta
	
	# Spawn normal obstacle at its own interval.
	if time_since_spawn >= spawn_interval:
		time_since_spawn = 0.0
		if spawnAllowed and not is_borasc_active:
			spawn_obstacle()
	
	# Spawn powerup at its own interval.
	if time_since_powerup_spawn >= powerup_spawn_interval:
		time_since_powerup_spawn = 0.0
		if spawnAllowed and not is_borasc_active:
			spawn_powerup()

func spawn_obstacle() -> void:
	# Determine the x coordinate for the obstacle spawn.
	# Using the average of two random numbers biases the spawn location toward the center.
	var t = (rng.randf() + rng.randf()) / 2.0
	var x_pos = lerp(400, 1600, t)
	
	# Choose a texture from the list, excluding powerup.png.
	var chosen_texture: Texture2D
	var available_textures: Array[String] = []
	for file in obstacle_textures:
		if file.find("powerup.png") == -1:
			available_textures.append(file)
	if available_textures.size() > 0:
		var index = rng.randi_range(0, available_textures.size() - 1)
		chosen_texture = load(available_textures[index])
	else:
		chosen_texture = obstacle_texture
	
	# Create warning sprite using the regular warning texture.
	var warning_sprite = Sprite2D.new()
	warning_sprite.texture = load("res://Textures/warning.png")
	warning_sprite.centered = true
	warning_sprite.position = Vector2(x_pos, 200)
	add_child(warning_sprite)
	
	await get_tree().create_timer(2.0).timeout
	warning_sprite.queue_free()
	
	# Check if BORASC is active before spawning the obstacle
	if is_borasc_active:
		return
	
	# Create the obstacle sprite.
	var obstacle_sprite = Sprite2D.new()
	obstacle_sprite.texture = chosen_texture
	obstacle_sprite.flip_h = rng.randf() < 0.5
	obstacle_sprite.centered = true
	obstacle_sprite.set_script(load("res://Scripts/Obstacle.gd"))
	
	# Tag the obstacle as non-powerup.
	obstacle_sprite.set_meta("is_powerup", false)
	
	# Optionally add a light occluder if texture is a cone.
	if chosen_texture and chosen_texture.resource_path.find("cone.png") != -1:
		var light_occluder = LightOccluder2D.new()
		light_occluder.occluder = cone_occluder_polygon.duplicate()
		obstacle_sprite.add_child(light_occluder)
	
	# Setup collision detection.
	var area = Area2D.new()
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = 2
	area.collision_mask = 16
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	if chosen_texture:
		rect_shape.extents = chosen_texture.get_size() * 0.5
	collision.shape = rect_shape
	collision.position = Vector2.ZERO
	area.add_child(collision)
	area.connect("area_entered", Callable(obstacle_sprite, "_on_area_entered_obstacle"))
	obstacle_sprite.add_child(area)
	
	obstacle_sprite.position = Vector2(x_pos, 0)
	add_child(obstacle_sprite)

func spawn_powerup() -> void:
	# Determine the x coordinate for the powerup spawn.
	var x_pos = rng.randi_range(400, 1600)
	
	# For powerups, force the use of the powerup texture.
	var chosen_texture: Texture2D = load("res://Textures/Obstacles/powerup.png")
	
	# Create warning sprite with goodwarning.png.
	var warning_sprite = Sprite2D.new()
	warning_sprite.texture = load("res://Textures/goodwarning.png")
	warning_sprite.centered = true
	warning_sprite.position = Vector2(x_pos, 200)
	add_child(warning_sprite)
	
	await get_tree().create_timer(2.0).timeout
	warning_sprite.queue_free()
	
	# Check if BORASC is active before spawning the powerup
	if is_borasc_active:
		return
	
	# Create the powerup obstacle sprite.
	var obstacle_sprite = Sprite2D.new()
	obstacle_sprite.texture = chosen_texture
	obstacle_sprite.flip_h = rng.randf() < 0.5
	obstacle_sprite.centered = true
	obstacle_sprite.set_script(load("res://Scripts/Obstacle.gd"))
	
	# Tag as powerup.
	obstacle_sprite.set_meta("is_powerup", true)
	
	# Optionally add a light occluder if texture is a cone.
	if chosen_texture and chosen_texture.resource_path.find("cone.png") != -1:
		var light_occluder = LightOccluder2D.new()
		light_occluder.occluder = cone_occluder_polygon.duplicate()
		obstacle_sprite.add_child(light_occluder)
	
	# Setup collision detection.
	var area = Area2D.new()
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = 2
	area.collision_mask = 16
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	if chosen_texture:
		rect_shape.extents = chosen_texture.get_size() * 0.5
	collision.shape = rect_shape
	collision.position = Vector2.ZERO
	area.add_child(collision)
	area.connect("area_entered", Callable(obstacle_sprite, "_on_area_entered_obstacle"))
	obstacle_sprite.add_child(area)
	
	obstacle_sprite.position = Vector2(x_pos, 0)
	add_child(obstacle_sprite)

func _on_borasc() -> void:
	if is_borasc_active:
		return
	is_borasc_active = true
	_borasc_timer.start(5.0)
	await _borasc_timer.timeout
	is_borasc_active = false

func _exit_tree() -> void:
	if _borasc_timer:
		_borasc_timer.stop()
