extends Camera2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D

var target_position: Vector2 = Vector2.ZERO
var camera_smoothing: int = 20


func _ready():
	make_current()  # Forces this Camera2D to become the current active one


func _process(delta):
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * camera_smoothing))  #https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/


func acquire_target():
	if not player: return Vector2.ZERO
	else: target_position = player.global_position


