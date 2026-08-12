class_name SetGlobalSongInteraction extends Interaction

@export var stream: AudioStream

func on_interaction():
	if GlobalAudioStream.stream != stream or !GlobalAudioStream.playing:
			GlobalAudioStream.stream = stream
			GlobalAudioStream.play()
