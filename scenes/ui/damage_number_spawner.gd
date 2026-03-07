extends Node2D

@export var floating_text_scene: PackedScene = preload("res://scenes/ui/floating_text.tscn")


func _ready() -> void:
	GameEvents.damage_number_requested.connect(on_damage_number_requested)


func on_damage_number_requested(position: Vector2, amount: int) -> void:
	if not floating_text_scene:
		return
	var floating_text := floating_text_scene.instantiate() as Node2D
	if not floating_text:
		return
	add_child(floating_text)
	floating_text.global_position = position
	floating_text.start(str(amount))

