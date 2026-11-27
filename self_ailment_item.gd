class_name SelfAilmentItem extends Item

@export var ailment: Character.Ailments

func on_use(caster: Character):
	if caster.target.ailment == caster.Ailments.KO:
		await DialogueBox.type("> It was futile.")
		return
	
	caster.target.ailment = ailment
	match ailment:
		Character.Ailments.GLOWING:
			await DialogueBox.type("> %s began glowing blue violently!" % caster.target.character_name)
		Character.Ailments.FLOATING:
			await DialogueBox.type("> %s began levitating...?" % caster.target.character_name)

	Global.items.erase(self)
