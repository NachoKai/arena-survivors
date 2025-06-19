extends Node

const CELL_SIZE = 100  # Size of each grid cell
const ACTIVE_DISTANCE = 800  # Distance at which entities are fully active
const SEMI_ACTIVE_DISTANCE = 1200  # Distance at which entities are partially active

var grid = {}  # Dictionary to store entities in grid cells
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Spatial manager: Player not found")


func _physics_process(_delta):
	if not player:
		return
	update_entity_states()


func register_entity(entity: Node2D):
	var cell = get_cell_coords(entity.global_position)
	if not grid.has(cell):
		grid[cell] = []
	grid[cell].append(entity)


func unregister_entity(entity: Node2D):
	var cell = get_cell_coords(entity.global_position)
	if grid.has(cell):
		grid[cell].erase(entity)
		if grid[cell].is_empty():
			grid.erase(cell)


func update_entity_position(entity: Node2D, old_pos: Vector2, new_pos: Vector2):
	var old_cell = get_cell_coords(old_pos)
	var new_cell = get_cell_coords(new_pos)

	if old_cell != new_cell:
		if grid.has(old_cell):
			grid[old_cell].erase(entity)
			if grid[old_cell].is_empty():
				grid.erase(old_cell)

		if not grid.has(new_cell):
			grid[new_cell] = []
		grid[new_cell].append(entity)


func get_cell_coords(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / CELL_SIZE), floor(pos.y / CELL_SIZE))


func get_nearby_entities(pos: Vector2, radius: float) -> Array:
	var nearby = []
	var cell_radius = ceili(radius / CELL_SIZE)
	var center_cell = get_cell_coords(pos)

	for x in range(-cell_radius, cell_radius + 1):
		for y in range(-cell_radius, cell_radius + 1):
			var check_cell = Vector2i(center_cell.x + x, center_cell.y + y)
			if grid.has(check_cell):
				for entity in grid[check_cell]:
					if entity.global_position.distance_to(pos) <= radius:
						nearby.append(entity)

	return nearby


func update_entity_states():
	var player_cell = get_cell_coords(player.global_position)
	var cells_to_check = get_cells_in_range(player_cell, ceili(SEMI_ACTIVE_DISTANCE / CELL_SIZE))

	for cell in cells_to_check:
		if not grid.has(cell):
			continue

		for entity in grid[cell]:
			var distance = entity.global_position.distance_to(player.global_position)

			if distance <= ACTIVE_DISTANCE:
				set_entity_active_state(entity, true)
			elif distance <= SEMI_ACTIVE_DISTANCE:
				set_entity_semi_active_state(entity)
			else:
				set_entity_active_state(entity, false)


func get_cells_in_range(center: Vector2i, radius: int) -> Array:
	var cells = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			cells.append(Vector2i(center.x + x, center.y + y))
	return cells


func set_entity_active_state(entity: Node2D, active: bool):
	if not is_instance_valid(entity):
		return

	if entity.has_method("set_active"):
		entity.set_active(active)

	# Default implementation if entity doesn't have custom method
	entity.set_physics_process(active)
	entity.set_process(active)

	# Keep collision enabled but reduce physics update frequency
	if entity.has_node("HurtboxComponent"):
		entity.get_node("HurtboxComponent").monitoring = active


func set_entity_semi_active_state(entity: Node2D):
	if not is_instance_valid(entity):
		return

	if entity.has_method("set_semi_active"):
		entity.set_semi_active()

	# Default implementation if entity doesn't have custom method
	entity.set_physics_process(true)
	entity.set_process(false)  # Disable visual updates

	# Keep collision enabled but reduce physics update frequency
	if entity.has_node("HurtboxComponent"):
		entity.get_node("HurtboxComponent").monitoring = true
