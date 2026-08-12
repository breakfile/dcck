class_name DbgFillExpItemsSkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	Global.items = []
	for i in range(0, Global.MAX_ITEMS):
		Global.items.append(load("res://items/6gum.tres"))
