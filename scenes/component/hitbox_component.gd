class_name HitboxComponent
extends Area2D

signal hit_applied(hurtbox: HurtboxComponent, damage: float)

@export var damage: float = 0.0
@export var knockback_force: float = 0.0

var owner_node: Node


func _ready() -> void:
	owner_node = get_parent()
