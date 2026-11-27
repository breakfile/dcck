extends TileMapLayer

func _process(x):
	visible = false
	
	for member in Global.party:
		if member.ailment == Character.Ailments.GLOWING:
			visible = true
