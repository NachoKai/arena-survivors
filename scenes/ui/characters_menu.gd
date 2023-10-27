extends CanvasLayer

@export var characters: Array[Character] = []
@onready var grid_container: GridContainer = %GridContainer
@onready var back_button: Button = %BackButton
var character_card_scene = preload("res://scenes/component/character_card.tscn")


func _ready():
	back_button.pressed.connect(on_back_button_pressed)
	for character in characters:
		var character_card_instance = character_card_scene.instantiate()
		grid_container.add_child(character_card_instance)
		character_card_instance.set_character(character)


func on_back_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
