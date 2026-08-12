extends Node

@export var active: bool = true
@export var items: Array[Item]
var party: Array[Character]
@export var snails: int = 0
var remembered: Array[String]

var in_battle = false
var bs: BattleSystem

var true_name = ""

var facing = "f"

var entering := -1
var player: CharacterBody2D = null

const MAX_ITEMS := 9

func _ready():
	get_window().size = Vector2i(800, 600)
	# For debugging
	for path in ["declan", "partyboy", "pucky", "kagu"]:
		Global.party.append(Character.enemy_factory(get_tree(), load("res://enemies/" + path + ".tres")))

func add_exp(exp: int):
	if exp == 1:
		await DialogueBox.type("> You got " + str(exp) + " experience point.")
	else:
		await DialogueBox.type("> You got " + str(exp) + " experience points.")

	for member in party:
		if member.ailment != Character.Ailments.KO:
			member.xp += exp

		var new_level = floor(pow(member.xp / 10.0, 0.87)) + 1

		if new_level > member.lv:
			await member.level_up_verbose(new_level)
