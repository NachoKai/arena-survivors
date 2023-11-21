extends Node

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var dagger_ability_scene: PackedScene
@export var base_damage: int = 5
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 1
var dagger_count: int = 1


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player or not foreground: return

	for i in range(dagger_count):
		var dagger_instance = dagger_ability_scene.instantiate() as DaggerAbility
		if not dagger_instance: return
		foreground.add_child(dagger_instance)
		dagger_instance.global_position = player.global_position
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "dagger_count":
		dagger_count = current_upgrades.dagger_count.quantity + 1  # We already have 1 dagger
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades.dagger_damage.quantity * 0.15)
	elif upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades.dagger_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_size":
		additional_size_percent = 1 + (current_upgrades.dagger_size.quantity * 0.13)
