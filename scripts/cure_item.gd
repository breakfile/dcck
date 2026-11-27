class_name CureItem extends Item

func on_use(caster: Character):
	await DialogueBox.type("> %s tried to consume the %s." % [caster.target.character_name, name])
	if caster.target.ailment == Character.Ailments.NORMAL:
		await DialogueBox.type("> But nothing was wrong with %s.\n> It was futile." % [caster.target.character_name])
	elif caster.target.ailment == Character.Ailments.KO:
		await DialogueBox.type("> But it didn't revive %s.\n> It was futile." % [caster.target.character_name])
	else:
		await DialogueBox.type("> %s was revived!" % [caster.target.character_name])
		caster.target.ailment = Character.Ailments.NORMAL
	
	Global.items.remove_at(Global.items.find(self))
