extends Interaction

func on_interaction():
	DialogueBox.skipping = false
	get_viewport().get_camera_2d().reparent(get_tree().current_scene)
	await DialogueBox.type("> Declan: That was fun, wasn't it, %s?" % [Global.true_name])
	await DialogueBox.type("> Where should we go... next?")
