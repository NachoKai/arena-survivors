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
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player or not foreground: return

	for i in range(dagger_count + 1):
		var direction = player.global_position.direction_to(player.global_position + player.velocity)
		var dagger_instance = dagger_ability_scene.instantiate() as DaggerAbility
		if not dagger_instance: return
		if not dagger_instance.hitbox_component: return
		if not dagger_instance.hitbox_component.damage: return
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.scale = Vector2.ONE * additional_size_percent

		# Calculate the end position based on player's movement
		var end_position = player.global_position + player.velocity * i * 0.1  # Adjust the multiplier for speed

		# Create a Tween and interpolate the position
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(dagger_instance, "global_position", dagger_instance.global_position, end_position, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

		# Add the dagger to the scene
		foreground.add_child(dagger_instance)



func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
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
