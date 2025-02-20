extends Node2D

@export var left_spawn_interval: float = 1.0
@export var right_spawn_interval: float = 2.0

# Minimum intervals when distance is high (i.e. spawn rate is faster)
@export var min_left_spawn_interval: float = 0.5
@export var min_right_spawn_interval: float = 1.0

# The distance at which the spawn intervals reach their minimum values.
@export var distance_for_max_spawn: float = 1000.0

var time_since_spawn_left: float = 0.0
var time_since_spawn_right: float = 0.0

@export var default_obstacle_texture: Texture2D = preload("res://Textures/Obstacles/DynamicObstacles/car1.png")
var obstacle_textures: Array[String] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawnAllowed: bool = true

@export var enemy_light_scene: PackedScene = preload("res://Scenes/EnemyLight.tscn")
@export var enemy_light_down_scene: PackedScene = preload("res://Scenes/EnemyLightDown.tscn")

func _ready() -> void:
	rng.randomize()
	var dir = DirAccess.open("res://Textures/Obstacles/DynamicObstacles/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				obstacle_textures.append("res://Textures/Obstacles/DynamicObstacles/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func _process(delta: float) -> void:
	# Calculate a factor (0.0 to 1.0) based on the current distance
	# When Global.distance is >= distance_for_max_spawn, factor is 1.
	var factor: float = clamp(Global.distance / distance_for_max_spawn, 0.0, 1.0)
	
	# Lerp between default (slower) intervals and minimum (faster) intervals.
	var current_left_spawn_interval = lerp(left_spawn_interval, min_left_spawn_interval, factor)
	var current_right_spawn_interval = lerp(right_spawn_interval, min_right_spawn_interval, factor)
	
	if spawnAllowed:
		time_since_spawn_left += delta
		time_since_spawn_right += delta
		
		if time_since_spawn_left >= current_left_spawn_interval:
			spawn_obstacle("left")
			time_since_spawn_left = 0.0
			
		if time_since_spawn_right >= current_right_spawn_interval:
			spawn_obstacle("right")
			time_since_spawn_right = 0.0

func spawn_obstacle(direction: String) -> void:
	var obstacle_sprite = Sprite2D.new()
	var texture_path: String = ""
	if obstacle_textures.size() > 0:
		if direction == "left":
			for t in obstacle_textures:
				if t.find("car1.png") != -1:
					texture_path = t
					break
		elif direction == "right":
			for t in obstacle_textures:
				if t.find("car2.png") != -1:
					texture_path = t
					break
		if texture_path == "":
			texture_path = default_obstacle_texture.resource_path
	else:
		texture_path = default_obstacle_texture.resource_path
	
	obstacle_sprite.texture = load(texture_path)
	obstacle_sprite.centered = true
	obstacle_sprite.set_script(load("res://Scripts/DynamicObstacle.gd"))
	
	var viewport_size = get_viewport_rect().size
	var spawn_y: float = 0.0
	if direction == "left":
		obstacle_sprite.movement_direction = Vector2.DOWN
		spawn_y = -700
	else:
		obstacle_sprite.movement_direction = Vector2.UP
		spawn_y = viewport_size.y + 700
	
	var light
	if obstacle_sprite.movement_direction == Vector2.DOWN:
		light = enemy_light_down_scene.instantiate()
	else:
		light = enemy_light_scene.instantiate()
	obstacle_sprite.add_child(light)
	
	var area = Area2D.new()
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = 2
	area.collision_mask = 16
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	if obstacle_sprite.texture:
		rect_shape.extents = obstacle_sprite.texture.get_size() * 0.5
	collision.shape = rect_shape
	collision.position = Vector2.ZERO
	area.add_child(collision)
	area.connect("area_entered", Callable(obstacle_sprite, "_on_area_entered_obstacle"))
	obstacle_sprite.add_child(area)
	
	var x_pos: float = 0.0
	if direction == "left":
		x_pos = rng.randi_range(400, 900)
	else:
		x_pos = rng.randi_range(950, 1600)
	
	obstacle_sprite.position = Vector2(x_pos, spawn_y)
	add_child(obstacle_sprite)
