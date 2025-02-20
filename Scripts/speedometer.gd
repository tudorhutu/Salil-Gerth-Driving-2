extends Control

@export var below_angle: float = deg_to_rad(20)
@export var mid_angle: float = deg_to_rad(0)
@export var max_angle: float = deg_to_rad(330)
@export var min_speed: float = 10.0
@export var max_speed: float = 70.0

func _process(delta: float) -> void:
	update_needle()

func update_needle() -> void:
	var speed = Global.player_speed
	if speed < min_speed:
		$Needle.rotation = below_angle
	elif speed == max_speed - 10.0:
		$Needle.rotation = max_angle
	else:
		$Needle.rotation = mid_angle
