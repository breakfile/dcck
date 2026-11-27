extends LinearTweenInteraction

func _process(delta: float) -> void:
	if Global.active == false and tween:
		tween.stop()
