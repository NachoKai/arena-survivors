extends Camera2D

var player: Node2D
var camera_smoothing: int = 20


func _ready():
	make_current()
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if player:
		global_position = global_position.lerp(player.global_position, 1.0 - exp(-delta * camera_smoothing)).round()
