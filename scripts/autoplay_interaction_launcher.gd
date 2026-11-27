class_name AutoPlayInteractionLauncher extends InteractionLauncher

func _ready():
	Global.active = false
	
	if routes.size() <= 0: routes.append(self)
	
	for child in routes[route].get_children():
				if _stopped:
					break

				if child:
					if child is Interaction:
						if root:
							child.root = root
						if child.wait:
							await child.on_interaction()
						else:
							child.on_interaction()
	
	Global.active = true
	
