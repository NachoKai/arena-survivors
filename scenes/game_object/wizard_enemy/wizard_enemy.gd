extends CharacterBody2D

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component: Node = $VelocityComponent
var is_moving: bool = false


func _process(_delta):
	if is_moving: velocity_component.accelerate_to_player()
	else: velocity_component.decelerate()
	velocity_component.move(self)
	var move_sign = sign(velocity.x)
	if move_sign != 0: visuals.scale = Vector2(move_sign, 1)


func set_is_moving(moving: bool):
	is_moving == moving
