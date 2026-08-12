class_name WaitForTimerInteraction extends Interaction

@export var wait_time: float

func on_interaction():
	await get_tree().create_timer(wait_time).timeout
