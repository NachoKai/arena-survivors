extends CharacterBody2D

@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var collision_area: Area2D = $CollisionArea
@onready var abilities = $Abilities

const MAX_SPEED: int = 125
const ACCELERATION_SMOOTHING: int = 25
var colliding_bodies_quantity: int = 0


func _ready():
	collision_area.body_entered.connect(on_body_entered)
	collision_area.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()


func _process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()


func check_deal_damage():
	var isDamageTimerActive = ! damage_interval_timer.is_stopped()
	if colliding_bodies_quantity == 0 || isDamageTimerActive: return
	health_component.damage(1)
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


func on_health_changed():
	update_health_display()
	
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, _current_upgrades: Dictionary):
	if not ability_upgrade is Ability: return
	var ability = ability_upgrade as Ability
	abilities.add_child(ability.ability_controller_scene.instantiate())
		
