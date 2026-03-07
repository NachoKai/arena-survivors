extends Node

# Dictionary to store pools for different object types
var pools: Dictionary = {}
const POOL_SIZES: Dictionary = {
	"enemy": 100,
	"projectile": 200,
	"experience_vial": 100,
	"effect": 50,
}


func _ready() -> void:
	initialize_pools()


func initialize_pools() -> void:
	for object_type in POOL_SIZES.keys():
		pools[object_type] = []


func get_object(object_type: String, scene_path: String) -> Node:
	if not pools.has(object_type):
		pools[object_type] = []

	# Try to find an inactive object in the pool
	var pool: Array = pools[object_type]
	for obj in pool:
		if not is_instance_valid(obj) or not obj.visible:
			obj.visible = true
			if obj.has_method("on_spawn"):
				obj.on_spawn()
			return obj

	# If no inactive object found and pool not full, create new one
	var max_size: int = POOL_SIZES.get(object_type, 100) # Default size 100 if missing
	if pool.size() < max_size:
		var new_obj := load(scene_path).instantiate()
		add_child(new_obj)
		pool.append(new_obj)
		if new_obj.has_method("on_spawn"):
			new_obj.on_spawn()
		return new_obj

	# If pool is full, reuse the oldest object
	var oldest_obj := pool[0]
	pool.pop_front()
	pool.push_back(oldest_obj)
	oldest_obj.visible = true
	if oldest_obj.has_method("on_spawn"):
		oldest_obj.on_spawn()
	return oldest_obj


func release_object(object: Node, object_type: String) -> void:
	if not pools.has(object_type):
		return

	if object.has_method("on_despawn"):
		object.on_despawn()

	object.visible = false
	# Reset object position far away to prevent any unintended interactions
	if object is Node2D:
		var node2d := object as Node2D
		node2d.global_position = Vector2(-1000, -1000)


# Example usage:
# var enemy = get_object("enemy", "res://scenes/game_object/base_enemy/base_enemy.tscn")
# enemy.global_position = spawn_position
# ... when done with enemy ...
# release_object(enemy, "enemy")
