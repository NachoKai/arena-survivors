class_name HurtboxComponent
extends Area2D

signal hit(hitbox: HitboxComponent, damage: float)

@export var health_component: HealthComponent


func _ready() -> void:
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D) -> void:
	if not (other_area is HitboxComponent):
		return
	if not health_component:
		return
	var hitbox_component := other_area as HitboxComponent
	var damage: float = hitbox_component.damage
	health_component.damage(damage)
	var text_position := global_position + (Vector2.UP * 8.0)
	GameEvents.emit_damage_number(text_position, int(round(damage)))
	hit.emit(hitbox_component, damage)
