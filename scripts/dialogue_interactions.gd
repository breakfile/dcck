class_name DialogueInteraction extends Interaction

@export_multiline var dialogues: Array[String]
@export var disable_skipping := false

func on_interaction():
	DialogueBox.skipping = !disable_skipping
	for dialogue in dialogues:
		await DialogueBox.type(dialogue)
	DialogueBox.skipping = true
	return
