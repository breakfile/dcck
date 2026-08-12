class_name GumItem extends Item

@export var amount := 6
@export var expire := true

func on_use(caster: Character):
	await DialogueBox.type("> Declan took out the gum and everyone started chewing!")
	await Global.add_exp(amount)
	if expire:
		Global.items.remove_at(Global.items.find(self))
