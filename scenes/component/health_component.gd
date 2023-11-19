class_name HealthComponent
extends Node

signal died
signal health_changed(current_health: float)
signal health_decreased

@export var max_health: float = 100
var current_health


func _ready():
	current_health = max_health
	GameEvents.health_vial_collected.connect(on_health_vial_collected)


func damage(damage_amount: float = 0):
	var is_healing = false
	if damage_amount < 0:
		is_healing = true

	current_health = clamp(current_health - damage_amount, 0, max_health)
	health_changed.emit(current_health, is_healing)
	if damage_amount > 0:
		health_decreased.emit(current_health)
	check_death.call_deferred()


func heal(heal_amount: int):
	damage(-heal_amount)


func get_health_percent():
	if max_health <= 0: return 0
	return min(current_health / max_health, 1)


func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()


func on_health_vial_collected(number: int):
	heal(number)
