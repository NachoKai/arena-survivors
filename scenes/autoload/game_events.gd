extends Node

signal experience_vial_collected(number: float)
signal health_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged(current_health: float)
signal character_selected(character: String)

@export var game_version: String = "2.3.2"


func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged(current_health):
	player_damaged.emit(current_health)


func emit_health_vial_collected(number: float):
	health_vial_collected.emit(number)


func emit_character_selected(character):
	character_selected.emit(character)
