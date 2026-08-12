extends Label

func _process(_x):
	text = ""
	if Input.is_key_pressed(KEY_F):
		text += "Debug Item View (" + str(Global.items.size()) + " items):\n"
		for item in Global.items:
			if Input.is_key_pressed(KEY_G):
				text += item.resource_path + "\n"
			else:
				text += item.name + "\n"
		
		text += "\n[G] for paths"
