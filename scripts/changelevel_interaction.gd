class_name ChangeLevelInteraction extends Interaction

@export_file("*.tscn") var room: String = "res://rooms/1F.tscn"
@export var sign := 0

func on_interaction():
	await Fader.fade_in()
	
	Global.entering = sign
	get_tree().change_scene_to_file(room)
