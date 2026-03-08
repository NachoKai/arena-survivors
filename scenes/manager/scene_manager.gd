extends Node

signal scene_loading_started(scene_path: String)
signal scene_loaded()

var current_scene_path: String = ""

func change_scene(scene_path: String) -> void:
	scene_loading_started.emit(scene_path)
	
	if ScreenTransition:
		ScreenTransition.transition()
		await ScreenTransition.transition_halfway
		
	get_tree().change_scene_to_file(scene_path)
	current_scene_path = scene_path
	
	scene_loaded.emit()
