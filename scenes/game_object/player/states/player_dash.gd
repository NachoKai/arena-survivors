class_name PlayerDash
extends State

@export var player: CharacterBody2D

var dash_speed: float = 200.0
var dash_duration: float = 0.2
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var velocity_component: Node
var dash_sound: Node

func enter(msg: Dictionary = {}) -> void:
    dash_timer = dash_duration
    if msg.has("direction"):
        dash_direction = msg.direction.normalized()
    else:
        var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else Vector2.RIGHT

    if player and "dash_cooldown" in player:
        player.dash_cooldown_timer = player.dash_cooldown

    if player:
        if not dash_sound:
            dash_sound = player.get_node_or_null("DashSound")
        if dash_sound:
            dash_sound.play()
            
        if not velocity_component:
            velocity_component = player.get_node_or_null("VelocityComponent")

func physics_update(delta: float) -> void:
    if not player or not velocity_component:
        state_machine.transition_to("Idle")
        return
        
    dash_timer -= delta
    
    velocity_component.velocity = dash_direction * dash_speed
    velocity_component.move(player)

    if dash_timer <= 0.0:
        velocity_component.velocity = Vector2.ZERO
        var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        if direction == Vector2.ZERO:
            state_machine.transition_to("Idle")
        else:
            state_machine.transition_to("Move")
