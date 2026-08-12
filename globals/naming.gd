extends Control

var current = ""
var editing = 1
var is_editing_true = false

const BUTTONS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxy␣"

func _ready():
	GlobalAudioStream.stream = load("res://music/my_own/harry_naming.ogg")
	GlobalAudioStream.play()
	
	current = Global.party[editing].character_name
	for letter in BUTTONS:
		var b = Button.new()
		b.text = letter + " "
		b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		$VBoxContainer/GridContainer.add_child(b)
		b.pressed.connect(func():
			if current.length() < 8:
				if letter == "␣":
					letter = " "
				current += letter
		)
			
	var def = Button.new()
	def.text = "Reset to default"
	def.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	def.alignment = HORIZONTAL_ALIGNMENT_LEFT
	def.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	$VBoxContainer.add_child(def)
	def.pressed.connect(func():
		if !is_editing_true:
			current = Global.party[editing].character_name
		else:
			current = "Harry"
	)
	
	var bck = Button.new()
	bck.text = "Backspace"
	bck.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	bck.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bck.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	$VBoxContainer.add_child(bck)
	bck.pressed.connect(func():
		current = current.erase(current.length()-1)
	)
	
	bck = Button.new()
	bck.text = "End"
	bck.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	bck.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bck.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bck.pressed.connect(func():
		if current.length() == 0: return
		
		if editing != Global.party.size()-1:
			Global.party[editing].character_name = current
			editing += 1
			current = Global.party[editing].character_name
		elif is_editing_true:
			Global.true_name = current
			if current.to_lower() == "harry":
				$VBoxContainer.visible = false
				$PanelContainer.visible = false
				$Editing.visible = false
				$Current.visible = false
				await DialogueBox.type("> HARD MODE ACTIVE")
				Global.party.clear()
				Global.party.append(
					Character.enemy_factory(get_tree(), load("res://enemies/declan.tres"))
				)
				await Fader.fade_in()
				Floor.visible = true
				Fader.fade_out()
				get_tree().change_scene_to_file("res://rooms/outside_cathedral.tscn")
			await Fader.fade_in()
			Floor.visible = true
			Fader.fade_out()
			get_tree().change_scene_to_file("res://rooms/tutorial1.tscn")
		else:
			Global.party[editing].character_name = current
			is_editing_true = true
			current = ""
	)
	$VBoxContainer.add_child(bck)
	bck.grab_focus()
	

func _process(delta: float) -> void:
	if !is_editing_true:
		$Editing.text = "Party member %d name" % [editing]
	else:
		$Editing.text = "YOUR own name"
	$Current.text = '"' + current + '"'
