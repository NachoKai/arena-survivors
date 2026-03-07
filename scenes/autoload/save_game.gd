extends Node

# On desktop platforms the directory paths for user:// are:
# Windows: %APPDATA%\Godot\app_userdata\[project_name]
# macOS: ~/Library/Application Support/Godot/app_userdata/[project_name]
# To see the folder: Project -> Open User Data Folder
const SAVE_FILE_PATH: String = "user://game_stats.save"

var save_data: Dictionary = {
	"selected_character": "warrior",
	"player_health": 0,
	"player_level": 1,
	"player_experience": 0
}


func _ready() -> void:
	GameEvents.player_damaged.connect(on_player_health_changed)
	GameEvents.health_vial_collected.connect(on_player_health_changed)
	GameEvents.experience_vial_collected.connect(on_player_experience_changed)
	GameEvents.character_selected.connect(on_selected_character_changed)
	load_file()


func load_file() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()


func save_file() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)


func get_player_health(health: float) -> float:
	if is_equal_approx(health, 0.0):
		return 100.0
	if save_data.player_health:
		return save_data.player_health


func get_player_level() -> int:
	if save_data.player_level:
		return save_data.player_level
	return 1


func get_player_experience() -> float:
	if save_data.player_experience:
		return save_data.player_experience
	return 0.0


func get_selected_character() -> String:
	if save_data.selected_character:
		return save_data.selected_character
	return "warrior"


func on_player_health_changed(health: float) -> void:
	if is_equal_approx(health, 0.0):
		return
	save_data.player_health = health


func on_player_level_changed(level: int) -> void:
	if level == 0:
		return
	save_data.player_level = level


func on_player_experience_changed(experience: float) -> void:
	if is_equal_approx(experience, 0.0):
		return
	save_data.player_experience = experience


func on_selected_character_changed(character: String) -> void:
	if character.is_empty():
		return
	save_data.selected_character = character
	await get_tree().process_frame
	save_file()
