class_name PlaySoundInteraction extends Interaction

@export var sound: AudioStream

func on_interaction():
	var asp := AudioStreamPlayer.new()
	asp.stream = sound
	add_child(asp)
	asp.play()
	await asp.finished
