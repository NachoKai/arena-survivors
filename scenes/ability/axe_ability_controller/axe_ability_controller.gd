extends Node

@onready var timer: Timer = $Timer
@export var axe_ability_scene: PackedScene
var base_damage = 10
var additional_damage_percent = 1
var default_wait_time


func _ready():
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player: return
	var foreground = get_tree().get_first_node_in_group("foreground") as Node2D
	if not foreground: return
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	if not axe_instance: return
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = base_damage * additional_damage_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades.axe_damage.quantity * 0.10)
