extends Node2D

func _ready():
	Floor.visible = false

func _process(delta: float) -> void:
	$RichTextLabel.position.y -= delta*16
	if $RichTextLabel.position.y <= -768:
		get_tree().change_scene_to_file("res://globals/title.tscn")
