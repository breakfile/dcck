class_name InteractionLauncher extends Area2D

@export var label: String = "Interaction"
@export var root: Node
@export var require_input: bool = true

@export var routes: Array[Node]
@export var remember_route: bool
var route = 0
var unique_path := ""

signal stop

var _stopped := false

func _ready() -> void:
	if get_tree().current_scene is Level:
		var level := get_tree().current_scene as Level
		unique_path = "%s:%s" % [level.title, get_path()]
	
	if remember_route:
		if Global.route_memory.has(unique_path):
			print(Global.route_memory[unique_path])
			route = Global.route_memory[unique_path]
	
	stop.connect(_on_stop)

func _on_stop() -> void:
	_stopped = true

func _process(_delta: float) -> void:
	if remember_route:
		Global.route_memory[unique_path] = route
	
	if !Global.active:
		return
		
	if routes.size() <= 0: routes.append(self)

	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and (Input.is_action_just_pressed("ui_accept") or !require_input):
			Global.active = false
			_stopped = false

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
