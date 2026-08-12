extends RigidBody2D

@export var text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = text
	for i in $Border.get_children():
		i.text = text
	apply_impulse(Vector2(100, -250))
	await get_tree().create_timer(2).timeout
	queue_free()
