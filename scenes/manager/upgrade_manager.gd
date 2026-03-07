extends Node

@export var experience_manager: ExperienceManager
@export var upgrade_screen_scene: PackedScene

var current_upgrades: Dictionary = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_player_speed: AbilityUpgrade = preload("res://resources/upgrades/player_speed.tres")
var upgrade_pickup_area: AbilityUpgrade = preload("res://resources/upgrades/pickup_area.tres")

var upgrade_sword: AbilityUpgrade = preload("res://resources/upgrades/sword.tres")
var upgrade_sword_count: AbilityUpgrade = preload("res://resources/upgrades/sword_count.tres")
var upgrade_sword_damage: AbilityUpgrade = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_sword_rate: AbilityUpgrade = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_size: AbilityUpgrade = preload("res://resources/upgrades/sword_size.tres")

var upgrade_axe: AbilityUpgrade = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_count: AbilityUpgrade = preload("res://resources/upgrades/axe_count.tres")
var upgrade_axe_damage: AbilityUpgrade = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate: AbilityUpgrade = preload("res://resources/upgrades/axe_rate.tres")
var upgrade_axe_size: AbilityUpgrade = preload("res://resources/upgrades/axe_size.tres")

var upgrade_hammer: AbilityUpgrade = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_count: AbilityUpgrade = preload("res://resources/upgrades/hammer_count.tres")
var upgrade_hammer_damage: AbilityUpgrade = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_rate: AbilityUpgrade = preload("res://resources/upgrades/hammer_rate.tres")
var upgrade_hammer_size: AbilityUpgrade = preload("res://resources/upgrades/hammer_size.tres")
var upgrade_alistair: AbilityUpgrade = preload("res://resources/upgrades/alistair.tres")
var upgrade_shadowmere: AbilityUpgrade = preload("res://resources/upgrades/shadowmere.tres")

var upgrade_dagger: AbilityUpgrade = preload("res://resources/upgrades/dagger.tres")
var upgrade_dagger_count: AbilityUpgrade = preload("res://resources/upgrades/dagger_count.tres")
var upgrade_dagger_damage: AbilityUpgrade = preload("res://resources/upgrades/dagger_damage.tres")
var upgrade_dagger_rate: AbilityUpgrade = preload("res://resources/upgrades/dagger_rate.tres")
var upgrade_dagger_size: AbilityUpgrade = preload("res://resources/upgrades/dagger_size.tres")

var upgrade_shadowmere_count: AbilityUpgrade = preload("res://resources/upgrades/shadowmere_count.tres")
var upgrade_shadowmere_damage: AbilityUpgrade = preload("res://resources/upgrades/shadowmere_damage.tres")
var upgrade_shadowmere_rate: AbilityUpgrade = preload("res://resources/upgrades/shadowmere_rate.tres")
var upgrade_shadowmere_size: AbilityUpgrade = preload("res://resources/upgrades/shadowmere_size.tres")

var upgrade_alistair_count: AbilityUpgrade = preload("res://resources/upgrades/alistair_count.tres")
var upgrade_alistair_damage: AbilityUpgrade = preload("res://resources/upgrades/alistair_damage.tres")
var upgrade_alistair_rate: AbilityUpgrade = preload("res://resources/upgrades/alistair_rate.tres")
var upgrade_alistair_size: AbilityUpgrade = preload("res://resources/upgrades/alistair_size.tres")


func _ready() -> void:
	upgrade_pool.add_item(upgrade_player_speed, 5)
	upgrade_pool.add_item(upgrade_pickup_area, 5)

	upgrade_pool.add_item(upgrade_dagger, 8)
	upgrade_pool.add_item(upgrade_axe, 7)
	upgrade_pool.add_item(upgrade_hammer, 6)

	add_starting_ability_upgrades()

	experience_manager.level_up.connect(on_levep_up)


