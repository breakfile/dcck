class_name LinearTweenInteraction extends Interaction

@export var node: Node
@export var property: String
@export var new_value: Variant
@export var time: float
var tween: Tween

func on_interaction():
	tween = create_tween()
	tween.tween_property(node, property, new_value, time)
	await tween.finished
