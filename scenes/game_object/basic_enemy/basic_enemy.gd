extends CharacterBody2D

const MAX_SPEED: int = 40

@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(_delta):
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()
	if direction.x !=0 || direction.y !=0: animation_player.play("walk")
	if direction.x < 0: visuals.scale.x = -1
	elif direction.x > 0: visuals.scale.x = 1


func get_direction_to_player():
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return Vector2.ZERO
	return (player.global_position - global_position).normalized()

