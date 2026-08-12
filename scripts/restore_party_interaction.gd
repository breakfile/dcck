class_name RestorePartyInteraction extends Interaction

func on_interaction():
	for member in Global.party:
		member.hp = member.max_hp
		member.mp = member.max_mp
		member.ailment = Character.Ailments.NORMAL
