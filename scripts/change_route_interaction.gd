class_name ChangeRouteInteraction extends Interaction

@export var interaction_launcher: InteractionLauncher
@export var route := 0

func on_interaction():
	interaction_launcher.route = route
