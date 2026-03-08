class_name AxeAbility
extends Node2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var hitbox_component = $HitboxComponent
var base_rotation = Vector2.RIGHT
const MAX_RADIUS: int = 100


func _ready() -> void:
	pass

func on_spawn() -> void:
	base_rotation = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	var tween := create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 2.8)
	tween.tween_callback(func() -> void: ObjectPoolManager.release_object(self, "axe_ability"))

func on_despawn() -> void:
	pass


func tween_method(rotations: float) -> void:
	if not rotations: return
	var percent := rotations / 2.0
	var current_direction := base_rotation.rotated(rotations * TAU)
	var current_radius := percent * MAX_RADIUS
	if not player: return
	global_position = player.global_position + (current_direction * current_radius)

