extends Node

@export var basic_enemy_scene: PackedScene
const SPAWN_RADIUS = 375


func _ready():
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	# spawn enemies on screen
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation
	var spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
	var enemy = basic_enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = spawn_position
