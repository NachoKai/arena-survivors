extends CharacterBody2D

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component: Node = $VelocityComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hit_random_stream_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent
@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var hide_enemy_timer: Timer = $HideEnemyTimer
var screen_size


func _ready():
	hurtbox_component.hit.connect(on_hit)
	screen_size = get_viewport_rect().size
	hide_enemy_timer.timeout.connect(on_timer_timeout)


func _physics_process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	var move_sign = sign(velocity.x)
	if move_sign != 0: visuals.scale = Vector2(move_sign, 1)


func on_hit():
	hit_random_stream_player_component.play_random()


func on_timer_timeout():
	var location_diff = global_position - player.global_position
	if abs(location_diff.x) > (screen_size.x / 2) * 1.4 || abs(location_diff.y) > (screen_size.y / 2) * 1.4:
		visible = false
	else:
		visible = true
