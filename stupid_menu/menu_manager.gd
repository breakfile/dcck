extends CanvasLayer

@onready var command_menu := $Command
@onready var item_menu := $Items
@onready var item_grid := $Items/ScrollContainer/GridContainer
@onready var description_textbox := $PlayerStats/PanelContainer2/RichTextLabel
@onready var item_settings := $ItemSettings
@onready var item_settings_label := $ItemSettings/VBoxContainer/Label
@onready var party_vbox := $Party/VBoxContainer/PartyVbox
@onready var party := $Party
@onready var battle_command_menu := $BattleCommand
@onready var say := $Say
@onready var say_label := $Say/VBoxContainer/SayLabel
@onready var say_grid := $Say/VBoxContainer
var stack: Array[StackMenu]

signal end_turn

func refresh():
	for panel in stack:
		if panel != stack.back():
			panel.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
			panel.modulate = Color.DARK_SLATE_GRAY
		else:
			panel.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
			panel.modulate = Color.WHITE
		panel.z_index = stack.find(panel)

func push(pc: StackMenu, playpush = false):
	pc.push.emit()
	stack.push_back(pc)
	pc.visible = true
	refresh()
	pc.focus_last_control()

func pop(times: int = 1):
	for i in times:
		if stack.size() > 0 and stack.back() == command_menu:
			Global.active = true
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
		if stack.size() > 0 and stack.back().pop_with_return and stack.back().focus_behavior_recursive == Control.FOCUS_BEHAVIOR_ENABLED:
			pop()
			
	if stack.size() > 0 or Global.in_battle:
		$PlayerStats.visible = true
	else:
		$PlayerStats.visible = false

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
			if not Global.in_battle:
				item_settings_label.text = item.name
				push(item_settings)
			else:
				if item is FoodItem:
					pvb_ownparty = true
					pvb_onchoice = func(member: Character):
						Global.bs.current_member.target = member
						clear(false)
						await selected_item.on_use(Global.bs.current_member)
						Global.bs._progress()
					push(party)
				else:
					Global.bs.current_member.target = Global.bs.current_member
					clear(false)
					await selected_item.on_use(Global.bs.current_member)
					Global.bs._progress()
		)
	item_menu.default_control = item_grid.get_children().front()

func clear(reactivate_after = true):
	for panel in stack:
		panel.visible = false
	
	stack.clear()
	Global.active = reactivate_after

func stone():
	stack.back().focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func _on_item_pressed() -> void:
	push(item_menu)

func _on_title_pressed() -> void:
	push($QuitConfirm)

@onready var skill := $Skills
@onready var skill_vbox := $Skills/VBoxContainer
var selected_skillcaster: Character

func _on_confirm_title_pressed() -> void:
	await Fader.fade_in()
	clear()
	get_tree().change_scene_to_file("res://globals/title.tscn")
	Fader.fade_out()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_toss_pressed() -> void:
	if selected_item.cannot_toss:
		$Deny.play()
		push($WarnItemToss)
		return
	
	pop()
	stone()
	await DialogueBox.type("> Declan threw away the %s." % [selected_item.name])
	Global.items.erase(selected_item)
	clear(false)
	push(command_menu)
	push(item_menu)


func _on_use_pressed() -> void:
	if selected_item is GumItem:
		pop()
		stone()
		Global.party[0].target = Global.party[0]
		await selected_item.on_use(Global.party[0])
		clear(false)
		push(command_menu)
		push(item_menu)
	elif selected_item is FoodItem or selected_item is Equipment or selected_item is KeySandwichItem:
		pvb_ownparty = true
		pvb_onchoice = func(member: Character):
			pop(2)
			stone()
			Global.party[0].target = member
			await selected_item.on_use(Global.party[0])
			clear(false)
			push(command_menu)
			push(item_menu)
		push(party)
	else:
		$Deny.play()
		push($WarnItemUse)

var pvb_ownparty = true
var pvb_onchoice: Callable

func _on_party_push() -> void:
	for child in party_vbox.get_children():
		child.free()
		
	for member in Global.party if pvb_ownparty else Global.bs.enemies:
		var b = Button.new()
		b.text = member.character_name
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		b.pressed.connect(pvb_onchoice.bind(member))
		party_vbox.add_child(b)
		b.focus_entered.connect(func():
			if member.sprite:
				member.sprite.modulate = Color(4,4,4)
		)
		b.focus_exited.connect(func():
			if member.sprite:
				member.sprite.modulate = Color(1,1,1)
		)
	party.default_control = party_vbox.get_children().front()

var selected_equipper: Character
@onready var strip_what = $StripWhat

func _on_equip_pressed() -> void:
	pvb_ownparty = true
	pvb_onchoice = func(member):
		selected_equipper = member
		push(strip_what)
	push(party)


func _on_r_wep_pressed() -> void:
	if selected_equipper.weapon.name == "---":
		$Deny.play()
	else:
		$Strip.play()
	
	selected_equipper.target = selected_equipper
	DialogueBox.verbose = false
	load("res://items/fist.tres").on_use(selected_equipper)
	DialogueBox.verbose = true
	_on_strip_what_push()


func _on_r_pro_pressed() -> void:
	if selected_equipper.protection.name == "---":
		$Deny.play()
	else:
		$Strip.play()
	
	selected_equipper.target = selected_equipper
	DialogueBox.verbose = false
	load("res://items/resiliance.tres").on_use(selected_equipper)
	DialogueBox.verbose = true
	_on_strip_what_push()


func _on_strip_what_push() -> void:
	$StripWhat/VBoxContainer/RWep.text = selected_equipper.weapon.name
	$StripWhat/VBoxContainer/RPro.text = selected_equipper.protection.name


func _on_fight_pressed() -> void:
	pass # Replace with function body.


func _on_say_push() -> void:
	for child in say_grid.get_children():
		if child is Button:
			child.queue_free()


var current_stat_check: Character
func _on_stats_pressed() -> void:
	pvb_ownparty = true
	pvb_onchoice = func(member: Character):
		current_stat_check = member
		push($Stats)
	push(party)


func _on_stats_push() -> void:
	$Stats/GridContainer/Name.text = current_stat_check.character_name
	$Stats/GridContainer/Lvl.text = str(current_stat_check.lv)
	$Stats/GridContainer/Exp.text = str(current_stat_check.xp)
	$Stats/GridContainer/Atk.text = str(current_stat_check.at) + " (" + str(current_stat_check.weapon.attack_increase + current_stat_check.protection.attack_increase) + ")"
	$Stats/GridContainer/Def.text = str(current_stat_check.df) + " (" + str(current_stat_check.weapon.defense_increase + current_stat_check.protection.defense_increase) + ")"
	$Stats/GridContainer/Fire.text = str(int(current_stat_check.fire_mult*100)) + "%"
	$Stats/GridContainer/Ice.text = str(int(current_stat_check.freeze_mult*100)) + "%"
	$Stats/GridContainer/Phys.text = str(int(current_stat_check.phys_mult*100)) + "%"


func _on_skills_push() -> void:
	for child in skill_vbox.get_children():
		child.queue_free()
