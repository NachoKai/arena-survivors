extends Node

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var timer: Timer = $Timer
@export var enemies_cap: int = 650
@export var arena_time_manager: ArenaTimeManager
@export var rat_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene

const SPAWN_RADIUS: int = 375
var base_spawn_time: float = 0
var enemies_to_spawn = 1
var enemy_table = WeightedTable.new()


func _ready():
	enemy_table.add_item(rat_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position():
	if not player: return Vector2.ZERO
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))  # TAU: 2 times PI, a full rotation

	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20  # 20px extra so that enemies dont get stuck if spawning over a wall
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if result.is_empty(): return spawn_position
		else: random_direction = random_direction.rotated(deg_to_rad(90))

	return spawn_position


func on_timer_timeout():
	timer.start()
	if not player: return

	for i in enemies_to_spawn:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as Node2D
		var entities = get_tree().get_first_node_in_group("entities")
		var children_quantity = entities.get_children().size()

		if children_quantity <= enemies_cap:
			entities.add_child(enemy)
			var spawn_position = get_spawn_position()
			enemy.global_position = spawn_position


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = min((0.1 / 60 / 5) * arena_difficulty, 0.7)
	timer.wait_time = base_spawn_time - time_off

	if arena_difficulty == 6:
		enemy_table.add_item(bat_enemy_scene, 12)
	elif arena_difficulty == 12:
		enemy_table.add_item(wizard_enemy_scene, 8)
	elif arena_difficulty == 18:
		enemy_table.add_item(ghost_enemy_scene, 10)
	elif arena_difficulty == 24:
		enemy_table.add_item(spider_enemy_scene, 10)
	elif arena_difficulty == 30:
		enemy_table.add_item(cyclops_enemy_scene, 4)

	if (arena_difficulty % 6) == 0:  # 30 seconds interval
		enemies_to_spawn += 1

