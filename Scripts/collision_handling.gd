extends Node2D

func _ready() -> void:
	SignalBus.connect("obstacle_hit", Callable(self, "_on_obstacle_hit"))

func _on_obstacle_hit(area: Area2D) -> void:
	pass


func _on_dirt_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
