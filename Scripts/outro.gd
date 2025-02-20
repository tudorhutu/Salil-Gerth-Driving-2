extends Node2D

var wife_dead_player: AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("outro")
	$wife_dead_player.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
