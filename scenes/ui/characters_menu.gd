extends CanvasLayer

@export var characters: Array[Character] = []
@onready var grid_container: GridContainer = %GridContainer
@onready var back_button: Button = %BackButton
var character_card_scene = preload("res://scenes/component/character_card.tscn")


func _ready():
	back_button.pressed.connect(on_back_button_pressed)
	GameEvents.character_selected.connect(on_character_selected)
	for character in characters:
		var character_card_instance = character_card_scene.instantiate()
		grid_container.add_child(character_card_instance)
		character_card_instance.set_character(character)

	refresh_character_cards()


func refresh_character_cards():
	for child in grid_container.get_children():
		if child.has_method("handle_use_button"):
			child.handle_use_button()


func on_character_selected(_character_id: String):
	SaveManager.save_game()
	refresh_character_cards()


func on_back_button_pressed():
	SaveManager.save_game()
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
