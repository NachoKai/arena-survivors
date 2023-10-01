extends CharacterBody2D

@onready var damage_interval_timer: Timer = $DamageIntervalTimer
const MAX_SPEED: int = 125
const ACCELERATION_SMOOTHING: int = 25
var colliding_bodies_quantity: int = 0


func _ready():
	$CollisionArea.body_entered.connect(on_body_entered)
	$CollisionArea.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)


func _process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()


func check_deal_damage():
	if colliding_bodies_quantity == 0 || damage_interval_timer.is_stopped(): return
	$HealthComponent.damage(1)
	damage_interval_timer.start()


func on_body_entered(other_body: Node2D):
	colliding_bodies_quantity += 1
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	colliding_bodies_quantity -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()
