class_name DaggerAbility
extends Node2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var hitbox_component = $HitboxComponent
@export var SPEED: int = 30
var direction: Vector2 = Vector2.UP


func _ready():
	var player_future_position = player.global_position + player.velocity
	var direction = player.global_position.direction_to(player_future_position)
	var rotation_angle = direction.angle_to(Vector2(0, -1))
	rotation_degrees = rotation_angle


func _process(delta):
	position += direction * SPEED * delta
