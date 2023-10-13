extends CanvasLayer

signal transition_halfway

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var skip_emit: bool = false


func transition():
	animation_player.play("default")
	await transition_halfway
	skip_emit = true
	animation_player.play_backwards("default")


func emit_transition_halfway():
	if skip_emit:
		skip_emit = false
		return
	transition_halfway.emit()
