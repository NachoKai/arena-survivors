extends Node2D

@onready var label: Label = $Label


func _ready():
	pass


func start(text: String):
	label.text = text
	var tween = create_tween()
	const DURATION = 0.3
	tween.set_parallel()
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.chain()
	tween.tween_property(self, "scale", Vector2.ONE * 0.8, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.chain()
	tween.tween_property(self, "global_position", global_position + (Vector2.DOWN * 48), DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	tween.tween_callback(queue_free)
