extends CanvasLayer

@export var experience_manager: ExperienceManager
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var level_label = %LevelLabel


func _ready():
	progress_bar.value = 0
	experience_manager.experience_updated.connect(on_experience_updated)


func on_experience_updated(current_experience: float, target_experience: float, current_level: float):
	if target_experience == 0: return
	var percent = current_experience / target_experience
	progress_bar.value = percent
	var level = str(current_level)
	level_label.text = "Level: " + level
