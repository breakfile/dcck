extends Control

func _ready() -> void:
	Global.active = true
	Global.entering = -1
	Global.snails = 0
	Global.items = []
	Global.party = []
	Global.remembered = []
	for path in ["declan", "partyboy", "pucky", "kagu"]:
		Global.party.append(Character.enemy_factory(get_tree(), load("res://enemies/" + path + ".tres")))
	Floor.visible = false
	$TabContainer/TextureRect/VBoxContainer/Button.grab_focus()


func _on_button_pressed() -> void:
	$TabContainer/Control.visible = true
	%Start.grab_focus()


func _on_start_pressed() -> void:
	await Fader.fade_in()
	Fader.fade_out()
	get_tree().change_scene_to_file("res://globals/naming.tscn")


func _on_back_pressed() -> void:
	$TabContainer/TextureRect.visible = true
	$TabContainer/TextureRect/VBoxContainer/Button.grab_focus()
