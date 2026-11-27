extends CanvasLayer

func fade_in(time = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color.BLACK, time)
	await tween.finished

func fade_whitefade(time = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color.WHITE, time)
	await tween.finished

func fade_out(time = 0.15):
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), time)
	await tween.finished
