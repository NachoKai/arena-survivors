extends Node

func _ready() -> void:
	GameEvents.player_damaged.connect(on_player_health_changed)
	GameEvents.health_vial_collected.connect(on_player_health_changed)
	GameEvents.experience_vial_collected.connect(on_player_experience_changed)
	GameEvents.character_selected.connect(on_selected_character_changed)

func get_player_health(health: float) -> float:
	if is_equal_approx(health, 0.0):
		return 100.0
	if SaveManager.save_data.has("player_health"):
		return SaveManager.save_data.player_health
	return 100.0

func get_player_level() -> int:
	if SaveManager.save_data.has("player_level"):
		return SaveManager.save_data.player_level
	return 1

func get_player_experience() -> float:
	if SaveManager.save_data.has("player_experience"):
		return SaveManager.save_data.player_experience
	return 0.0

func get_selected_character() -> String:
	if SaveManager.save_data.has("selected_character"):
		return SaveManager.save_data.selected_character
	return "warrior"

func on_player_health_changed(health: float) -> void:
	if is_equal_approx(health, 0.0):
		return
	SaveManager.save_data.player_health = health

func on_player_level_changed(level: int) -> void:
	if level == 0:
		return
	SaveManager.save_data.player_level = level

func on_player_experience_changed(experience: float) -> void:
	if is_equal_approx(experience, 0.0):
		return
	SaveManager.save_data.player_experience = experience

func on_selected_character_changed(character: String) -> void:
	if character.is_empty():
		return
	SaveManager.save_data.selected_character = character
	await get_tree().process_frame
	SaveManager.save_game()
