class_name StopGlobalSongInteraction extends Interaction


func on_interaction():
	GlobalAudioStream.stop()
