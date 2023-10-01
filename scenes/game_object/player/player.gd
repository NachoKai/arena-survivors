extends CharacterBody2D

const MAX_SPEED: int = 125
const ACCELERATION_SMOOTHING : int = 25


func _process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()

