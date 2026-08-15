class_name StackMenu extends PanelContainer

@export var default_control: Control
@export var pop_with_return: bool = true
var last_control: Control

signal push

func _ready():
	last_control = default_control
	_connect_focus_signals(self)

func _process(_x):
	_connect_focus_signals(self)
	pass

func _connect_focus_signals(node: Node):
	for child in node.get_children():
		if child is Control:
			if not child.focus_entered.is_connected(_on_child_focus_entered.bind(child)):
				child.focus_entered.connect(_on_child_focus_entered.bind(child))
		# recurse in case controls are nested inside other containers
		_connect_focus_signals(child)

func _on_child_focus_entered(control: Control):
	last_control = control

@export var always_default_control := false

func focus_last_control():
	if last_control and last_control.visible and !always_default_control:
		last_control.grab_focus()
	elif default_control:
		default_control.grab_focus()
