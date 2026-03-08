class_name AbilityController
extends Node

@export var ability_scene: PackedScene
@export var base_damage: float = 10.0
@export var base_wait_time: float = 1.0

var current_damage: float
var current_wait_time: float
var timer: Timer
var default_wait_time: float

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground") as Node2D

func _ready() -> void:
    current_damage = base_damage
    
    if has_node("Timer"):
        timer = get_node("Timer")
        timer.wait_time = base_wait_time
        default_wait_time = base_wait_time
        current_wait_time = base_wait_time
        timer.timeout.connect(on_timer_timeout)
        
    GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
    
func on_timer_timeout() -> void:
    use_ability()
    
func use_ability() -> void:
    # To be overridden by specific ability controllers
    pass

func on_ability_upgrade_added(_upgrade: AbilityUpgrade, _current_upgrades: Dictionary) -> void:
    # To be overridden by specific ability controllers
    pass
