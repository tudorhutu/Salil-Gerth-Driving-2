extends Control

@onready var timer_label: Label = $TimerLabel
@onready var timer: Timer = $Timer

func _ready():
	# Connect to the BORASC signal from SignalBus.
	SignalBus.connect("BORASC", Callable(self, "on_borasc"))
	
	# Start the timer if not set to autostart.
	if not timer.autostart:
		timer.start()

func _process(delta):
	# Update label with formatted time.
	# Note: timer.time_left is read-only and reflects the current countdown.
	var time_left = timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func on_borasc():
	# When BORASC is triggered, decrease the timer's remaining time by 20 seconds.
	var current_time_left = timer.time_left
	var new_time_left = max(current_time_left - 20, 0)
	
	# Stop and update the timer with the new remaining time.
	timer.stop()
	timer.wait_time = new_time_left
	timer.start()
