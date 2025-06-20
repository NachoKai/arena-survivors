extends Node

@export var experience_manager: ExperienceManager
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_pickup_area = preload("res://resources/upgrades/pickup_area.tres")

var upgrade_sword = preload("res://resources/upgrades/sword.tres")
var upgrade_sword_count = preload("res://resources/upgrades/sword_count.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_size = preload("res://resources/upgrades/sword_size.tres")

var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_count = preload("res://resources/upgrades/axe_count.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")
var upgrade_axe_size = preload("res://resources/upgrades/axe_size.tres")

var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_count = preload("res://resources/upgrades/hammer_count.tres")
var upgrade_hammer_damage = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_rate = preload("res://resources/upgrades/hammer_rate.tres")
var upgrade_hammer_size = preload("res://resources/upgrades/hammer_size.tres")
var upgrade_alistair = preload("res://resources/upgrades/alistair.tres")
var upgrade_shadowmere = preload("res://resources/upgrades/shadowmere.tres")

var upgrade_dagger = preload("res://resources/upgrades/dagger.tres")
var upgrade_dagger_count = preload("res://resources/upgrades/dagger_count.tres")
var upgrade_dagger_damage = preload("res://resources/upgrades/dagger_damage.tres")
var upgrade_dagger_rate = preload("res://resources/upgrades/dagger_rate.tres")
var upgrade_dagger_size = preload("res://resources/upgrades/dagger_size.tres")

var upgrade_shadowmere_count = preload("res://resources/upgrades/shadowmere_count.tres")
var upgrade_shadowmere_damage = preload("res://resources/upgrades/shadowmere_damage.tres")
var upgrade_shadowmere_rate = preload("res://resources/upgrades/shadowmere_rate.tres")
var upgrade_shadowmere_size = preload("res://resources/upgrades/shadowmere_size.tres")

var upgrade_alistair_count = preload("res://resources/upgrades/alistair_count.tres")
var upgrade_alistair_damage = preload("res://resources/upgrades/alistair_damage.tres")
var upgrade_alistair_rate = preload("res://resources/upgrades/alistair_rate.tres")
var upgrade_alistair_size = preload("res://resources/upgrades/alistair_size.tres")


func _ready():
	upgrade_pool.add_item(upgrade_player_speed, 5)
	upgrade_pool.add_item(upgrade_pickup_area, 5)

	upgrade_pool.add_item(upgrade_dagger, 8)
	upgrade_pool.add_item(upgrade_axe, 7)
	upgrade_pool.add_item(upgrade_hammer, 6)

	add_starting_ability_upgrades()

	experience_manager.level_up.connect(on_levep_up)


func add_starting_ability_upgrades():
	var selected_character = SaveGame.get_selected_character()

	match selected_character:
		"warrior":
			current_upgrades["sword"] = {
				"resource" = upgrade_sword,
				"quantity" = 1
			}
			upgrade_pool.add_item(upgrade_sword, 7)
			upgrade_pool.add_item(upgrade_sword_count, 5)
			upgrade_pool.add_item(upgrade_sword_damage, 8)
			upgrade_pool.add_item(upgrade_sword_rate, 8)
			upgrade_pool.add_item(upgrade_sword_size, 5)
		"barbarian":
			current_upgrades["axe"] = {
				"resource" = upgrade_axe,
				"quantity" = 1
			}
			upgrade_pool.add_item(upgrade_axe_count, 5)
			upgrade_pool.add_item(upgrade_axe_damage, 8)
			upgrade_pool.add_item(upgrade_axe_rate, 8)
			upgrade_pool.add_item(upgrade_axe_size, 5)
			upgrade_pool.remove_item(upgrade_axe)
		"monk":
			current_upgrades["dagger"] = {
				"resource" = upgrade_dagger,
				"quantity" = 1
			}
			upgrade_pool.add_item(upgrade_dagger_count, 5)
			upgrade_pool.add_item(upgrade_dagger_damage, 8)
			upgrade_pool.add_item(upgrade_dagger_rate, 8)
			upgrade_pool.add_item(upgrade_dagger_size, 5)
			upgrade_pool.remove_item(upgrade_dagger)
		"witch":
			current_upgrades["hammer"] = {
				"resource" = upgrade_hammer,
				"quantity" = 1
			}
			upgrade_pool.add_item(upgrade_hammer_count, 5)
			upgrade_pool.add_item(upgrade_hammer_damage, 8)
			upgrade_pool.add_item(upgrade_hammer_rate, 8)
			upgrade_pool.add_item(upgrade_hammer_size, 5)
			upgrade_pool.remove_item(upgrade_hammer)
		_:
			pass


func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if not has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource" = upgrade,
			"quantity" = 1
		}
	else: current_upgrades[upgrade.id].quantity += 1

	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id].quantity
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)

	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func check_ability_can_evolve(upgrades: Dictionary, ability: String) -> bool:
	var totalQuantity = 0

	for upgrade in upgrades.keys():
		if upgrade.find(ability) == 0:
			totalQuantity += upgrades[upgrade]["quantity"]

	return totalQuantity >= 15


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if not chosen_upgrade: return
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

	var sword_can_evolve = check_ability_can_evolve(current_upgrades, "sword")
	var axe_can_evolve = check_ability_can_evolve(current_upgrades, "axe")
	var dagger_can_evolve = check_ability_can_evolve(current_upgrades, "dagger")
	var hammer_can_evolve = check_ability_can_evolve(current_upgrades, "hammer")

	if sword_can_evolve:
		pass
	if axe_can_evolve:
		pass
	if dagger_can_evolve:
		upgrade_pool.add_item(upgrade_shadowmere, 1000)
	if hammer_can_evolve:
		upgrade_pool.add_item(upgrade_alistair, 1000)


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
	if not upgrade: return
	apply_upgrade(upgrade)


func on_levep_up(_current_level: int):
	var upgrade_scene_instance = upgrade_screen_scene.instantiate()
	if not upgrade_scene_instance: return
	add_child(upgrade_scene_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_scene_instance.set_ability_upgrade(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_scene_instance.upgrade_selected.connect(on_upgrade_selected)
