extends Node2D

var colors = [
	Color(1.0, 0.0, 0.0), # Red
	Color(0.0, 1.0, 0.0), # Green
	Color(0.0, 0.0, 1.0), # Blue
	Color(1.0, 1.0, 0.0), # Yellow
	Color(1.0, 0.0, 1.0), # Magenta
	Color(0.0, 1.0, 1.0)  # Cyan
]

@export var flash_speed: float = 0.5 # Time between color changes
@export var pulse_speed: float = 10.0 # Speed of the pulsating effect
@export var min_intensity: float = 2.0 # Minimum light energy
@export var max_intensity: float = 4.0 # Maximum light energy

var time_passed: float = 0.0
var lights: Array = []

func _ready() -> void:
	$AnimationPlayer.play("intro")
	randomize()

	# Wait for the scene tree to be fully ready
	await get_tree().process_frame
	
	# Collect lights dynamically
	lights = [
		$HouseRoot/House/CanvasLayer/partylight,
		$HouseRoot/House/CanvasLayer/partylight2,
		$HouseRoot/House/CanvasLayer/partylight3
	]
	
	flash_lights()

func flash_lights():
	while true:
		for light in lights:
			if is_instance_valid(light):
				# Assign a random color to each light
				light.color = colors[randi() % colors.size()]
		await get_tree().create_timer(flash_speed).timeout

func _process(delta: float) -> void:
	time_passed += delta * pulse_speed
	
	# Apply pulsating effect to each light
	for light in lights:
		if is_instance_valid(light):
			var pulsate_intensity = min_intensity + (sin(time_passed + light.get_index()) * 0.5 + 0.5) * (max_intensity - min_intensity)
			light.energy = pulsate_intensity
