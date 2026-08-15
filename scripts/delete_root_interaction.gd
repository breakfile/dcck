class_name DeleteRootInteraction extends Interaction


@export var delete_permanently := true

func on_interaction():
	if root:
		if root is MementoMori and delete_permanently:
			root.destroy_permanently()
		else:
			root.free()
