extends Node

const SAVE_FILE_PATH: String = "user://game_save.data"
const SAVE_PASSWORD = "arena_survivors_secret_key" # In a real game, hide this better or use OS keystore

var save_data: Dictionary = {
	"selected_character": "warrior",
	"player_health": 0,
	"player_level": 1,
	"player_experience": 0,
	"meta_upgrade_currency": 0,
	"meta_upgrades": {}
}

func _ready() -> void:
	load_game()

func save_game() -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVE_FILE_PATH, FileAccess.WRITE, SAVE_PASSWORD)
	if file:
		file.store_var(save_data)
		file.close()
	else:
		push_error("Failed to save game data.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return # Start with default save_data
		
	var file = FileAccess.open_encrypted_with_pass(SAVE_FILE_PATH, FileAccess.READ, SAVE_PASSWORD)
	if file:
		var loaded_data = file.get_var()
		file.close()
		
		if typeof(loaded_data) == TYPE_DICTIONARY:
			# Merge loaded data with default schema to preserve new keys added in updates
			for key in loaded_data.keys():
				save_data[key] = loaded_data[key]
	else:
		push_error("Failed to load game data or password mismatch.")