func add_starting_ability_upgrades() -> void:
	var selected_character := SaveGame.get_selected_character()

	match selected_character:
		"warrior":
			current_upgrades["sword"] = {
				"resource": upgrade_sword,
				"quantity": 1,
			}
			upgrade_pool.add_item(upgrade_sword, 7)
			upgrade_pool.add_item(upgrade_sword_count, 5)
			upgrade_pool.add_item(upgrade_sword_damage, 8)
			upgrade_pool.add_item(upgrade_sword_rate, 8)
			upgrade_pool.add_item(upgrade_sword_size, 5)
		"barbarian":
			current_upgrades["axe"] = {
				"resource": upgrade_axe,
				"quantity": 1,
			}
			upgrade_pool.add_item(upgrade_axe_count, 5)
			upgrade_pool.add_item(upgrade_axe_damage, 8)
			upgrade_pool.add_item(upgrade_axe_rate, 8)
			upgrade_pool.add_item(upgrade_axe_size, 5)
			upgrade_pool.remove_item(upgrade_axe)
		"monk":
			current_upgrades["dagger"] = {
				"resource": upgrade_dagger,
				"quantity": 1,
			}
			upgrade_pool.add_item(upgrade_dagger_count, 5)
			upgrade_pool.add_item(upgrade_dagger_damage, 8)
			upgrade_pool.add_item(upgrade_dagger_rate, 8)
			upgrade_pool.add_item(upgrade_dagger_size, 5)
			upgrade_pool.remove_item(upgrade_dagger)
		"witch":
			current_upgrades["hammer"] = {
				"resource": upgrade_hammer,
				"quantity": 1,
			}
			upgrade_pool.add_item(upgrade_hammer_count, 5)
			upgrade_pool.add_item(upgrade_hammer_damage, 8)
			upgrade_pool.add_item(upgrade_hammer_rate, 8)
			upgrade_pool.add_item(upgrade_hammer_size, 5)
			upgrade_pool.remove_item(upgrade_hammer)
		_:
			pass


