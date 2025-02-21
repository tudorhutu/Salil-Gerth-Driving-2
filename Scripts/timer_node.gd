extends Control

@onready var timer_label: Label = $TimerLabel
@onready var timer: Timer = $Timer

func _ready():
	# Start the timer if not set to autostart
	if not timer.autostart:
		timer.start()

func _process(delta):
	# Update label with formatted time
	var time_left = timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
