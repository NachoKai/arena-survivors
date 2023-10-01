extends Node

@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
var current_upgrades = {}

func _ready():
	experience_manager.level_up.connect(on_levep_up)
	
	
func on_levep_up(_current_level: int):
	var chosen_upgrade = upgrade_pool.pick_random() as AbilityUpgrade
	if chosen_upgrade == null: return
	var has_upgrade = current_upgrades.has(chosen_upgrade.id)
	if !has_upgrade:
		current_upgrades[chosen_upgrade.id] = {
			"resource": chosen_upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[chosen_upgrade.id]["quantity"] += 1
