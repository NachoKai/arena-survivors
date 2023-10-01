extends CharacterBody2D


const MAX_SPEED: int = 200


func _process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * MAX_SPEED
	move_and_slide()

