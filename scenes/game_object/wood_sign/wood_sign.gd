extends StaticBody2D

@onready var panel_container: PanelContainer = %PanelContainer
@onready var label: Label = %Label
@onready var visible_on_screen_enabler: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var sign_button: Button = $SignButton
@onready var message_button: Button = $MessageButton
@export_multiline var text: String = ""


func _ready():
	sign_button.pressed.connect(on_sign_pressed)
	message_button.pressed.connect(on_message_pressed)
	visible_on_screen_enabler.screen_exited.connect(on_screen_exited)


func show_message(message: String):
	panel_container.visible = true
	message_button.visible = true
	label.text = message
	label.visible = true


func hide_message():
	panel_container.visible = false
	message_button.visible = false


func on_screen_exited():
	hide_message()


func on_sign_pressed():
	if panel_container.visible == true:
		hide_message()
	elif panel_container.visible == false:
		show_message(text)
	else: return

func on_message_pressed():
	if panel_container.visible == true:
		hide_message()
	else: return
