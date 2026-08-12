class_name HealSkill extends Skill

@export var heal_amount := 30
@export var heal_ko: bool = false

func cast(caster: Character):
	await super.cast(caster)
	await caster.target.heal(heal_amount, heal_ko)
