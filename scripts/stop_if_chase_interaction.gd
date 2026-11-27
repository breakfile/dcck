extends Interaction

func on_interaction():
	if Global.chase_sequence:
		await DialogueBox.type("> No cheating!")
		get_parent().stop.emit()
