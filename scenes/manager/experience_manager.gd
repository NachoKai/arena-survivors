class_name ExperienceManager
extends Node

signal experience_updated(current_experience: float, target_experience: float, current_level: float)
signal level_up(new_level: int)

const EXPERIENCE_GROWTH_FACTOR: int = 5
var current_experience: float = 0
var current_level: float = 1
var target_experience: float = 5


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)


func increment_experience(number: float):
	current_experience += number

	if current_experience >= target_experience:
		current_level += 1
		current_experience -= target_experience
		target_experience += EXPERIENCE_GROWTH_FACTOR
		experience_updated.emit(current_experience, target_experience, current_level)
		level_up.emit(current_level)

	experience_updated.emit(min(current_experience, target_experience), target_experience, current_level)

func on_experience_vial_collected(number: float):
	increment_experience(number)
