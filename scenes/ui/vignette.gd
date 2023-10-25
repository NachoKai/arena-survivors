extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect


func _ready():
	GameEvents.player_damaged.connect(on_player_damaged)


func on_player_damaged(_current_health):
	color_rect.visible = true
	animation_player.play("hit")
	await animation_player.animation_finished
	color_rect.visible = false
