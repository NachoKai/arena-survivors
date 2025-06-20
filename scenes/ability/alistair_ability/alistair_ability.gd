class_name AlistairAbility
extends Node2D

@onready var hitbox_component = $HitboxComponent
@onready var animation_player = $AnimationPlayer

var has_damaged_enemies = []


func _ready():
	hitbox_component.body_entered.connect(on_body_entered)
	hitbox_component.area_entered.connect(on_area_entered)

	await get_tree().create_timer(0.25).timeout
	apply_area_damage()


func on_body_entered(_other_body: Node2D):
	pass


func on_area_entered(_other_body: Node2D):
	pass


func apply_area_damage():
	var overlapping_bodies = hitbox_component.get_overlapping_bodies()
	var overlapping_areas = hitbox_component.get_overlapping_areas()

	var all_enemies = []
	for body in overlapping_bodies:
		if body.is_in_group("enemy") and not all_enemies.has(body):
			all_enemies.append(body)

	for area in overlapping_areas:
		if area.is_in_group("enemy") and not all_enemies.has(area):
			all_enemies.append(area)

	for enemy in all_enemies:
		if not has_damaged_enemies.has(enemy):
			has_damaged_enemies.append(enemy)
