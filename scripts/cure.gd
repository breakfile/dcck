class_name CureSkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	if caster.target.ailment == Character.Ailments.NORMAL:
		await DialogueBox.type("> But nothing was wrong with %s.\n> It was futile." % [caster.target.character_name])
	elif caster.target.ailment == Character.Ailments.KO:
		await DialogueBox.type("> But it didn't revive %s.\n> It was futile." % [caster.target.character_name])
	else:
		await DialogueBox.type("> %s was revived!" % [caster.target.character_name])
		caster.target.ailment = Character.Ailments.NORMAL
