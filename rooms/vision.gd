extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Floor.get_node("PanelContainer").self_modulate = Color.BLACK
	DialogueBox.get_node("PanelContainer").self_modulate = Color.BLACK

func _process(_x):
	Floor.visible = Global.active

func _exit_tree() -> void:
	Floor.visible = true
	Floor.get_node("PanelContainer").self_modulate = Color.WHITE
	DialogueBox.get_node("PanelContainer").self_modulate = Color.WHITE
