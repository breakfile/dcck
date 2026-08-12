class_name DbgClearFreeMemorySkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	Global.remembered = []
