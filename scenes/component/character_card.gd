extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var character_image: Sprite2D = %Image
@onready var use_button: Button = %UseButton

var character_id: String
var implemented_characters = ["Darius", "Kael", "Zenith", "Seraphina"]

func _ready():
	use_button.pressed.connect(on_use_button_pressed)


func set_character(character: Character):
	if not character: return
	character_id = character.id
	name_label.text = character.name
	if character.image_path:
		character_image.texture = load(character.image_path)
	else:
		character_image.visible = false
	handle_use_button()



func handle_use_button():
	if name_label.text in implemented_characters:
		use_button.disabled = false

		var selected_character = SaveGame.get_selected_character()
		if character_id == selected_character:
			use_button.text = "Selected"
			use_button.add_theme_color_override("font_color", Color(0.14902, 0.168627, 0.266667, 1))
			use_button.add_theme_stylebox_override("normal", create_yellow_stylebox())
			use_button.add_theme_stylebox_override("hover", create_yellow_stylebox())
			use_button.add_theme_stylebox_override("pressed", create_yellow_stylebox())
		else:
			use_button.text = "Use"
			use_button.remove_theme_color_override("font_color")
			use_button.remove_theme_stylebox_override("normal")
			use_button.remove_theme_stylebox_override("hover")
			use_button.remove_theme_stylebox_override("pressed")


func create_yellow_stylebox() -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.996078, 0.905882, 0.380392, 1)
	stylebox.border_width_left = 2
	stylebox.border_width_top = 2
	stylebox.border_width_right = 2
	stylebox.border_width_bottom = 2
	stylebox.border_color = Color(0.14902, 0.168627, 0.266667, 1)
	stylebox.corner_radius_top_left = 4
	stylebox.corner_radius_top_right = 4
	stylebox.corner_radius_bottom_right = 4
	stylebox.corner_radius_bottom_left = 4
	return stylebox


func on_use_button_pressed():
	if not character_id: return
	GameEvents.emit_character_selected(character_id)
	handle_use_button()
