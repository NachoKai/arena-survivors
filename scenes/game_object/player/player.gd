extends CharacterBody2D

@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var collision_area: Area2D = $CollisionArea
@onready var abilities = $Abilities
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var velocity_component: Node = $VelocityComponent
@onready var hit_random_stream_player: AudioStreamPlayer2D = $HitRandomStreamPlayer
@onready var pickup_area_shape: CollisionShape2D = $PickupArea/PickupAreaShape
@onready var night_light_animation = $NightLightAnimation
@export var arena_time_manager: ArenaTimeManager
@onready var image: Sprite2D = %Image
@onready var health_particles: GPUParticles2D = $Visuals/HealthParticles

var colliding_bodies_quantity: int = 0
var base_speed = 0
var base_pickup_area = 30


func _ready():
	if not arena_time_manager: return
#	image.texture = SaveGame.get_selected_character()
	night_light_animation.play("default")
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	collision_area.body_entered.connect(on_body_entered)
	collision_area.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_decreased.connect(on_health_decreased)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()


func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)

	if direction.x != 0 || direction.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")

	if direction.x < 0:
		visuals.scale.x = -1
	elif direction.x > 0:
		visuals.scale.x = 1


func check_deal_damage():
	var isDamageTimerActive = ! damage_interval_timer.is_stopped()
	if colliding_bodies_quantity == 0 || isDamageTimerActive: return
	health_component.damage(10)
	damage_interval_timer.start()


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func on_body_entered(_other_body: Node2D):
	colliding_bodies_quantity += 1
	check_deal_damage()


func on_body_exited(_other_body: Node2D):
	colliding_bodies_quantity -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_decreased(current_health):
	GameEvents.emit_player_damaged(current_health)
	hit_random_stream_player.play_random()


func on_health_changed(_current_health, is_healing):
	if is_healing and health_particles:
		health_particles.emitting = true
	update_health_display()


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not ability_upgrade: return
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades.player_speed.quantity * 0.1)
	elif ability_upgrade.id == "pickup_area":
		pickup_area_shape.shape.radius = base_pickup_area + (current_upgrades.pickup_area.quantity * 6)


func on_arena_difficulty_increased(difficulty: int):
	var health_regeneration_quantity = MetaProgression.get_upgrade_count("health_regeneration")
	if health_regeneration_quantity > 0:
		var is_thirty_second_interval = (difficulty % 6) == 0  # 30 seconds interval
		if is_thirty_second_interval:
			health_component.heal(health_regeneration_quantity)
			if health_particles:
				health_particles.emitting = true
