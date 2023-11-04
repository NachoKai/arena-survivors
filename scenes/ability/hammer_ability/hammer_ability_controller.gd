extends Node

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var hammer_ability_scene: PackedScene
@export var base_damage: int = 15
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 1
var hammer_count: int = 0
const BASE_RANGE: int = 100


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player or not foreground: return
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation
	var additional_rotation_degrees = 360.0 / (hammer_count + 1)
	var hammer_distance = randf_range(0, BASE_RANGE)

	for i in range(hammer_count + 1):
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * hammer_distance)
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if not result.is_empty():
			spawn_position = result.position
		var hammer_ability = hammer_ability_scene.instantiate() as HammerAbility
		foreground.add_child(hammer_ability)
		hammer_ability.global_position = spawn_position
		hammer_ability.hitbox_component.damage = base_damage * additional_damage_percent
		hammer_ability.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "hammer_count":
		hammer_count = current_upgrades.hammer_count.quantity + 1  # We already have 1 hammer
	elif upgrade.id == "hammer_damage":
		additional_damage_percent = 1 + (current_upgrades.hammer_damage.quantity * 0.15)
	elif upgrade.id == "hammer_rate":
		var percent_reduction = current_upgrades.hammer_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "hammer_size":
		additional_size_percent = 1 + (current_upgrades.hammer_size.quantity * 0.13)
