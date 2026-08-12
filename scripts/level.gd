class_name Level extends Node2D

@export var title: String
@export var music: AudioStream

func _ready():
	if music:
		if GlobalAudioStream.stream != music or !GlobalAudioStream.playing:
			GlobalAudioStream.stream = music
			GlobalAudioStream.play()
	else:
		GlobalAudioStream.stop()
