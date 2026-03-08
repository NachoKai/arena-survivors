class_name PlayerMove
extends State

@export var player: CharacterBody2D

var animation_player: AnimationPlayer
var velocity_component: Node
var visuals: Node

func enter(_msg: Dictionary = {}) -> void:
    if player:
        if not animation_player:
            animation_player = player.get_node_or_null("AnimationPlayer")
        if not velocity_component:
            velocity_component = player.get_node_or_null("VelocityComponent")
        if not visuals:
            visuals = player.get_node_or_null("Visuals")
            
        if animation_player:
            animation_player.play("walk")

func physics_update(_delta: float) -> void:
    if not player:
        return
        
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Handle Dash
    if Input.is_action_just_pressed("dash") and "dash_cooldown_timer" in player and player.dash_cooldown_timer <= 0.0 and direction != Vector2.ZERO:
        state_machine.transition_to("Dash", {"direction": direction})
        return

    # Back to idle if stopped
    if direction == Vector2.ZERO:
        state_machine.transition_to("Idle")
        return
        
    # Process movement
    if velocity_component:
        velocity_component.accelerate_in_direction(direction)
        velocity_component.move(player)

    # Orientation and animation
    if visuals:
        if direction.x < 0:
            visuals.scale.x = -1
        elif direction.x > 0:
            visuals.scale.x = 1
