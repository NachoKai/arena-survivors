extends Node

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var max_speed: float = 40.0
@export var acceleration: float = 5.0
var velocity: Vector2 = Vector2.ZERO


func accelerate_to_player() -> void:
	var owner_node2d := owner as Node2D
	if not owner_node2d:
		return
	if not player:
		return
	var direction: Vector2 = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)


func accelerate_in_direction(direction: Vector2) -> void:
	var desired_velocity: Vector2 = direction * max_speed
	velocity = velocity.lerp(desired_velocity, 1.0 - exp(-acceleration * get_process_delta_time()))


func decelerate() -> void:
	accelerate_in_direction(Vector2.ZERO)


func stop() -> void:
	max_speed = 0.0


func move(character_body: CharacterBody2D) -> void:
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
