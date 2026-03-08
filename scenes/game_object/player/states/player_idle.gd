class_name PlayerIdle
extends State

@export var player: CharacterBody2D

var animation_player: AnimationPlayer
var dash_sound: AudioStreamPlayer2D

func enter(_msg: Dictionary = {}) -> void:
    if player:
        if not animation_player:
            animation_player = player.get_node_or_null("AnimationPlayer")
        
        if animation_player:
            animation_player.play("idle")

func physics_update(_delta: float) -> void:
    if not player:
        return
        
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    # Check for dash first
    if Input.is_action_just_pressed("dash") and "dash_cooldown_timer" in player and player.dash_cooldown_timer <= 0.0 and direction != Vector2.ZERO:
        state_machine.transition_to("Dash", {"direction": direction})
        return
        
    if direction != Vector2.ZERO:
        state_machine.transition_to("Move")
