extends Interaction


func on_interaction():
	await Fader.fade_whitefade(5)
