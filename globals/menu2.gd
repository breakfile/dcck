extends CanvasLayer

func new_button(text: String, logic: Callable):
	var b := Button.new()
	b.text = text
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(logic)
	%VBox.add_child(b)
	return b

func _process(delta: float) -> void:
	if Global.active:
		if Input.is_action_just_pressed("menu"):
			$OpenMenu.play()
			Global.active = false
			await Fader.fade_in()
			visible = true
			_create_home()
			Fader.fade_out()
	else:
		if Input.is_action_just_pressed("menu") and visible:
			await _close()

func _close():
	$CloseMenu.play()
	await Fader.fade_in()
	visible = false
	%QuickInfo.visible = true
	Global.active = true
	Fader.fade_out()

func _clear():
	for child in %VBox.get_children():
		child.queue_free()

func _create_home():
	%CurrentInfo.text = "Command?"
	_clear()
	new_button("SKILL", func(): _create_skills()).grab_focus()
	new_button("ITEM",  func(): _create_item())
	new_button("STATS", func(): _create_state())
	new_button("EQUIP", func(): _create_equipment())
	new_button("SETUP", func(): _create_setup())
	
func _create_setup():
	%CurrentInfo.text = "Pick an option."
	_clear()
	new_button("← Back", func(): _create_home()).grab_focus()
	new_button("Return to title", func():
		await _close()
		get_tree().change_scene_to_file("res://globals/title.tscn"))

func _create_equipment():
	%CurrentInfo.text = "Who will you equip on?"
	_clear()
	new_button("← Back", func(): _create_home()).grab_focus()
	for member in Global.party:
		new_button(member.character_name, func():
			_equipping(member)
		)

func _equipping(member: Character):
	%StatsScreen.show_stats(member)
	%CurrentInfo.text = "What equipment?"
	_clear()
	var u = new_button("← Back", func(): %QuickInfo.visible = true; _create_equipment())
	u.grab_focus()
	u.focus_entered.connect(func():
		%StatsScreen.show_stats(member)
	)
	
	var w = new_button("Remove Weapon", func():
		await _close(); Global.active = false
		member.target = member
		await load("res://items/fist.tres").on_use(member)
		Global.active = true)
	w.focus_entered.connect(func():
		%StatsScreen.show_improvements(member, load("res://items/fist.tres"))
	)
	var p = new_button("Remove Protector", func():
		await _close(); Global.active = false
		member.target = member
		await load("res://items/resiliance.tres").on_use(member)
		Global.active = true)
	p.focus_entered.connect(func():
		%StatsScreen.show_improvements(member, load("res://items/resiliance.tres"))
	)
	
	for item in Global.items:
		if item is Equipment:
			var x = new_button(item.name, func():
				await _close(); Global.active = false
				member.target = member
				await item.on_use(member)
				Global.active = true
			)
			x.focus_entered.connect(func():
				%StatsScreen.show_improvements(member, item)
			)

func _create_state():
	%CurrentInfo.text = "Who's statistics will you view?"
	_clear()
	new_button("← Back", func(): _create_home()).grab_focus()
	for member in Global.party:
		new_button(member.character_name, func(): _display_stats(member))

func _create_item():
	if Global.items.size() > 0:
		%CurrentInfo.text = "What item should you use?"
	else:
		%CurrentInfo.text = "You don't appear to have any items."
	_clear()
	new_button("← Back", func(): _create_home()).grab_focus()
	for item in Global.items:
		new_button(item.name, func():
			%CurrentInfo.text = "What will you do with %s?" % item.name
			_clear()
			new_button("← Back", func(): _create_item()).grab_focus()
			new_button("Use", func():
				_get_target_item(_create_item, item)
			)
			new_button("Describe", func(): 
				await _close(); Global.active = false
				await DialogueBox.type(item.desc)
				Global.active = true))

func _create_skills():
	%CurrentInfo.text = "Who's skill will you use?"
	_clear()
	new_button("← Back", func(): _create_home()).grab_focus()
	for member in Global.party:
		new_button(member.character_name, func():
			if member.protection.skills.size() > 0:
				%CurrentInfo.text = "What skill should you use?"
			else:
				%CurrentInfo.text = "You don't have a CEREBRUM equipped..."
			_clear()
			new_button("← Back", func(): _create_skills()).grab_focus()
			for skill in member.protection.skills:
				new_button("%02dMP: %s" % [skill.cost, skill.name], func():
					%CurrentInfo.text = "What will you do with %s?" % skill.name
					_clear()
					new_button("← Back", func(): _create_skills()).grab_focus()
					if skill.cost <= member.mp and skill is HealSkill:
						new_button("Use", func():
							_get_target_skill(_create_skills, skill, member)
							pass
						)
					new_button("Describe", func(): 
						await _close(); Global.active = false
						await DialogueBox.type(skill.desc)
						Global.active = true))
		)

func _get_target_skill(back: Callable, skill: Skill, caster: Character):
	%CurrentInfo.text = "Who will you use it on?"
	_clear()
	new_button("← Back", func(): back.call()).grab_focus()
	for member in Global.party:
		new_button(member.character_name, func():
			await _close()
			Global.active = false
			caster.target = member
			await skill.cast(caster)
			Global.active = true
		)

func _get_target_item(back: Callable, item: Item):
	%CurrentInfo.text = "Who will you use it on?"
	_clear()
	new_button("← Back", func(): back.call()).grab_focus()
	for member in Global.party:
		new_button(member.character_name, func():
			await _close()
			Global.active = false
			member.target = member
			await item.on_use(member)
			Global.active = true
		)

func _display_stats(member: Character):
	%CurrentInfo.text = "Viewing %s's statistics." % member.character_name
	_clear()
	new_button("← Back", func():
		_create_state()
		%StatsScreen.visible = false
	).grab_focus()
	%StatsScreen.show_stats(member)
