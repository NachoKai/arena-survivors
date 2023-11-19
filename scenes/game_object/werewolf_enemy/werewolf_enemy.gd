extends BaseEnemy

@onready var enemy_animation: AnimatedSprite2D = $Visuals/EnemyAnimation


func _ready():
	hurtbox_component.hit.connect(on_hit)


func on_hit():
	hit_random_stream_player_component.play_random()
	enemy_animation.play("attack")
	await get_tree().create_timer(0.5).timeout
	enemy_animation.play("default")
