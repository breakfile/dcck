class_name LockInteraction extends Interaction

var key := preload("res://items/key.tres")

func on_interaction():
	if Global.items.has(key):
		await DialogueBox.type("> Declan used the %s on the lock." % key.name)
		Global.items.erase(key)
		if root is MementoMori:
			root.destroy_permanently()
		else:
			root.queue_free()
	else:
		await DialogueBox.type("> Declan doesn't have a key for this lock!!!")
