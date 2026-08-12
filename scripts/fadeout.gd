extends CanvasLayer

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color.BLACK, 0.1)
	await tween.finished

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 0.15)
	await tween.finished
