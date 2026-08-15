
class_name BattleSystem extends CanvasLayer

signal finished

var can_escape: bool = true
@onready var bg = %TextureRect
@onready var parallax: Parallax2D = $Parallax2D

@onready var vbox := %VBOX
@onready var label := %Label

var round = 0

var reward: Item = null
var battle_over := false

func pop_up(text):
	_clear()
	vbox.visible = true
	label.text = text

func play_sfx(stream: AudioStream):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	add_child(asp)
	asp.play()
	return

var deny_sfx: AudioStream = preload("res://sfx/deny.wav")
var slain_sfx: AudioStream = preload("res://sfx/slain.wav")
var win_sfx: AudioStream = preload("res://sfx/win.wav")

var enemy_list: Array[EnemyData]

var enemies: Array[Character]

var song: AudioStream

var earned := 0

var advantage := false

func new_button(text: String, logic: Callable):
	var b := Button.new()
	b.text = text
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(logic)
	%VBOX.add_child(b)
	return b

func _clear():
	for child in %VBOX.get_children():
		%VBOX.remove_child(child)
		child.queue_free()

var current_member: Character

func _ready():
	if song:
		$Smt1Encounter.stream = song
		$Smt1Encounter.play()
	
	Fader.fade_out()
	var sprites = [$One, $Two, $Three]
	
	for i in Global.party.size():
		#Global.party[i].sprite = get_node("Player" + str(i))
		#get_node("Player" + str(i)).chara = Global.party[i]
		#get_node("Player" + str(i)).bm = self
		Global.party[i].bs = self

	for i in enemy_list.size():
		var character = Character.enemy_factory(get_tree(), enemy_list[i])
		character.bs = self
		enemies.append(character)

		if i < sprites.size():
			character.sprite = sprites[i]
			sprites[i].texture = character.texture
			sprites[i].visible = true
	
	if !enemies.is_empty():
		await DialogueBox.type("> %s%s drew near!" % [enemies[0].character_name, " and their cohorts" if enemies.size() > 1 else ""])
		if advantage:
			await DialogueBox.type("> Now's your chance for a surprise opening attack!")
	else:
		await DialogueBox.type("> ...Who are you fighting!?")
	%VBOX.visible = true
	
	# find the first non-KO'd party member to start the battle with
	turn_index = 0
	while turn_index < Global.party.size() and Global.party[turn_index].ailment == Character.Ailments.KO:
		turn_index += 1

	if turn_index >= Global.party.size():
		# entire party is KO'd entering battle
		await check_player_deaths()
		return

	current_member = Global.party[turn_index]
	var checked_member = current_member
	await check_for_poison(current_member)
	
	if battle_over:
		return
	if current_member != checked_member or checked_member.ailment == Character.Ailments.KO:
		return
	
	#_create_main(current_member)
	MenuManager.push(MenuManager.battle_command_menu)
		
var turn_index := 0

func _create_main(member: Character):
	%Label.text = "Command?"
	%Label.modulate = Color.WHITE
	_clear()
	var x = new_button("Attack", func(): _create_targets(member, load("res://skills/player_attack.tres"), enemies, _create_main))
	x.icon = load("res://sprites/phys.png")
	x.grab_focus()
	new_button("Skill", func(): _create_skills(member))
	new_button("Item", func(): _create_items(member))
	new_button("Talk", func():
		_create_talk_targets(member))
	new_button("Check", func(): _create_targets(member, load("res://skills/check.tres"), enemies, _create_main))
	new_button("Next", func(): %VBOX.visible = false; await _progress())
	new_button("Escape", func():
		%VBOX.visible = false
		if can_escape:
			await DialogueBox.type("> You ran away...")
			await _stop()
		else:
			await DialogueBox.type("> Can't run from this battle!")
			await _progress())
	

func _create_skills(member: Character):
	if member.protection.skills.is_empty():
		%Label.text = "No CEREBRUM equipped!"
		%Label.modulate = Color.RED
	else:
		%Label.text = "Which skill?"
		
	if member.ailment == member.Ailments.CONFUSION:
		_clear()
		%Label.text = "%s is confused!" % [member.character_name]
		%Label.modulate = Color(1,0,0)
		var b = new_button("← Back", func(): _create_main(member))
		b.grab_focus()
		return
	
	_clear()
	var b = new_button("← Back", func(): _create_main(member))
	b.grab_focus()
	b.focus_entered.connect(func():
		%Label.text = "Which skill?"
		%Label.modulate = Color(1,1,1)
	)
	for skill in member.protection.skills:
		var u = new_button("%02dMP: %s" % [skill.cost, skill.name], func():
			if member.mp < skill.cost:
				play_sfx(deny_sfx)
				%Label.text = "Not enough MP!"
				%Label.modulate = Color.RED
				return
			
			if skill is DamageSkill or skill is AilmentSkill:
				_create_targets(member, skill, enemies, _create_skills)
			elif skill is HealSkill:
				_create_targets(member, skill, Global.party, _create_skills)
			else:
				member.target = member
				%VBOX.visible = false
				await skill.cast(member)
				await _progress())
		u.focus_entered.connect(func():
			%Label.modulate = Color(1,1,0)
			%Label.text = "Cast: " + skill.one_line_desc
		)
		if skill is DamageSkill:
			match skill.attack_type:
				Character.AttackType.FIRE:
					u.icon = load("res://sprites/fire.png")
				Character.AttackType.ICE:
					u.icon = load("res://sprites/ice.png")
				Character.AttackType.PHYS:
					u.icon = load("res://sprites/phys.png")
		elif skill is HealSkill or skill is AilmentSkill:
			u.icon = load("res://sprites/res.png")

