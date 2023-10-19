extends CanvasLayer

@onready var label: Label = %Label
@export var arena_time_manager: ArenaTimeManager


func _process(_delta):
	if not arena_time_manager: return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	var time_elapsed_formatted = format_seconds_to_string(time_elapsed)
	label.text = time_elapsed_formatted


func format_seconds_to_string(value: int) -> String:
	var seconds = value %60
	var minutes = (value / 60)%60

	return "%02d:%02d" % [minutes, seconds]
