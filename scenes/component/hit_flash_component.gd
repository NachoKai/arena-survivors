extends Node

@export var health_component: Node
@export var sprite: Sprite2D
@export var hit_flash_material: ShaderMaterial
var hit_flash_tween: Tween


func _ready():
	if not health_component: return
	health_component.health_decreased.connect(on_health_decreased)
	sprite.material = hit_flash_material


func on_health_decreased(_current_health):
	if hit_flash_tween != null && hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	var sprite_material = sprite.material as ShaderMaterial
	sprite_material.set_shader_parameter("lerp_percent", 1.0)
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_property(sprite_material, "shader_parameter/lerp_percent", 0.0, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

