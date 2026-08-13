class_name KeySandwichItem extends FoodItem

@export_file("*.tres") var chewed_form_path: String

func on_use(caster: Character):
	await super.on_use(caster)
	if Global.party.find(caster.target) == 3:
		await DialogueBox.type("> Inside the sandwich, Kagu found a key!")
		Global.items.append(load("res://items/key.tres"))
	else:
		await DialogueBox.type("> That sandwich was intended for [color=yellow]KAGU[/color] to eat it!")
		await DialogueBox.type("> You spat out the sandwich to try again.\n> It looked yucky")
		Global.items.append(load(chewed_form_path))
