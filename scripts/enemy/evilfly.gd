extends EnemyData

func talk(caster: Character, bs: BattleSystem):
	await DialogueBox.type("Bz bz bz")
	await DialogueBox.type("> The fly is awaiting your response.")
	bs.pop_up("Your plan?")
	
	bs.new_button("Yell", func():
		bs.vbox.visible = false
		await DialogueBox.type("> The fly looked shocked!")
		await caster.target.weigh_defense(-7)
		await bs._progress()
	).grab_focus()
	
	bs.new_button("Beg", func():
		bs.vbox.visible = false
		await DialogueBox.type("> You begged the fly for an apple.")
		await DialogueBox.type("Bz bz bz bz bzzz bz\n(Who do you think I am!? Issac Newton?)")
		await DialogueBox.type("Bzzz bz bz\n(If you can beat me, I'll give ya one.)")
		await caster.target.weigh_attack(6)
		bs.reward = load("res://items/resources/apple.tres")
		await bs._progress()
	)
