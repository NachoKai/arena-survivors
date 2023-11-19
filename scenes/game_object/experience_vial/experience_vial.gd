extends Node2D

@export var experience_quantity_per_vial: float = 1.5
@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var experience_vial_area: Area2D = $ExperienceVialArea
@onready var experience_vial_area_shape: CollisionShape2D = $ExperienceVialArea/ExperienceVialAreaShape
@onready var experience_vial_image: Sprite2D = $ExperienceVialImage
@onready var random_stream_player_component: AudioStreamPlayer2D = $RandomStreamPlayerComponent


func _ready():
	var random_rotation = randf_range(0, 360)
	experience_vial_image.rotation_degrees = random_rotation
	experience_vial_area.area_entered.connect(on_area_entered)


func tween_collect(percent: float, start_position: Vector2):
	if not player: return
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))


func collect():
	GameEvents.emit_experience_vial_collected(experience_quantity_per_vial)
	queue_free()


func disable_collision():
	experience_vial_area_shape.disabled = true


func on_area_entered(_other_area: Area2D):
	disable_collision.call_deferred()
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(tween.TRANS_BACK)
	tween.tween_property(experience_vial_image, "scale", Vector2.ZERO, 0.10).set_delay(0.40)
	tween.chain()
	tween.tween_callback(collect)
	random_stream_player_component.play_random()
