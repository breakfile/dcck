class_name Skill extends Resource

@export var name: String
@export_multiline var desc: String
@export var one_line_desc: String
@export var cost: int = 0

@export var effect: PackedScene = preload("res://fx/slash.tscn")
@export var wait_for_animation_to_finish := false

func play_effect(target: Character):
		if target.sprite:
			var slash = effect.instantiate() as AnimatedSprite2D
			target.sprite.add_child(slash)
			if wait_for_animation_to_finish: await slash.animation_finished

func cast(caster: Character):
	if caster not in Global.party:
		await DialogueBox.type("> " + caster.character_name + " used " + name + "!")
	caster.mp = max(caster.mp - cost, 0)
	if effect:
		await play_effect(caster.target)
