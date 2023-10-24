extends StaticBody2D

signal open(position, direction)

@onready var current_direction: Vector2 = Vector2.DOWN.rotated(rotation)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hit_random_stream_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent
@onready var marker: Marker2D = $Marker
var is_open: bool = false


func _ready():
	hurtbox_component.hit.connect(on_hit)


func hit():
	if not is_open:
		animated_sprite.play()
		hit_random_stream_player_component.play_random()
		var marker_position = marker.global_position
		open.emit(marker_position, current_direction)
		is_open = true


func on_hit():
	hit()
