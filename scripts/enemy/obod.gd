extends EnemyData

func ai(enemy: Character, battle_system: BattleSystem):
	await super.ai(enemy, battle_system)
	if !battle_system.can_escape:
		battle_system.can_escape = true
		await DialogueBox.type("PARTYBOY: W-what the hell!? Why are you capable of that!?")
		await DialogueBox.type("[color=orange]Please... RUN FOR YOUR LIFE!!!!!!!!!!!![/color]")
		await DialogueBox.type("> Declan chickened out!\n> He can now ESCAPE from battle.")

func talk(caster: Character, battle_system: BattleSystem):
	battle_system.vbox.visible = false
	await DialogueBox.type("[color=orange]Please... you have to run away...[/color]")
	await battle_system._progress()
