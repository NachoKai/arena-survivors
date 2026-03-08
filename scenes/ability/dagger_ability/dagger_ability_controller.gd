extends AbilityController

var additional_damage_percent = 1.0
var additional_size_percent = 1.0
var dagger_count: int = 1


func use_ability() -> void:
	if not player or not foreground: return

	for i in range(dagger_count):
		var dagger_instance = ability_scene.instantiate() as DaggerAbility
		if not dagger_instance: return
		foreground.add_child(dagger_instance)
		dagger_instance.global_position = player.global_position
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if not upgrade: return
	if upgrade.id == "dagger_count":
		dagger_count = current_upgrades.dagger_count.quantity + 1
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades.dagger_damage.quantity * 0.15)
	elif upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades.dagger_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_size":
		additional_size_percent = 1 + (current_upgrades.dagger_size.quantity * 0.13)
