class_name DbgGiveKeySkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	Global.items.append(load("res://items/key.tres"))
