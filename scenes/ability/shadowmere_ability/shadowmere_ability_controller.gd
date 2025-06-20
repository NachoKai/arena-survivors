extends Node

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var shadowmere_ability_scene: PackedScene
@export var base_damage: int = 8
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 1
var shadowmere_count: int = 1


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player or not foreground: return

	for i in range(shadowmere_count):
		var shadowmere_instance = shadowmere_ability_scene.instantiate()
		if not shadowmere_instance: return
		foreground.add_child(shadowmere_instance)
		shadowmere_instance.global_position = player.global_position
		shadowmere_instance.hitbox_component.damage = base_damage * additional_damage_percent
		shadowmere_instance.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "shadowmere_count":
		shadowmere_count = current_upgrades.shadowmere_count.quantity + 1
	elif upgrade.id == "shadowmere_damage":
		additional_damage_percent = 1 + (current_upgrades.shadowmere_damage.quantity * 0.15)
	elif upgrade.id == "shadowmere_rate":
		var percent_reduction = current_upgrades.shadowmere_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "shadowmere_size":
		additional_size_percent = 1 + (current_upgrades.shadowmere_size.quantity * 0.13)
