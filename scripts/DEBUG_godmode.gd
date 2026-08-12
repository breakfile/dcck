class_name DbgGodModeSkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	await caster.level_up_verbose(100000) # Should clamp to 99
	caster.fire_mult = 0
	caster.freeze_mult = 0
	caster.phys_mult = 0
	
