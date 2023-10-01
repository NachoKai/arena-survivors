extends CharacterBody2D

const MAX_SPEED: int = 40

@onready var health_component: HealthComponent = $HealthComponent

func _ready():
	$HitArea.area_entered.connect(on_area_entered)


func _process(_delta):
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()
	
	
func get_direction_to_player():
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return Vector2.ZERO
	else: return (player.global_position - global_position).normalized()
	

func on_area_entered(_other_area: Area2D):
	health_component.damage(100)

