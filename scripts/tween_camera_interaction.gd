class_name TweenCameraInteraction extends Interaction

var camera: Camera2D
@export var property: String
@export var new_value: Variant
@export var time: float
var tween: Tween

func on_interaction():
	camera = get_viewport().get_camera_2d()
	tween = create_tween()
	tween.tween_property(camera, property, new_value, time)
	await tween.finished
