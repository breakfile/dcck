
extends Node

@export var deny_sfx: AudioStream
@export var move_sfx: AudioStream

@export var menu: Control
@export var menu_first: Button
@export var stats: Control
@export var stats_first: TabContainer

var selected_item: Item = null

func _close_all():
	Global.active = true

	# Changed: Use a loop instead of repeating the same code for every panel.
	for panel in [menu, stats]:
		panel.visible = false
		panel.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED

var last_focus: Control

func _process(_delta: float) -> void:
	
	
	if Input.is_action_just_pressed("menu"):
		if Global.active:
			menu.visible = true
			menu_first.grab_focus()
			Global.active = false
		elif menu.visible and menu.focus_behavior_recursive != Control.FOCUS_BEHAVIOR_DISABLED:
			# Changed: Replaced nested if with elif since only one branch can run.
			_close_all()

	# Changed: Handle ui_cancel once instead of checking it separately for each menu.
	if Input.is_action_just_pressed("ui_cancel"):
		if stats.visible and stats.focus_behavior_recursive != Control.FOCUS_BEHAVIOR_DISABLED:
			menu.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
			menu_first.grab_focus()
			stats.visible = false


func _on_help_pressed() -> void:
	_close_all()
	Global.active = false
	await DialogueBox.type(selected_item.desc)
	Global.active = true


func _on_toss_pressed() -> void:
	_close_all()
	Global.active = false

	# Changed: Flipped the condition to reduce nesting.
	if selected_item.cannot_toss:
		await DialogueBox.type("> Don't throw away " + selected_item.name + ".")
	else:
		await DialogueBox.type("> Declan threw away " + selected_item.name + ".")
		Global.items.remove_at(Global.items.find(selected_item))

	Global.active = true


func _on_stats_pressed() -> void:
	menu.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

	for child in stats_first.get_children():
		child.free()
		
	var all_tab := RichTextLabel.new()
	all_tab.name = "All"
	all_tab.bbcode_enabled = true
	all_tab.text = "[center]← [color=yellow]Shared for all Members[/color] →[/center]"
	all_tab.text += "\n[hr]\nMoney: %d snails (sn)" % Global.snails
	all_tab.text += "\nItems: %d/%d" % [Global.items.size(), Global.MAX_ITEMS]

	all_tab.text += "\n\n[center]Press ← or → to view specific members.[/center]"
	stats_first.add_child(all_tab)

	for member in Global.party:
		var tab := RichTextLabel.new()
		tab.name = member.character_name
		tab.bbcode_enabled = true

		# Changed: Switched to % formatting to make the text construction easier to read.
		tab.text = "[center]← [color=yellow]%s[/color] →[/center]" % member.desc
		tab.text += "\n[hr]\nLvl %d" % member.lv
		match member.ailment:
			Character.Ailments.NORMAL:
				tab.text += "\nExp %d" % member.xp
			Character.Ailments.KO:
				tab.text += "\n[img]res://sprites/ailment/ko.png[/img][color=red]Unconscious[/color]"
			Character.Ailments.POISON:
				tab.text += "\n[img]res://sprites/ailment/poison.png[/img][color=green]Poisoned[/color]"
		tab.text += "\nHP  %d/%d" % [member.hp, member.max_hp]
		tab.text += "\nAtk %d[color=darkgray][color=orange]%+d[/color][color=#008deb]%+d[/color]=[/color][color=yellow]%d[/color]" % [member.at, member.weapon.attack_increase, member.protection.attack_increase, member.at+member.weapon.attack_increase+member.protection.attack_increase]
		tab.text += "\nDef %d[color=darkgray][color=orange]%+d[/color][color=#008deb]%+d[/color]=[/color][color=yellow]%d[/color]" % [member.df, member.weapon.defense_increase, member.protection.defense_increase, member.df+member.weapon.defense_increase+member.protection.defense_increase]
		tab.text += "\n[right]%d%% damage intake | [img]res://sprites/fire.png[/img] [color=red]FIRE[/color]" % ((member.fire_mult/1)*100)
		tab.text += "\n%d%% damage intake | [img]res://sprites/ice.png[/img]  [color=aqua]ICE[/color]" % ((member.freeze_mult/1)*100)
		tab.text += "\n%d%% damage intake | [img]res://sprites/phys.png[/img] [color=yellow]PHYS[/color]" % ((member.phys_mult/1)*100)
		tab.text += "\n%d exp. until next level." % ((10 * member.lv) - member.xp)

		stats_first.add_child(tab)

	stats.visible = true
	stats_first.get_tab_bar().grab_focus()