func apply_upgrade(upgrade: AbilityUpgrade) -> void:
	var has_upgrade := current_upgrades.has(upgrade.id)
	if not has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1,
		}
	else:
		current_upgrades[upgrade.id].quantity += 1

	if upgrade.max_quantity > 0:
		var current_quantity: int = current_upgrades[upgrade.id].quantity
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)

	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func check_ability_can_evolve(upgrades: Dictionary, ability: String) -> bool:
	var total_quantity := 0

	for upgrade_key in upgrades.keys():
		if String(upgrade_key).begins_with(ability):
			total_quantity += upgrades[upgrade_key]["quantity"]

	return total_quantity >= 15


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade) -> void:
	if not chosen_upgrade:
		return
	if chosen_upgrade.id == upgrade_sword.id:
		upgrade_pool.add_item(upgrade_sword_count, 5)
		upgrade_pool.add_item(upgrade_sword_damage, 8)
		upgrade_pool.add_item(upgrade_sword_rate, 8)
		upgrade_pool.add_item(upgrade_sword_size, 5)
	elif chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_count, 5)
		upgrade_pool.add_item(upgrade_axe_damage, 8)
		upgrade_pool.add_item(upgrade_axe_rate, 8)
		upgrade_pool.add_item(upgrade_axe_size, 5)
	elif chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_count, 5)
		upgrade_pool.add_item(upgrade_hammer_damage, 8)
		upgrade_pool.add_item(upgrade_hammer_rate, 8)
		upgrade_pool.add_item(upgrade_hammer_size, 5)
	elif chosen_upgrade.id == upgrade_dagger.id:
		upgrade_pool.add_item(upgrade_dagger_count, 5)
		upgrade_pool.add_item(upgrade_dagger_damage, 8)
		upgrade_pool.add_item(upgrade_dagger_rate, 8)
		upgrade_pool.add_item(upgrade_dagger_size, 5)
	elif chosen_upgrade.id == upgrade_alistair.id:
		current_upgrades.erase("hammer")
		upgrade_pool.remove_item(upgrade_hammer)
		upgrade_pool.remove_item(upgrade_hammer_count)
		upgrade_pool.remove_item(upgrade_hammer_damage)
		upgrade_pool.remove_item(upgrade_hammer_rate)
		upgrade_pool.remove_item(upgrade_hammer_size)

		if current_upgrades.has("hammer_count"):
			current_upgrades["alistair_count"] = current_upgrades["hammer_count"]
			current_upgrades.erase("hammer_count")
		if current_upgrades.has("hammer_damage"):
			current_upgrades["alistair_damage"] = current_upgrades["hammer_damage"]
			current_upgrades.erase("hammer_damage")
		if current_upgrades.has("hammer_rate"):
			current_upgrades["alistair_rate"] = current_upgrades["hammer_rate"]
			current_upgrades.erase("hammer_rate")
		if current_upgrades.has("hammer_size"):
			current_upgrades["alistair_size"] = current_upgrades["hammer_size"]
			current_upgrades.erase("hammer_size")

		upgrade_pool.add_item(upgrade_alistair_count, 5)
		upgrade_pool.add_item(upgrade_alistair_damage, 8)
		upgrade_pool.add_item(upgrade_alistair_rate, 8)
		upgrade_pool.add_item(upgrade_alistair_size, 5)
	elif chosen_upgrade.id == upgrade_shadowmere.id:
		current_upgrades.erase("dagger")
		upgrade_pool.remove_item(upgrade_dagger)
		upgrade_pool.remove_item(upgrade_dagger_count)
		upgrade_pool.remove_item(upgrade_dagger_damage)
		upgrade_pool.remove_item(upgrade_dagger_rate)
		upgrade_pool.remove_item(upgrade_dagger_size)

		if current_upgrades.has("dagger_count"):
			current_upgrades["shadowmere_count"] = current_upgrades["dagger_count"]
			current_upgrades.erase("dagger_count")
		if current_upgrades.has("dagger_damage"):
			current_upgrades["shadowmere_damage"] = current_upgrades["dagger_damage"]
			current_upgrades.erase("dagger_damage")
		if current_upgrades.has("dagger_rate"):
			current_upgrades["shadowmere_rate"] = current_upgrades["dagger_rate"]
			current_upgrades.erase("dagger_rate")
		if current_upgrades.has("dagger_size"):
			current_upgrades["shadowmere_size"] = current_upgrades["dagger_size"]
			current_upgrades.erase("dagger_size")

		upgrade_pool.add_item(upgrade_shadowmere_count, 5)
		upgrade_pool.add_item(upgrade_shadowmere_damage, 8)
		upgrade_pool.add_item(upgrade_shadowmere_rate, 8)
		upgrade_pool.add_item(upgrade_shadowmere_size, 5)

	var sword_can_evolve := check_ability_can_evolve(current_upgrades, "sword")
	var axe_can_evolve := check_ability_can_evolve(current_upgrades, "axe")
	var dagger_can_evolve := check_ability_can_evolve(current_upgrades, "dagger")
	var hammer_can_evolve := check_ability_can_evolve(current_upgrades, "hammer")

	var selected_character := SaveGame.get_selected_character()

	if sword_can_evolve:
		pass
	if axe_can_evolve:
		pass
	if dagger_can_evolve and selected_character == "monk":
		upgrade_pool.add_item(upgrade_shadowmere, 1000)
	if hammer_can_evolve and selected_character == "witch":
		upgrade_pool.add_item(upgrade_alistair, 1000)


func pick_upgrades() -> Array[AbilityUpgrade]:
	var chosen_upgrades: Array[AbilityUpgrade] = []
	var upgrade_pool_quantity := upgrade_pool.items.size()
	var chosen_upgrades_quantity := chosen_upgrades.size()

	for i in upgrade_pool_quantity:
		if upgrade_pool_quantity == chosen_upgrades_quantity:
			break
		var chosen_upgrade: AbilityUpgrade = upgrade_pool.pick_item(chosen_upgrades)
		chosen_upgrades.append(chosen_upgrade)

	return chosen_upgrades


func on_upgrade_selected(upgrade: AbilityUpgrade) -> void:
	if not upgrade:
		return
	apply_upgrade(upgrade)


func on_levep_up(_current_level: int) -> void:
	var upgrade_scene_instance := upgrade_screen_scene.instantiate()
	if not upgrade_scene_instance:
		return
	add_child(upgrade_scene_instance)
	var chosen_upgrades := pick_upgrades()
	upgrade_scene_instance.set_ability_upgrade(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(on_upgrade_selected)
