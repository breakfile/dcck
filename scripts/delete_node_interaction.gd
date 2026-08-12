class_name DeleteNodeInteraction extends Interaction

@export var delete_permanently := true
@export var node: Node

func on_interaction():
	if node:
		if node is MementoMori and delete_permanently:
			node.destroy_permanently()
		else:
			node.free()
