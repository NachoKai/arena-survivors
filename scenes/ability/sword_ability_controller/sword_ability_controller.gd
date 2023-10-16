extends Node

@onready var timer: Timer = $Timer
@export var sword_ability: PackedScene
@export var base_damage = 5
const MAX_RANGE: int = 150
var additional_damage_percent = 1
var default_wait_time


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player: return
	var enemies = get_enemies_in_range(player)
	if not enemies || enemies.size() == 0: return
	var closest_enemy = get_closest_enemy(player, enemies)
	use_sword_ability(player, closest_enemy)


func get_enemies_in_range(player: Node2D) -> Array:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies: return []
	return enemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)


func get_closest_enemy(player: Node2D, enemies: Array) -> Node2D:
	if not enemies || enemies.size() == 0: return null
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	return enemies[0]


func use_sword_ability(_player: Node2D, target_enemy: Node2D):
	var sword_instance = sword_ability.instantiate() as SwordAbility
	if not sword_instance: return
	var foreground = get_tree().get_first_node_in_group("foreground")
	if not foreground: return
	foreground.add_child(sword_instance)
	sword_instance.hitbox_component.damage = base_damage * additional_damage_percent
	sword_instance.global_position = target_enemy.global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4  # TAU: 2 times PI, a full rotation
	var enemy_direction = target_enemy.global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades.sword_rate.quantity * 0.1
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "sword_damage":
		additional_damage_percent = 1 + (current_upgrades.sword_damage.quantity * 0.15)
