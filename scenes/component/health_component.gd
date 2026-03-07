class_name HealthComponent
extends Node

signal died
signal health_changed(current_health: float, is_healing: bool)
signal health_decreased(current_health: float)

@export var max_health: float = 100.0
@export var destroy_on_death: bool = true
var current_health: float = 0.0
@onready var potion_splash_player: AudioStreamPlayer = $PotionSplashPlayer


func _ready() -> void:
	current_health = max_health
	GameEvents.health_vial_collected.connect(on_health_vial_collected)


func damage(damage_amount: float = 0.0) -> void:
	var is_healing := false
	if damage_amount < 0:
		is_healing = true
		if potion_splash_player:
			potion_splash_player.play_random()

	current_health = clamp(current_health - damage_amount, 0, max_health)
	health_changed.emit(current_health, is_healing)
	if damage_amount > 0:
		health_decreased.emit(current_health)
	check_death.call_deferred()


func heal(heal_amount: int) -> void:
	damage(-heal_amount)


func get_health_percent() -> float:
	if max_health <= 0.0:
		return 0.0
	return min(current_health / max_health, 1)


func check_death() -> void:
	if is_equal_approx(current_health, 0.0):
		died.emit()
		if destroy_on_death:
			owner.queue_free()


func on_health_vial_collected(number: int) -> void:
	heal(number)
