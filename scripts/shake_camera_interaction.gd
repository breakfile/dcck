class_name CameraShakeInteraction extends Interaction

@export var shake_strength := 10.0
@export var shake_duration := 0.3

func on_interaction():
	var camera = get_viewport().get_camera_2d()

	if camera:
		await shake_camera(camera)

func shake_camera(camera: Camera2D):
	var original_offset = camera.offset
	var time := 0.0

	while time < shake_duration:
		time += get_process_delta_time()

		camera.offset = original_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		
		if get_tree():
			await get_tree().process_frame

	camera.offset = original_offset
