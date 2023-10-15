extends CanvasLayer

signal transition_halfway

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

func transition():
	color_rect.visible = true
	animation_player.play("default")
	await animation_player.animation_finished
	transition_halfway.emit()
	animation_player.play_backwards("default")
	await animation_player.animation_finished
	color_rect.visible = false
