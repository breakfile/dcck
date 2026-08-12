extends AudioStreamPlayer

func fade_in():
	volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(GlobalAudioStream, "volume_db", 0.0, 0.4)
