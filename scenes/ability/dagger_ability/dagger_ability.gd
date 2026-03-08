class_name DaggerAbility
extends Node2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier
@onready var hitbox_component: Area2D = $HitboxComponent
@export var SPEED: int = 200

var direction


func _ready() -> void:
	hitbox_component.body_entered.connect(on_body_entered)
	hitbox_component.area_entered.connect(on_body_entered)
	visible_on_screen_notifier.screen_exited.connect(on_screen_exited)

func on_spawn() -> void:
	if not player: return
	var player_position := player.global_position + player.velocity
	var base_direction := player.global_position.direction_to(player_position)
	var random_adjustment := Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	direction = (base_direction + random_adjustment).normalized()
	rotation = direction.angle()
	
func on_despawn() -> void:
	direction = Vector2.ZERO


func _process(delta: float) -> void:
	position += direction * SPEED * delta


func on_body_entered(_other_body: Node2D) -> void:
	ObjectPoolManager.release_object(self, "dagger_ability")


func on_area_entered(_other_body: Node2D) -> void:
	ObjectPoolManager.release_object(self, "dagger_ability")


func on_screen_exited() -> void:
	ObjectPoolManager.release_object(self, "dagger_ability")
