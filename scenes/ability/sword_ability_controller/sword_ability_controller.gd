extends Node

const MAX_RANGE: int = 150
@export var sword_ability: PackedScene
var damage = 5


func _ready():
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null: return
	var enemies = get_enemies_in_range(player)
	if enemies.size() == 0: return
	var closest_enemy = get_closest_enemy(player, enemies)
	use_sword_ability(player, closest_enemy)


func get_enemies_in_range(player: Node2D) -> Array:
	return get_tree().get_nodes_in_group("enemy").filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)


func get_closest_enemy(player: Node2D, enemies: Array) -> Node2D:
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	return enemies[0]


func use_sword_ability(player: Node2D, target_enemy: Node2D):
	var sword_instance = sword_ability.instantiate() as SwordAbility
	player.get_parent().add_child(sword_instance)
	sword_instance.hitbox_component.damage = damage
	sword_instance.global_position = target_enemy.global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4  # TAU: 2 times PI, a full rotation
	var enemy_direction = target_enemy.global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()
