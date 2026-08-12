extends CanvasLayer

@onready var command_menu := $Command
@onready var item_menu := $Items
@onready var item_grid := $Items/ScrollContainer/GridContainer
@onready var description_textbox := $Control/PanelContainer2/RichTextLabel
@onready var item_settings := $ItemSettings
@onready var item_settings_label := $ItemSettings/VBoxContainer/Label
var stack: Array[StackMenu]

func refresh():
	for panel in stack:
		if panel != stack.back():
			panel.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
		else:
			panel.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
		panel.z_index = stack.find(panel)

func push(pc: StackMenu):
	pc.push.emit()
	stack.push_back(pc)
	pc.visible = true
	refresh()
	pc.focus_last_control()

func pop():
	stack.back().visible = false
	stack.pop_back()
	refresh()
	if not stack.is_empty() and stack.back():
		stack.back().focus_last_control()

func _process(_x):
	if Input.is_action_just_pressed("menu"):
		if stack.size() == 0 and Global.active:
			push(command_menu)
			Global.active = false;
			pass
		elif stack.size() == 1 and stack.back().pop_with_return:
			pop()
			Global.active = true;
	if Input.is_action_just_pressed("ui_cancel"):
		if stack.size() > 0 and stack.back() == command_menu:
			Global.active = true
		if stack.size() > 0 and stack.back().pop_with_return:
			pop()
			
	if stack.size() > 0 or Global.in_battle:
		$Control.visible = true
	else:
		$Control.visible = false

var old_items: Array[Item]
var selected_item: Item = null

func _on_items_push() -> void:
	if Global.items == old_items:
		return
	old_items = Global.items.duplicate()
	
	for child in item_grid.get_children():
		child.free()
	if Global.items.size() > 0:
		item_menu.get_child(1).visible = false
	else:
		item_menu.get_child(1).visible = true
	for item in Global.items:
		var b := Button.new()
		b.text = item.name
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		item_grid.add_child(b)
		
		b.focus_entered.connect(func():
			description_textbox.text = item.desc
		)
		b.focus_exited.connect(func():
			description_textbox.text = ""
		)
		b.pressed.connect(func():
			selected_item = item
			item_settings_label.text = item.name
			push(item_settings)
		)
	item_menu.default_control = item_grid.get_children().front()

func clear():
	for panel in stack:
		pop()

func _on_item_pressed() -> void:
	push(item_menu)


func _on_title_pressed() -> void:
	clear()
	await Fader.fade_in()
	get_tree().change_scene_to_file("res://globals/title.tscn")
	Fader.fade_out()

func _on_exit_pressed() -> void:
	get_tree().quit()
