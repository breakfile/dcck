extends EnemyData

func talk(caster: Character, bs: BattleSystem):
	MenuManager.clear(false)
	MenuManager.say_label.text = "Attitude?"
	MenuManager.push(MenuManager.say)
	
	new_button("Friendly", func():
		MenuManager.clear(false)
		await DialogueBox.type("YOUR FRIENDLINESS DOES NOT PIERCE MY SOUL")
		MenuManager.say_label.text = "Say?"
		MenuManager.push(MenuManager.say)
		new_button("\"Prodigious\"", func():
			MenuManager.clear(false)
			await DialogueBox.type("> Declan couldn't resist saying it with the force of a thousand suns!!")
			await DialogueBox.type("YOUR ENTHUSIASM CONFUSES ME")
			await DialogueBox.type("PLEASE DON'T HURT ME!!!")
			bs.earned += 2
			await bs._stop()
		).grab_focus()
		new_button("\"You are awesome\"", func():
			MenuManager.clear(false)
			await DialogueBox.type("YOUR FRIENDLINESS DOES NOT PIERCE MY SOUL!!! AS I SAID PRIOR")
			await bs._progress()
		)
		new_button("Illness help (5sn)", func():
			MenuManager.clear(false)
			var no_helped = 0
			for member in Global.party:
				if member.ailment != Character.Ailments.KO and member.ailment != Character.Ailments.NORMAL:
					member.ailment = Character.Ailments.NORMAL
					no_helped += 1
					
			if no_helped == 0:
				await DialogueBox.type("NONE OF YOU APPEAR PARTICULARLY UNWELL")
				await bs._progress()
			else:
				if Global.snails >= 5:
					await DialogueBox.type("YOU HAVE BEEN HEALED. YOU WILL BE CHARGED 5sn FOR THIS TRANSACTION")
					Global.snails = max(Global.snails - 5, 0)
					await bs._stop()
				else:
					await DialogueBox.type("> Declan's card declined! Not enough snails!")
					await bs._progress()
		)
		new_button("Input tan(90)", func():
			MenuManager.clear(false)
			await DialogueBox.type("> Declan input 'T-A-N-space-9-0-°' into the keypad.")
			DialogueBox.skipping = false
			await DialogueBox.type("Sure! Here's a simple tutorial on how to calculate tan(90)!")
			await DialogueBox.type("You should know that sin(90) is 1 and cos(90) is 0, so tan(90) is equal to 1/0, which is............................................")
			await DialogueBox.type("This program has performed an illegal operation and will be shut down. If the problem persists contact your program vendor.")
			DialogueBox.skipping = true
			await caster.target.hurt(250, Character.AttackType.FIRE)
			await bs._progress()
		)
	).grab_focus()
	
	new_button("Demanding", func(): 
		MenuManager.clear(false)
		await DialogueBox.type("PLEASE DON'T HURT ME!!!")
		await DialogueBox.type("> Declan demanded a steel ingot!")
		await DialogueBox.type("> Buster scaredly shaked it's head!\n> Defeat it non-violently!")
		await caster.target.weigh_defense(300)
		bs.reward = load("res://items/resources/steel.tres")
		await bs._progress()
	)
