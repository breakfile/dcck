extends EnemyData

var lowered = false

func ai(enemy: Character, bs: BattleSystem):
	if bs.round == 0:
		await DialogueBox.type("Bus: The CEREBRUM is mine for the taking!")
	if bs.round == 1:
		await DialogueBox.type("Bus: When I take over this cruel world...")
		await DialogueBox.type("Bus: I'll rule it with CHAOS!")
	if bs.round == 2:
		await DialogueBox.type("Bus: All I need is THE CEREBRUM OF WARMTH...")
		await DialogueBox.type("Bus: THE CEREBRUM OF THE COLD...")
		await DialogueBox.type("Bus: THE CEREBRUM OF RECOVERY...")
		await DialogueBox.type("Bus: THE CEREBRUM OF STRENGTH...")
		await DialogueBox.type("Bus: And, at last... THE CEREBRUM OF SOVEREIGNTY!")
	if enemy.hp < (enemy.max_hp/4) and !lowered:
		await DialogueBox.type("Bus: GRRR!")
		await DialogueBox.type("Bus: Why do you hate everything I do!?")
		await DialogueBox.type("Bus: WHY DO YOU HATE ME!?")
		await DialogueBox.type("Bus: WHAT IS IT THAT IS SO MUCH BETTER ABOUT TRAINS!?")
		await DialogueBox.type("> The Bus is still holding on.\n> The Bus is focusing on preserving it's life...")
		await DialogueBox.type("> Skillset changed!\n> Resistances changed!")
		DialogueBox.verbose = false
		var u = load("res://items/resiliance.tres") as Equipment
		enemy.target = enemy
		u.on_use(enemy)
		DialogueBox.verbose = true
		enemy.ai_skills = [load("res://skills/preservation.tres")]
		lowered = true
	await super.ai(enemy, bs)