func _create_items(member: Character):
	if Global.items.is_empty():
		%Label.text = "No items!"
		%Label.modulate = Color.RED
	else:
		%Label.text = "What item?"
	_clear()
	var b = new_button("← Back", func(): _create_main(member))
	b.grab_focus()
	b.focus_entered.connect(func():
		%Label.modulate = Color(1,1,1)
		%Label.text = "What item?")
	for item in Global.items:
		var x = new_button(item.name, func():
			if item is FoodItem:
				_create_targets(member, item, Global.party, _create_items)
			else:
				member.target = member
				%VBOX.visible = false
				await item.on_use(member)
				await _progress()
		)
		x.focus_entered.connect(func():
			%Label.modulate = Color(1,1,0)
			%Label.text = "Use: " + item.one_line_desc
		)

func _create_talk_targets(member: Character):
	%Label.text = "Talk to whom?"
	%Label.modulate = Color.WHITE
	_clear()

	new_button("← Back", func():
		_create_main(member)
	).grab_focus()

	for target in enemies:
		var b = new_button(target.character_name, func():
			member.target = target
			%VBOX.visible = false
			await target.on_talk.call(member, self)
		)

		b.focus_entered.connect(func():
			if target.sprite:
				target.sprite.modulate = Color(4,4,4)
		)

		b.focus_exited.connect(func():
			if target.sprite:
				target.sprite.modulate = Color(1,1,1)
		)

func _create_targets(member: Character, thing: Variant, list: Array[Character], back: Callable):
	%Label.text = "To whom?"
	%Label.modulate = Color.WHITE
	_clear()
	new_button("← Back", func(): back.call(member)).grab_focus()
	for target in list:
		var b = new_button(target.character_name, func():
			member.target = target
			%VBOX.visible = false
			if thing is Item:
				await thing.on_use(member)
			elif thing is Skill:
				await thing.cast(member)
			await _progress())
		b.focus_entered.connect(func():
			if target.sprite:
				target.sprite.modulate = Color(4, 4, 4))
		b.focus_exited.connect(func():
			if target.sprite:
				target.sprite.modulate = Color(1, 1, 1))

func _stop():
	for member in Global.party:
		member.at_w = 0
		member.df_w = 0
	
	play_sfx(win_sfx)
	await DialogueBox.type("[center]YOU WON![/center]")
	await Global.add_exp(earned)
	if reward:
		await DialogueBox.type("> You found [color=aqua]%s[/color] left over!" % [reward.name])
		if Global.items.size() == Global.MAX_ITEMS:
			await DialogueBox.type("> But, Declan is carrying too much...")
		else:
			Global.items.append(reward.duplicate())
	var tween = create_tween()
	tween.tween_property($Smt1Encounter, "volume_db", -80.0, 0.1)
	await Fader.fade_in()
	Fader.fade_out()
	finished.emit()
	free()

func death_anim(target: Character):
	play_sfx(slain_sfx)
	for i in range(12):
		target.sprite.self_modulate.r -= 0.1
		target.sprite.self_modulate.g -= 0.1
		target.sprite.self_modulate.b -= 0.1
		target.sprite.self_modulate.a -= 0.1
		await target.tree.create_timer(0.1).timeout


func check_player_deaths():
	var fallen = []
	for player in Global.party:
		if player.hp <= 0:
			fallen.append(player)
	if fallen.size() == Global.party.size():
		battle_over = true
		Global.in_battle = false
		await DialogueBox.type("> Declan's party was obliterated.")
		await Fader.fade_in()
		get_tree().change_scene_to_file("res://globals/title.tscn")
		Fader.fade_out()

func check_for_poison(member: Character):
	if member.ailment == Character.Ailments.POISON:
		await DialogueBox.type("> %s felt sick from the poison..." % [member.character_name])
		await member.hurt(10)
		

func handle_death(character: Character):
	if character in enemies:
		if character.hp >= 1:
			return
		death_anim(character)
		await DialogueBox.type("> %s was slain!" % [character.character_name])
		enemies.erase(character)
		earned += character.exp_drop
		if enemies.is_empty():
			await _stop()
	elif character in Global.party:
		if character.ailment == Character.Ailments.KO:
			return
		await DialogueBox.type("> %s took mortal damage!" % character.character_name)
		character.ailment = Character.Ailments.KO
		await check_player_deaths()
		
		if battle_over:
			return
		if current_member == character:
			await _progress()

func _progress():
	turn_index += 1

	while true:
		if turn_index >= Global.party.size():
			turn_index = 0

			if !advantage:
				if get_tree():
					current_member = null
					await get_tree().create_timer(1).timeout

				for enemy in enemies.duplicate():
					if enemy not in enemies:
						continue
					await check_for_poison(enemy)
					if enemy not in enemies:
						continue
					await enemy.ai.call(enemy, self)
			else:
				advantage = false
			round += 1

		if battle_over:
			return

		if Global.party[turn_index].ailment != Character.Ailments.KO:
			break

		turn_index += 1

	current_member = Global.party[turn_index]
	var checked_member = current_member
	await check_for_poison(current_member)

	if battle_over:
		return
	if current_member != checked_member:
		return

	MenuManager.push(MenuManager.battle_command_menu)
	#%VBOX.visible = true
