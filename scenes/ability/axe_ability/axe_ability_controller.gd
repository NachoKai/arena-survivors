extends Node

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
@onready var timer: Timer = $Timer
@export var axe_ability_scene: PackedScene
@export var base_damage: int = 10
var default_wait_time
var additional_damage_percent = 1
var additional_size_percent = 1
var axe_count: int = 0


func _ready():
	default_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	if not player or not foreground: return

	for i in range(axe_count + 1):
		var axe_instance = axe_ability_scene.instantiate() as AxeAbility
		if not axe_instance: return
		foreground.add_child(axe_instance)
		var angle = i * (360 / (axe_count + 1))
		var radius = 100
		var offset = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * radius
		axe_instance.global_position = player.global_position + offset
		axe_instance.hitbox_component.damage = base_damage * additional_damage_percent
		axe_instance.scale = Vector2.ONE * additional_size_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not upgrade: return
	if upgrade.id == "axe_count":
		axe_count = current_upgrades.axe_count.quantity + 1  # We already have 1 axe
	elif upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades.axe_damage.quantity * 0.15)
	elif upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades.axe_rate.quantity * 0.15
		timer.wait_time = default_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "axe_size":
		additional_size_percent = 1 + (current_upgrades.axe_size.quantity * 0.13)
