extends Node

@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene
var current_upgrades = {}


func _ready():
	experience_manager.level_up.connect(on_levep_up)
	

func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else: current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool = upgrade_pool.filter(func (pool_upgrade): return pool_upgrade.id != upgrade.id)

	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var filtered_upgrades = upgrade_pool.duplicate()
	var upgrades_quantity = filtered_upgrades.size()
	for i in upgrades_quantity:
		if upgrades_quantity == 0: break
		var chosen_upgrade = filtered_upgrades.pick_random() as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
		filtered_upgrades = filtered_upgrades.filter(func (upgrade): return upgrade.id != chosen_upgrade.id)
	
	return chosen_upgrades
		

func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)


func on_levep_up(_current_level: int):
	var upgrade_scene_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_scene_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_scene_instance.set_ability_upgrade(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(on_upgrade_selected)