func _on_equipment_pressed() -> void:
	menu.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	for child in stats_first.get_children():
		child.free()
	
	for member in Global.party:
		var tab := VBoxContainer.new()
		tab.name = member.character_name
		
		var info := RichTextLabel.new()
		info.bbcode_enabled = true
		info.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Changed: Switched to % formatting to make the text construction easier to read.
		info.text = "[center]← [color=yellow]%s[/color] →[/center]" % member.desc
		info.text += "\n[hr]\n"
		info.text += "[color=orange]Weapon[/color]: %s\n" % member.weapon.name
		info.text += "[color=darkgray]    %+03d At\n" % member.weapon.attack_increase
		info.text += "    %+03d Df\n" % member.weapon.defense_increase
		info.text += "[/color][color=#008deb]Protection[/color]: %s\n" % member.protection.name
		info.text += "[color=darkgray]    %+03d At\n" % member.protection.attack_increase
		info.text += "    %+03d Df\n" % member.protection.defense_increase
		#info.text += "[/color][center]Equip items in [color=yellow]ITEM[/color] menu.[/center]"

		tab.add_child(info)
		
		tab.add_child(HSeparator.new())
		
		var options = HBoxContainer.new()
		tab.add_child(options)
		
		var uweapon = Button.new()
		uweapon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		uweapon.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		uweapon.text = "Remove W."
		uweapon.pressed.connect(func():
			if Global.items.size() >= Global.MAX_ITEMS:
				play_sfx(deny_sfx)
				return
			
			if member.weapon.name != "Fist":
				_close_all()
				Global.active = false
				Global.items.append(member.weapon)
				await DialogueBox.type("> " + member.character_name + " removed " + member.weapon.name + ".")
				member.weapon = Equipment.new()
				member.weapon.name = "Fist"
				Global.active = true
			else:
				play_sfx(deny_sfx)
		)
		options.add_child(uweapon)
		
		var vsep = VSeparator.new()
		options.add_child(vsep)
		
		var uprotect = Button.new()
		uprotect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		uprotect.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		uprotect.text = "Remove P."
		uprotect.pressed.connect(func():
			if Global.items.size() >= Global.MAX_ITEMS:
				play_sfx(deny_sfx)
				return
			
			if member.protection.name != "Resiliance":
				_close_all()
				Global.active = false
				Global.items.append(member.protection)
				await DialogueBox.type("> " + member.character_name + " removed " + member.protection.name + ".")
				member.protection = Equipment.new()
				member.protection.name = "Resiliance"
				member.phys_mult = member.default_phys_mult
				member.freeze_mult = member.default_freeze_mult
				member.fire_mult = member.default_fire_mult
				Global.active = true
			else:
				play_sfx(deny_sfx)
		)
		options.add_child(uprotect)
		
		stats_first.add_child(tab)
	
	stats.visible = true
	stats_first.get_tab_bar().grab_focus()


