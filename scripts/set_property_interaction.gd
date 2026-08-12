class_name SetPropertyInteraction extends Interaction

@export var node: Node
@export var property: String
@export var result: Variant

func on_interaction():
	node.set(property, result)
