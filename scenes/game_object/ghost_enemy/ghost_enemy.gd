extends CharacterBody2D

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component: Node = $VelocityComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hit_random_stream_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent


func _ready():
	hurtbox_component.hit.connect(on_hit)


func _process(_delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	var move_sign = sign(velocity.x)
	if move_sign != 0: visuals.scale = Vector2(move_sign, 1)


func on_hit():
	hit_random_stream_player_component.play_random()
