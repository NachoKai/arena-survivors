extends Node

func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_collected)

func add_meta_upgrade(upgrade: MetaUpgrade) -> void:
	if not SaveManager.save_data.meta_upgrades.has(upgrade.id):
		SaveManager.save_data.meta_upgrades[upgrade.id] = {
			"quantity": 0
		}
	SaveManager.save_data.meta_upgrades[upgrade.id].quantity += 1
	SaveManager.save_game()

func get_upgrade_count(upgrade_id: String) -> int:
	if not upgrade_id:
		return 0
	if SaveManager.save_data.meta_upgrades.has(upgrade_id):
		return SaveManager.save_data.meta_upgrades[upgrade_id].quantity
	return 0

func on_experience_collected(amount: float) -> void:
	SaveManager.save_data.meta_upgrade_currency += amount

