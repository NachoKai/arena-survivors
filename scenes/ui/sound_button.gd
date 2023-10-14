extends Button

@onready var random_audio_stream_player_component = $RandomAudioStreamPlayerComponent


func _ready():
	pressed.connect(on_pressed)


func on_pressed():
	random_audio_stream_player_component.play_random()
