class_name BaseEnemy
extends CharacterBody2D

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var velocity_component: Node = $VelocityComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hit_random_stream_player_component: AudioStreamPlayer2D = $HitRandomAudioPlayerComponent
@onready var enemy_area: CollisionShape2D = $EnemyArea
@onready var spatial_manager = get_node("/root/SpatialManager")

var old_position: Vector2
var is_active: bool = true
var update_interval: float = 1.0/60.0  # Default to 60 fps
var time_since_last_update: float = 0.0
var player: Node2D = null

func _ready():
	hurtbox_component.hit.connect(on_hit)
	player = get_tree().get_first_node_in_group("player")

	# Register with spatial manager
	if spatial_manager:
		spatial_manager.register_entity(self)

	old_position = global_position


func _physics_process(delta):
	if not is_active:
		return

	time_since_last_update += delta
	if time_since_last_update < update_interval:
		return

	time_since_last_update = 0.0

	if velocity_component and player:
		velocity_component.accelerate_to_player()
		velocity_component.move(self)

		if spatial_manager:
			spatial_manager.update_entity_position(self, old_position, global_position)
			old_position = global_position

		var move_sign = sign(velocity.x)
		if move_sign != 0:
			visuals.scale = Vector2(move_sign, 1)


func on_hit():
	if hit_random_stream_player_component:
		hit_random_stream_player_component.play_random()


func frame_save(amount: int = 20):
	var rand_disable = randi() % 100
	if rand_disable < amount:
		enemy_area.call_deferred("set", "disabled", true)
		animation_player.stop()


func set_active(active: bool):
	is_active = active
	set_physics_process(active)
	set_process(active)

	if not active:
		animation_player.stop()
	else:
		animation_player.play()


func set_semi_active():
	is_active = true
	set_physics_process(true)
	set_process(false)
	update_interval = 1.0/30.0  # Reduce update frequency to 30 fps
	animation_player.stop()


func reset_enemy():
	# Reset enemy state when reused from object pool
	velocity = Vector2.ZERO
	is_active = true
	update_interval = 1.0/60.0
	time_since_last_update = 0.0
	if animation_player:
		animation_player.play()
	if enemy_area:
		enemy_area.disabled = false


func _exit_tree():
	if spatial_manager:
		spatial_manager.unregister_entity(self)

