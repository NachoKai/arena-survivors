extends CanvasLayer


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	GameEvents.player_damaged.connect(on_player_damaged)


func on_player_damaged():
	animation_player.play("hit")


