extends Node

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var dagger_ability_scene: PackedScene
@export var base_damage: int = 6
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 1
var dagger_count: int = 0


func _ready():
	print("ready")
	default_wait_time = timer.wait_time
	print("default_wait_time: ", default_wait_time)
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	print("timeout")
	if not player or not foreground: return

	for i in range(dagger_count + 1):
		var direction = player.global_position.direction_to(player.global_position + player.velocity)
		print("direction: ", direction)
		var dagger_instance = dagger_ability_scene.instantiate() as DaggerAbility
		if not dagger_instance: return

		var angle = i * (360 / (dagger_count + 1))
		print("angle: ", angle)
		var offset = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * 100
		print("offset: ", offset)
		foreground.add_child(dagger_instance)
		dagger_instance.global_position = player.global_position + offset

		dagger_instance.rotation_degrees = direction.angle() + 90
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.scale = Vector2.ONE * additional_size_percent

		var velocity = direction.normalized() * 500
		print("velocity: ", velocity)
#		dagger_instance.velocity = velocity


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	print("on_ability_upgrade_added")
	if not upgrade: return
	if upgrade.id == "dagger_count":
		dagger_count = current_upgrades.dagger_count.quantity + 1  # We already have 1 dagger
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades.dagger_damage.quantity * 0.15)
	elif upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades.dagger_rate.quantity * 0.1
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_size":
		additional_size_percent = 1 + (current_upgrades.dagger_size.quantity * 0.1)
