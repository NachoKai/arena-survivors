class_name ArenaTimeManager
extends Node

signal arena_difficulty_increased(arena_difficulty: int)

@onready var timer: Timer = $Timer
@export var end_screen_scene: PackedScene

const DIFFICULTY_INTERVAL: int = 5
var arena_difficulty: int = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)


func _process(_delta):
	if not timer: return
	var next_time_target = timer.wait_time - ((arena_difficulty + 1) * DIFFICULTY_INTERVAL)
	if timer.time_left <= next_time_target:
		arena_difficulty += 1
		arena_difficulty_increased.emit(arena_difficulty)


func get_time_elapsed():
	if not timer: return
	return timer.wait_time - timer.time_left


func on_timer_timeout():
	var isDefeat = false
	var end_screen_instance = end_screen_scene.instantiate()
	if not end_screen_instance: return
	add_child(end_screen_instance)
	end_screen_instance.play_jingle(isDefeat)
	MetaProgression.save_file()
