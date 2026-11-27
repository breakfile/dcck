extends Control

# INFO FOR TOMORROW:
# - Try as hard as possible to finish it
# - Party members are stored in stock, player is completely alone for next section
# - Ensure Declan CAN NOT level up in Catacombs until party joins back

# - Callum joins the party to help you beat the evil spider that chases you
# - Then he asks you to fight him forreal, and he dies.
# - Party joins back
# - Fight a couple LastBusters and Romeos for like 5-ish long floors
#   and overworld music plays in battle
# - Fight Cohen at the top of the Cathedral (probably should be 20F. nice rounded number)
# - Fight Onguk
# ENDING!!! Declan with red eyes walks off-screen
# Credits

# BTW Callum's sprite is fine being 16x32 in battle, you can change this after draft
# but you really need to get the game done hopefully (if not, a demo is fine)


func _ready() -> void:
	Global.active = true
	GlobalAudioStream.stop()
	Global.entering = -1
	Global.snails = 0
	Global.items = []
	Global.party = []
	Global.remembered = []
	Global.in_battle = false
	MenuManager.clear()
	if Global.bs:
		Global.bs._stop()
	Global.chase_sequence = false
	DialogueBox.verbose = true
	Global.demise_timer.stop()
	for path in ["declan", "partyboy", "pucky", "kagu"]:
		Global.party.append(Character.enemy_factory(get_tree(), load("res://enemies/" + path + ".tres")))
	Floor.visible = false
	$TabContainer/TextureRect/VBoxContainer/Button.grab_focus()


func _on_button_pressed() -> void:
	$TabContainer/Control.visible = true
	%Start.grab_focus()


func _on_start_pressed() -> void:
	await Fader.fade_in()
	Fader.fade_out()
	get_tree().change_scene_to_file("res://globals/naming.tscn")


func _on_back_pressed() -> void:
	$TabContainer/TextureRect.visible = true
	$TabContainer/TextureRect/VBoxContainer/Button.grab_focus()

func _on_continue_pressed() -> void:
	if not FileAccess.file_exists("user://dcsave"):
		return

	var file := FileAccess.open("user://dcsave", FileAccess.READ)
	if file == null:
		return

	var fat: String = file.get_as_text()
	var save_data: Variant = JSON.parse_string(fat)

	if save_data == null or not save_data is Dictionary:
		return
	
	Global.party = []
	Global.stock = []
	
	for item in save_data["items"]:
		if item != "":
			Global.items.append(load(item))
	
	for member in save_data["party"]:
		Character.load_file_dict(get_tree(), member)
	
	for member in save_data["stock"]:
		Character.load_file_dict(get_tree(), member, Global.stock)
	
	Global.remembered = save_data["remembered"]
	Global.route_memory = save_data["route_memory"]
	Global.true_name = save_data["true_name"]
	Global.snails = save_data["snails"]
	
	Global.sf_spawning = true
	Global.sf_spawnpos = Vector2(
		save_data["x"],
		save_data["y"]
	)
	
	await Fader.fade_in()
	Fader.fade_out()
	get_tree().change_scene_to_file(save_data["room"])
	Floor.visible = true
	
