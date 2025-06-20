class_name ShadowmereAbility
extends Node2D

@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier
@onready var hitbox_component: Area2D = $HitboxComponent
@export var SPEED: int = 250

var direction
var has_hit_enemies = []


func _ready():
	hitbox_component.body_entered.connect(on_body_entered)
	hitbox_component.area_entered.connect(on_area_entered)
	visible_on_screen_notifier.screen_exited.connect(on_screen_exited)
	if not player: return
	var player_position = player.global_position + player.velocity
	var base_direction = player.global_position.direction_to(player_position)
	var random_adjustment = Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	direction = (base_direction + random_adjustment).normalized()
	rotation = direction.angle()


func _process(delta):
	position += direction * SPEED * delta


func on_body_entered(other_body: Node2D):
	if other_body.is_in_group("enemy") and not has_hit_enemies.has(other_body):
		has_hit_enemies.append(other_body)


func on_area_entered(other_body: Node2D):
	if other_body.is_in_group("enemy") and not has_hit_enemies.has(other_body):
		has_hit_enemies.append(other_body)


func on_screen_exited():
	queue_free()
