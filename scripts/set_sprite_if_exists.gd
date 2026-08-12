extends Sprite2D

@export var object: Node
@export var sprite: Texture

func _process(_x):
	if not object:
		texture = sprite
