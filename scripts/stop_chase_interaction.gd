extends Interaction

func on_interaction():
	Global.chase_sequence = false
	Global.time_until_demise = 170
	Global.demise_timer.stop()
