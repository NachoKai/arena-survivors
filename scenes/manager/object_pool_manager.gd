extends Node

# Dictionary to store pools for different object types
var pools: Dictionary = {}
const POOL_SIZES = {
	"enemy": 100,
	"projectile": 200,
	"experience_vial": 100,
	"effect": 50
}

func _ready():
	initialize_pools()


func initialize_pools():
	for object_type in POOL_SIZES:
		pools[object_type] = []


func get_object(object_type: String, scene_path: String) -> Node:
	if not pools.has(object_type):
		push_warning("Object pool for type %s not initialized" % object_type)
		return null

	# Try to find an inactive object in the pool
	var pool = pools[object_type]
	for obj in pool:
		if not is_instance_valid(obj) or not obj.visible:
			obj.visible = true
			return obj

	# If no inactive object found and pool not full, create new one
	if pool.size() < POOL_SIZES[object_type]:
		var new_obj = load(scene_path).instantiate()
		add_child(new_obj)
		pool.append(new_obj)
		return new_obj

	# If pool is full, reuse the oldest object
	var oldest_obj = pool[0]
	pool.pop_front()
	pool.push_back(oldest_obj)
	oldest_obj.visible = true
	return oldest_obj


func release_object(object: Node, object_type: String):
	if not pools.has(object_type):
		return

	object.visible = false
	# Reset object position far away to prevent any unintended interactions
	if object is Node2D:
		object.global_position = Vector2(-1000, -1000)

	# Optional: Reset any specific properties based on object type
	match object_type:
		"enemy":
			if object.has_method("reset_enemy"):
				object.reset_enemy()
		"projectile":
			if object.has_method("reset_projectile"):
				object.reset_projectile()


# Example usage:
# var enemy = get_object("enemy", "res://scenes/game_object/base_enemy/base_enemy.tscn")
# enemy.global_position = spawn_position
# ... when done with enemy ...
# release_object(enemy, "enemy")
