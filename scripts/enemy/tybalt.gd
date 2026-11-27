extends EnemyData

func talk(caster: Character, battle_system: BattleSystem):
	await DialogueBox.type("Talking!? Ha... this fight is more of a comedy than a tragedy...")
	await DialogueBox.type("...for YOU!")
	await battle_system._progress()

func ai(enemy: Character, bs: BattleSystem):
	if bs.round == 0:
		await DialogueBox.type("Tybalt: Strike all you want, pathetic Declan and his Declans!")
		await DialogueBox.type("Your brawn shall never match my brain!")
	elif bs.round == 1:
		await DialogueBox.type("Tybalt: Haha! Bet you didn't think I'd still be standing!")
		await DialogueBox.type("You can't match my level, even if you tried!")
	elif bs.round == 3:
		await DialogueBox.type("Tybalt: OK dude I literally have %d health you gotta speed it up" % max_hp)
	elif bs.round == 4:
		await DialogueBox.type("Tybalt: Dam you suck")
		await enemy.weigh_defense(-300)
	await super.ai(enemy, bs)
	
func death(enemy: Character):
	enemy.bs.reward = load("res://items/cure.tres")
