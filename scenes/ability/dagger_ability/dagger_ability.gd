class_name DaggerAbility
extends Node2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var hitbox_component = $HitboxComponent


func _ready():
	pass
