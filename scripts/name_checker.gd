extends Area2D

func _process(_x):
	if Global.active == true:
		$Alert.modulate.r = 1
	else:
		$Alert.modulate.r = 0
	
	$Alert.visible = false
	if get_tree().current_scene is Level:
		Floor.get_node("PanelContainer/Label").text = get_tree().current_scene.title
	else:
		Floor.get_node("PanelContainer/Label").text = "Nothing"
	for body in get_overlapping_areas():
		if body is InteractionLauncher:
			if body.require_input:
				$Alert.visible = true
				Floor.get_node("PanelContainer/Label").text = body.label
