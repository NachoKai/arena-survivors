extends CharacterBody2D

const MAX_SPEED: int = 40

@onready var health_component: HealthComponent = $HealthComponent


func _process(_delta):
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()


func get_direction_to_player():
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return Vector2.ZERO
	else: return (player.global_position - global_position).normalized()

