extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene
var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")


func _ready():
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	experience_manager.level_up.connect(on_levep_up)


func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if ! has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else: current_upgrades[upgrade.id]["quantity"] += 1

	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity: upgrade_pool.remove_item(upgrade)

	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade == null: return
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var upgrade_pool_quantity = upgrade_pool.items.size()
	var chosen_upgrades_quantity = chosen_upgrades.size()

	for i in upgrade_pool_quantity:
		if upgrade_pool_quantity == chosen_upgrades_quantity: break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)

	return chosen_upgrades


func on_upgrade_selected(upgrade: AbilityUpgrade):
	if upgrade == null: return
	apply_upgrade(upgrade)


func on_levep_up(_current_level: int):
	var upgrade_scene_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_scene_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_scene_instance.set_ability_upgrade(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(on_upgrade_selected)
