extends Node

@onready var timer: Timer = $Timer
@onready var performance_check_timer: Timer = $PerformanceCheckTimer

var enemy_group: Array[Node] = []
var current_optimization_level: int = 0

func _ready():
	# Cache enemy group reference
	performance_check_timer.timeout.connect(check_performance)
	performance_check_timer.start()
	get_tree().get_nodes_in_group("enemy")


func check_performance():
	var fps = Engine.get_frames_per_second()
	var new_level = 0

	if fps < 40:
		new_level = 4  # Extreme optimization
	elif fps < 55:
		new_level = 3  # Heavy optimization
	elif fps < 70:
		new_level = 2  # Medium optimization
	elif fps < 85:
		new_level = 1  # Light optimization

	if new_level != current_optimization_level:
		apply_optimization_level(new_level)


func apply_optimization_level(level: int):
	current_optimization_level = level
	match level:
		4:  # Extreme optimization
			disable_stuff(40)  # Disable 40% of enemies
			get_tree().call_group("visual_effects", "set_enabled", false)
			get_tree().call_group("enemy", "set_physics_process_mode", Node.PROCESS_MODE_DISABLED)
		3:  # Heavy optimization
			disable_stuff(25)  # Disable 25% of enemies
			get_tree().call_group("visual_effects", "set_enabled", false)
		2:  # Medium optimization
			disable_stuff(15)  # Disable 15% of enemies
		1:  # Light optimization
			disable_stuff(5)   # Disable 5% of enemies
		0:  # No optimization
			enable_all()


func disable_stuff(percentage: int = 20):
	if timer.is_stopped():
		get_tree().call_group("enemy", "frame_save", percentage)
		timer.start()


func enable_all():
	get_tree().call_group("enemy", "frame_save", 0)
	get_tree().call_group("visual_effects", "set_enabled", true)
	get_tree().call_group("enemy", "set_physics_process_mode", Node.PROCESS_MODE_INHERIT)
