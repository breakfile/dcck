class_name ForceInventorySpaceInteraction extends Interaction

@export var least_free_space := 1
@export_multiline var dialogue := "> Declan is carrying too much to do this."

func on_interaction():
	var current_free_space = Global.MAX_ITEMS - Global.items.size()

	if current_free_space < least_free_space:
		await DialogueBox.type(dialogue)
		var launcher := get_parent() as InteractionLauncher
		launcher.stop.emit()
