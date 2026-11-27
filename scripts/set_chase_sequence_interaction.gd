extends Interaction

func on_interaction():
	Global.chase_sequence = true
	Global.demise_timer.start()
