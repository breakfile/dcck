class_name CheckSkill extends Skill

func _turn_into_percent(input: float):
	return (input/1)*100

func cast(caster: Character):
	await DialogueBox.type("> %s queried %s." % [caster.character_name, caster.target.character_name])
	await DialogueBox.type("\"" + caster.target.desc + "\"")
	await DialogueBox.type("> %d Attack.\n> %d Defense.\n> %d max HP with %d max MP." % [caster.target.at+caster.target.weapon.attack_increase+caster.target.protection.attack_increase, caster.target.df+caster.target.weapon.defense_increase+caster.target.protection.defense_increase, caster.target.max_hp, caster.target.max_mp])
	await DialogueBox.type("> %d%% damage intake from fire.\n> %d%% damage intake from ice.\n> %d%% damage intake from physical." % [
		_turn_into_percent(caster.target.fire_mult),
		_turn_into_percent(caster.target.freeze_mult),
		_turn_into_percent(caster.target.phys_mult)
	])
