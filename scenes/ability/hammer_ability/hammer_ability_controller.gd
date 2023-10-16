extends Node

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var timer: Timer = $Timer
@export var hammer_ability_scene: PackedScene
@export var base_damage: int = 15
const BASE_RANGE: int = 100
var hammer_count: int = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player: return
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation
	var additional_rotation_degrees = 360.0 / (hammer_count + 1)
	var hammer_distance = randf_range(0, BASE_RANGE)

	for i in range(hammer_count + 1):
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * hammer_distance)
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if not result.is_empty(): spawn_position = result.position
		var hammer_ability = hammer_ability_scene.instantiate() as Node2D
		get_tree().get_first_node_in_group("foreground").add_child(hammer_ability)
		hammer_ability.global_position = spawn_position
		hammer_ability.hitbox_component.damage = base_damage


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "hammer_count":
		hammer_count = current_upgrades.hammer_count.quantity
