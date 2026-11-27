extends DeleteRootInteraction

@export_file("*.tscn") var room: String
@export var sign := 0

func on_interaction():
	root.remember = true
	await Fader.fade_in()
	
	Global.entering = sign
	get_tree().change_scene_to_file(room)
