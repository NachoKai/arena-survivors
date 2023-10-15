extends CanvasLayer

var options_menu_scene = preload("res://scenes/ui/options_menu.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel_container: PanelContainer = %PanelContainer
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var menu_button: Button = %MenuButton
var is_closing: bool


func _ready():
	get_tree().paused = true
	resume_button.pressed.connect(on_resume_pressed)
	options_button.pressed.connect(on_options_pressed)
	menu_button.pressed.connect(on_menu_pressed)
	panel_container.pivot_offset = panel_container.size / 2
	animation_player.play("default")
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()


func close():
	if is_closing: return
	is_closing = true
	animation_player.play_backwards("default")
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween.finished
	get_tree().paused = false
	queue_free()


func on_resume_pressed():
	close()


func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	var options_menu_instance = options_menu_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))


func on_menu_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func on_options_back_pressed(options_menu: Node):
	options_menu.queue_free()
