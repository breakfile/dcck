class_name DbgResetItemsSkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	Global.items = []
