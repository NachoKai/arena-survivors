extends Node

@onready var timer: Timer = $Timer
@export var hammer_ability_scene: PackedScene
const BASE_RANGE: int = 100
const BASE_DAMAGE: int = 15


func _ready():
	timer.timeout.connect(on_timer_timeout)
	

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player: return Vector2.ZERO
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation
	spawn_position = player.global_position + (random_direction * BASE_RANGE)
	var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	if not result.is_empty(): spawn_position = result["position"]
	var hammer_ability = hammer_ability_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground").add_child(hammer_ability)
	hammer_ability.global_position = spawn_position
	hammer_ability.hitbox_component.damage = BASE_DAMAGE
