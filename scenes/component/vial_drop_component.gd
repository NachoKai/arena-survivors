extends Node

@export_range(0, 1) var drop_percent: float = 0.5
@export var health_component: Node
@export var vial_scene: PackedScene


func _ready():
	if not health_component: return
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	var adjusted_drop_percent = drop_percent
	var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	if experience_gain_upgrade_count > 0:
		adjusted_drop_percent += 0.1
	if randf() > adjusted_drop_percent: return
	if not vial_scene: return
	if not owner is Node2D: return
	var spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	var entities = get_tree().get_first_node_in_group("entities")
	if not entities || not vial_instance: return
	entities.add_child(vial_instance)
	vial_instance.global_position = spawn_position
