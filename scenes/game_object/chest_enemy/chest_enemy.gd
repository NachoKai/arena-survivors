extends BaseEnemy

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite

var is_open: bool = false


func _ready():
	hurtbox_component.hit.connect(on_hit)
	if not is_open:
		velocity_component.stop()
		animation_player.stop()


func hit():
	if not is_open:
		animated_sprite.play()
		hit_random_stream_player_component.play_random()
		is_open = true
		animated_sprite.queue_free()
		animation_player.play("walk")
		velocity_component.max_speed = 60
		velocity_component.accelerate_to_player()


func on_hit():
	hit()
