class_name SpawnMarker extends Marker2D

@export var sign: int

func _ready():
	if Global.player and Global.entering == sign:
		Global.player.global_position = global_position
