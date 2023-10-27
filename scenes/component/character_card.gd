extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var character_image: Sprite2D = %Image
@onready var use_button: Button = %UseButton
var disabled: bool = false

func _ready():
	use_button.pressed.connect(on_use_button_pressed)


func set_character(character: Character):
	if not character: return
	name_label.text = character.name
	if character.image_path:
		character_image.texture = load(character.image_path)
	else:
		character_image.visible = false


func on_use_button_pressed():
	pass