extends Node

signal experience_vial_collected(amount: float)
signal health_vial_collected(amount: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged(current_health: float)
signal character_selected(character: String)
signal damage_number_requested(position: Vector2, amount: int)

@export var game_version: String = "3.5.0"


func emit_experience_vial_collected(amount: float) -> void:
	experience_vial_collected.emit(amount)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged(current_health: float) -> void:
	player_damaged.emit(current_health)


func emit_health_vial_collected(amount: float) -> void:
	health_vial_collected.emit(amount)


func emit_character_selected(character: String) -> void:
	character_selected.emit(character)


func emit_damage_number(position: Vector2, amount: int) -> void:
	damage_number_requested.emit(position, amount)
