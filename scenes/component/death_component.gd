extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $GPUParticles2D
@export var healt_component: Node
@export var sprite: Sprite2D
@onready var hit_random_audio_player_component = $HitRandomAudioPlayerComponent


func _ready():
	particles.texture = sprite.texture
	healt_component.died.connect(on_died)


func on_died():
	if owner == null || not owner is Node2D: return
	var spawn_position = owner.global_position
	var entities = get_tree().get_first_node_in_group("entities")
	get_parent().remove_child(self)
	entities.add_child(self)
	global_position = spawn_position
	animation_player.play("default")
	hit_random_audio_player_component.play_random()

