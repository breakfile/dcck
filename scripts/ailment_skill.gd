class_name AilmentSkill extends Skill


@export var ailment: Character.Ailments
@export var one_in_x_chance: int = 3

func cast(caster: Character):
	await super.cast(caster)
	
	if randi() % one_in_x_chance == 0:
		match ailment:
			Character.Ailments.POISON:
				if caster.target.sprite:
					var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
					hit_number.text = "Poisoned"
					hit_number.modulate = Color(0, 1, 0)
					caster.target.sprite.add_child(hit_number)
				caster.target.ailment = ailment
				await DialogueBox.type("> %s was poisoned!" % caster.target.character_name)
			Character.Ailments.CONFUSION:
				if caster.target.sprite:
					var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
					hit_number.text = "Confused"
					hit_number.modulate = Color(1, 0.5, 0)
					caster.target.sprite.add_child(hit_number)
				caster.target.ailment = ailment
				await DialogueBox.type("> %s is confused! Can no longer use skills!" % caster.target.character_name)
	else:
		if caster.target.sprite:
			var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
			hit_number.text = "Miss"
			caster.target.sprite.add_child(hit_number)
		await DialogueBox.type("> %s was uneffected.\n> It was futile." % caster.target.character_name)
