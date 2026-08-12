class_name Item extends Resource

@export var name: String
@export var aura_name: String
@export_multiline var desc: String
@export var one_line_desc: String
@export var cannot_toss: bool

func on_use(caster: Character):
	await DialogueBox.type("> The " + name + " doesn't do anything.")
	return
