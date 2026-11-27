extends Node

var sf_spawnpos: Vector2
var sf_spawning := false

var dont_play_move_sfx := false

@export var active: bool = true
@export var items: Array[Item]
var party: Array[Character]
@export var snails: int = 0
var remembered: Array
var route_memory: Dictionary
var chase_sequence := false
var time_until_demise := 170
@onready var demise_timer := Timer.new()

var in_battle = false
var bs: BattleSystem

var true_name = ""

func save():
	var save_file = {}
	save_file["items"] = []
	save_file["party"] = []
	save_file["stock"] = []
	
	for item in Global.items:
		save_file["items"].append(item.resource_path)
	save_file["snails"] = snails
	save_file["remembered"] = remembered
	save_file["route_memory"] = route_memory
	save_file["x"] = player.position.x
	save_file["y"] = player.position.y
	save_file["true_name"] = true_name
	for member in Global.party:
		save_file["party"].append(member.get_save_dict())
	for member in Global.stock:
		save_file["stock"].append(member.get_save_dict())
	save_file["room"] = get_tree().current_scene.scene_file_path
	save_file["header"] = get_tree().current_scene.title if get_tree().current_scene is Level else "???"
	
	var file = FileAccess.open("user://dcsave", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file, "	"))

var facing = "f"

var entering := -1
var player: CharacterBody2D = null

const MAX_ITEMS := 9

var stock: Array[Character]

func _ready():
	get_window().size = Vector2i(800, 600)
	
	add_child(demise_timer)
	demise_timer.wait_time = 1
	demise_timer.timeout.connect(func():
		time_until_demise -= 1
		if time_until_demise <= 0:
			GlobalAudioStream.stream = load("res://sfx/explosion.wav")
			GlobalAudioStream.play()
			DialogueBox.verbose = false
			demise_timer.stop()
			DialogueBox.visible = false
			await Fader.fade_whitefade(1)
			time_until_demise = 170
			Fader.fade_out(1)
			get_tree().change_scene_to_file("res://globals/title.tscn")
	)
	
	# For debugging
	for path in ["declan", "partyboy", "pucky", "kagu"]:
		Global.party.append(Character.enemy_factory(get_tree(), load("res://enemies/" + path + ".tres")))

func add_exp(exp: int):
	Global.snails += ceil(exp/2.0)
	
	if exp == 1:
		await DialogueBox.type("> You got " + str(exp) + " experience point and 1sn.")
	else:
		await DialogueBox.type("> You got " + str(exp) + " experience points and " + str(int(ceil(exp/2.0))) + "sn.")

	for member in party:
		if member.ailment != Character.Ailments.KO:
			member.xp += exp

		var new_level = floor(pow(member.xp / 10.0, 0.87)) + 1

		if new_level > member.lv:
			await member.level_up_verbose(new_level)
