extends Node

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var alistair_ability_scene: PackedScene
@export var base_damage: int = 35
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 3
var alistair_count: int = 0
const BASE_RANGE: int = 140


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

	var percent_reduction = 3 * 0.15
	timer.wait_time = default_wait_time * (1 - percent_reduction)
	timer.start()


func on_timer_timeout():
	if not player or not foreground: return
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation
	var additional_rotation_degrees = 360.0 / (alistair_count + 1)
	var alistair_distance = randf_range(0, BASE_RANGE)

	for i in range(alistair_count + 1):
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * alistair_distance)
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if not result.is_empty():
			spawn_position = result.position
		var alistair_ability = alistair_ability_scene.instantiate()
		foreground.add_child(alistair_ability)
		alistair_ability.global_position = spawn_position
		alistair_ability.hitbox_component.damage = base_damage * additional_damage_percent
		alistair_ability.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "alistair_count":
		alistair_count = current_upgrades.alistair_count.quantity
	elif upgrade.id == "alistair_damage":
		additional_damage_percent = 1 + (current_upgrades.alistair_damage.quantity * 0.15)
	elif upgrade.id == "alistair_rate":
		var percent_reduction = current_upgrades.alistair_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "alistair_size":
		additional_size_percent = 3 + (current_upgrades.alistair_size.quantity * 0.13)
