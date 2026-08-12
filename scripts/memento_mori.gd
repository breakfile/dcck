class_name MementoMori extends Node2D

var unique_path := ""
var remember := false

func _ready():
	if get_tree().current_scene is Level:
		var level := get_tree().current_scene as Level
		unique_path = "%s:%s" % [level.title, get_path()]

	if Global.remembered.has(unique_path):
		queue_free()

func destroy_permanently():
	remember = true
	queue_free()

func _exit_tree():
	if remember and not Global.remembered.has(unique_path):
		Global.remembered.append(unique_path)
