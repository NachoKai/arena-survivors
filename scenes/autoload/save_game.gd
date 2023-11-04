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


func _ready():
	GameEvents.player_damaged.connect(on_player_health_changed)
	GameEvents.health_vial_collected.connect(on_player_health_changed)
	GameEvents.experience_vial_collected.connect(on_player_experience_changed)
	GameEvents.character_selected.connect(on_selected_character_changed)
	load_file()


func load_file():
	if not FileAccess.file_exists(SAVE_FILE_PATH): return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()


func save_file():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)


func get_player_health(health: float):
	if not health or health == 0: return 100
	if save_data.player_health:
		return save_data.player_health


func get_player_level():
	if save_data.player_level:
		return save_data.player_level
	else: return 1


func get_player_experience():
	if save_data.player_experience:
		return save_data.player_experience
	else: return 0


func get_selected_character():
	if save_data.selected_character:
		return save_data.selected_character
	else: return "warrior"


func on_player_health_changed(health: float):
	if not health: return
	save_data.player_health = health


func on_player_level_changed(level: int):
	if not level: return
	save_data.player_level = level


func on_player_experience_changed(experience: float):
	if not experience: return
	save_data.player_experience = experience


func on_selected_character_changed(character: String):
	if not character: return
	save_data.selected_character = character
