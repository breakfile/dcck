extends Interaction

func on_interaction():
	for member in Global.stock:
		Global.party.append(member)
	Global.stock = []
