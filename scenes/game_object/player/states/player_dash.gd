class_name PlayerDash
extends State

@export var player: CharacterBody2D

var dash_speed: float = 200.0
var dash_duration: float = 0.2
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func enter(msg: Dictionary = {}) -> void:
    dash_timer = dash_duration
    if msg.has("direction"):
        dash_direction = msg.direction.normalized()
    else:
        var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else Vector2.RIGHT

    if player and "dash_cooldown" in player:
        player.dash_cooldown_timer = player.dash_cooldown

    if player and player.has_node("DashSound"):
        player.get_node("DashSound").play()

func physics_update(delta: float) -> void:
    if not player or not player.has_node("VelocityComponent"):
        state_machine.transition_to("Idle")
        return
        
    dash_timer -= delta
    
    var velocity_component = player.get_node("VelocityComponent")
    velocity_component.velocity = dash_direction * dash_speed
    velocity_component.move(player)

    if dash_timer <= 0.0:
        velocity_component.velocity = Vector2.ZERO
        var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
        if direction == Vector2.ZERO:
            state_machine.transition_to("Idle")
        else:
            state_machine.transition_to("Move")
