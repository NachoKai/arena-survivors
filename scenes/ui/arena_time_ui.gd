extends CanvasLayer

@export var arena_time_manager: Node
@onready var label = %Label


func _process(_delta):
	if arena_time_manager == null: return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)
	

func format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = floor(seconds - (minutes * 60))
	return ("%02d" % minutes) + ":" + ("%02d" % remaining_seconds) # %02d adds a leading zero, so 0:0 becomes 00:00