func _on_heart_pressed() -> void:
	menu.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	for child in stats_first.get_children():
		child.free()
	
	for member in Global.party:
		if member.protection.skills.is_empty():
			var tab := RichTextLabel.new()
			tab.name = member.character_name
			tab.bbcode_enabled = true
			tab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tab.text = "No [color=#008deb]Cerebrum[/color]-type Protection equipped!"
			stats_first.add_child(tab)
		else:
			var tab := VBoxContainer.new()
			tab.name = member.character_name
			
			var l := Label.new()
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.text = "- " + member.protection.aura_name + " -\n" + str(member.mp) + "/" + str(member.max_mp) + " MP"
			tab.add_child(l)
			
			tab.add_child(HSeparator.new())
			
			var h := HBoxContainer.new()
			h.size_flags_vertical = Control.SIZE_EXPAND_FILL
			
			var rtl := RichTextLabel.new()
			rtl.bbcode_enabled = true
			rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rtl.modulate = Color.DARK_GRAY
			rtl.text = ""
			
			var scroller := ScrollContainer.new()
			scroller.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scroller.follow_focus = true
			scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
			scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
			
			var v := VBoxContainer.new()
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			for skill in member.protection.skills:
				var b := Button.new()
				b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b.text = skill.name
				b.focus_entered.connect(func():
					rtl.text = skill.desc)
				b.focus_exited.connect(func():
					rtl.text = "")
				b.pressed.connect(func():
					if member.mp < skill.cost:
						play_sfx(deny_sfx)
						return
					
					_close_all()
					Global.active = false
					member.target = Global.party[0]
					await skill.cast(member)
					Global.active = true)
				v.add_child(b)
				
			scroller.add_child(v)
			h.add_child(scroller)
			h.add_child(VSeparator.new())
			h.add_child(rtl)
			tab.add_child(h)
			stats_first.add_child(tab)
	
	stats.visible = true
	stats_first.get_tab_bar().grab_focus()


func play_sfx(stream: AudioStream):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	add_child(asp)
	asp.play()
	return

func _on_item_pressed() -> void:
	menu.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	for child in stats_first.get_children():
		child.free()
	
	for member in Global.party:
		if Global.items.is_empty():
			var tab := RichTextLabel.new()
			tab.name = member.character_name
			tab.bbcode_enabled = true
			tab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tab.text = "You have no items!!"
			stats_first.add_child(tab)
		else:
			var tab := HBoxContainer.new()
			tab.name = member.character_name
			var rtl := RichTextLabel.new()
			rtl.bbcode_enabled = true
			rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rtl.modulate = Color.DARK_GRAY
			rtl.text = "[center]← →\nChange target"
			
			
			
			var v := VBoxContainer.new()
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			for item in Global.items:
				var b := Button.new()
				b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b.text = item.name
				b.focus_entered.connect(func():
					rtl.text = item.desc)
				b.focus_exited.connect(func():
					rtl.text = "[center]← →\nChange target")
				b.pressed.connect(func():
					if not (item is FoodItem or item is Equipment or item is GumItem):
						play_sfx(deny_sfx)
						return
					
					_close_all()
					Global.active = false
					member.target = member
					await item.on_use(member)
					Global.active = true)
				v.add_child(b)
			tab.add_child(v)
			tab.add_child(VSeparator.new())
			tab.add_child(rtl)
			stats_first.add_child(tab)
			
	# Toss
	if Global.items.is_empty():
			var tab := RichTextLabel.new()
			tab.name = "Bin"
			tab.bbcode_enabled = true
			tab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tab.text = "No items to throw out!!"
			stats_first.add_child(tab)
	else:
			var tab := HBoxContainer.new()
			tab.name = "Bin"
			var rtl := RichTextLabel.new()
			rtl.bbcode_enabled = true
			rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			rtl.modulate = Color.DARK_GRAY
			rtl.text = "[center]← →\n[color=red]DELETE MODE!!![/color]"
			
			
			
			var v := VBoxContainer.new()
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			for item in Global.items:
				var b := Button.new()
				b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b.text = item.name
				b.focus_entered.connect(func():
					if item.cannot_toss:
						rtl.text = "[color=red]Can't[/color] bin the " + item.name + ".\n[hr]\n" + item.desc
					else:
						rtl.text = "Throw away the " + item.name + "?\n[hr]\n" + item.desc)
				b.focus_exited.connect(func():
					rtl.text = "[center]← →\n[color=red]DELETE MODE!!![/color]")
				b.pressed.connect(func():
					# Changed: Flipped the condition to reduce nesting.
					if item.cannot_toss:
						play_sfx(deny_sfx)
						return
					else:
						_close_all()
						Global.active = false
						await DialogueBox.type("> Declan threw away " + item.name + ".")
						Global.items.remove_at(Global.items.find(item))
						Global.active = true)
				v.add_child(b)
			tab.add_child(v)
			tab.add_child(VSeparator.new())
			tab.add_child(rtl)
			stats_first.add_child(tab)
	
	stats.visible = true
	stats_first.get_tab_bar().grab_focus()
