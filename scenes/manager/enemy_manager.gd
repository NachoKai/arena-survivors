extends Node

@export var enemies_cap: int = 600
@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@onready var timer: Timer = $Timer
@export var arena_time_manager: ArenaTimeManager
@export var rat_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene
@export var vampire_rat_enemy_scene: PackedScene
@export var vampire_wizard_enemy_scene: PackedScene
@export var vampire_bat_enemy_scene: PackedScene
@export var vampire_ghost_enemy_scene: PackedScene
@export var vampire_spider_enemy_scene: PackedScene
@export var vampire_cyclops_enemy_scene: PackedScene
@export var werewolf_enemy_scene: PackedScene

const SPAWN_RADIUS: float = 340.0
var base_spawn_time: float = 0.0
var enemies_to_spawn: int = 1
var enemy_table: WeightedTable = WeightedTable.new()


func _ready() -> void:
	enemy_table.add_item(rat_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, TAU))  # TAU: full rotation

	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset: Vector2 = random_direction * 25.0  # extra so enemies don't spawn in walls
		var query_parameters := PhysicsRayQueryParameters2D.create(
			player.global_position,
			spawn_position + additional_check_offset,
			1
		)
		var result := get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if result.is_empty():
			return spawn_position
		else:
			random_direction = random_direction.rotated(deg_to_rad(90.0))

	return spawn_position


func on_timer_timeout() -> void:
	timer.start()
	if not player:
		return

	for i in enemies_to_spawn:
		var enemy_scene: PackedScene = enemy_table.pick_item()
		if not enemy_scene:
			return

		# Derive pool key dynamically from filename
		var pool_key: String = enemy_scene.resource_path.get_file().get_basename()

		var enemy := ObjectPoolManager.get_object(pool_key, enemy_scene.resource_path) as Node2D
		if not enemy:
			# ObjectPool initialization hit a snag
			return

		var entities := get_tree().get_first_node_in_group("entities")

		# The object might already be in the tree if it's being reused, so only add if it has no parent
		if not enemy.get_parent():
			var children_quantity: int = entities.get_children().size()
			if children_quantity <= enemies_cap:
				entities.add_child(enemy)
			else:
				# Push back if we hit hard cap and it wasn't already in tree
				ObjectPoolManager.release_object(enemy, pool_key)
				continue

		# Assign pool_key so it knows how to release itself
		if "pool_key" in enemy:
			enemy.pool_key = pool_key

		var spawn_position: Vector2 = get_spawn_position()
		enemy.global_position = spawn_position


func on_arena_difficulty_increased(arena_difficulty: int) -> void:
	var time_off := minf((0.1 / 60.0 / 5.0) * arena_difficulty, 0.6)
	timer.wait_time = base_spawn_time - time_off

	if arena_difficulty == 5:  # 30 seconds
		enemy_table.add_item(bat_enemy_scene, 15)
	elif arena_difficulty == 15:  # 1 minute
		enemy_table.add_item(wizard_enemy_scene, 15)
	elif arena_difficulty == 20:
		enemy_table.add_item(ghost_enemy_scene, 20)
	elif arena_difficulty == 25:
		enemy_table.add_item(spider_enemy_scene, 25)
	elif arena_difficulty == 50:
		enemy_table.add_item(cyclops_enemy_scene, 25)

	# Vampires
	elif arena_difficulty == 60:  # 5 minutes
		enemy_table.add_item(vampire_rat_enemy_scene, 60)
	elif arena_difficulty == 65:
		enemy_table.add_item(vampire_bat_enemy_scene, 65)
	elif arena_difficulty == 75:
		enemy_table.add_item(vampire_wizard_enemy_scene, 75)
	elif arena_difficulty == 85:
		enemy_table.add_item(vampire_ghost_enemy_scene, 85)
	elif arena_difficulty == 95:
		enemy_table.add_item(vampire_spider_enemy_scene, 95)
	elif arena_difficulty == 105:
		enemy_table.add_item(vampire_cyclops_enemy_scene, 50)

	# Boss
	elif arena_difficulty == 115:
		enemy_table.add_item(werewolf_enemy_scene, 9999)

	if (arena_difficulty % 6) == 0:  # 30 seconds interval
		enemies_to_spawn += 1

