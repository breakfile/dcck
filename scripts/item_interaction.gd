class_name ItemInteraction extends Interaction

@export var item: Item

func play_sfx(stream: AudioStream):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	add_child(asp)
	asp.play()
	await asp.finished
	return

func on_interaction():
	play_sfx(load("res://sfx/get.wav"))
	await DialogueBox.type("> Declan found [color=aqua]" + (item.aura_name if not item.aura_name.is_empty() else item.name) + "[/color].")
	Global.items.append(item)
