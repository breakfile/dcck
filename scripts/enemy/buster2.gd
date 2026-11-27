extends EnemyData

func talk(caster: Character, bs: BattleSystem):
	MenuManager.clear(false)
	MenuManager.say_label.text = "Attitude?"
	MenuManager.push(MenuManager.say)
	
	new_button("Friendly", func():
		MenuManager.clear(false)
		await DialogueBox.type("TIME TO BE FRIENDLY? AS IF.")
		MenuManager.say_label.text = "Say?"
		MenuManager.push(MenuManager.say)
		new_button("\"Prodigious\"", func():
			MenuManager.clear(false)
			await DialogueBox.type("> Declan couldn't resist saying it with the force of a thousand suns!!")
			await DialogueBox.type("YOU ENTHUSIASM IS INCREDIBLE.")
			await DialogueBox.type("YET ANOTHER PRODIGIOUS FAN! WE'LL BE FRIENDS FOREVER!")
			bs.earned += 2
			await bs._stop()
		).grab_focus()
		new_button("\"You are awesome\"", func():
			MenuManager.clear(false)
			await DialogueBox.type("YOUR ENTHUSIASM PARTIALLY PIERCES MY SOUL")
			await caster.target.hurt(1, Character.AttackType.FIRE)
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
				await DialogueBox.type("NONE OF YOU ARE UNWELL.")
				await bs._progress()
			else:
				if Global.snails >= 5:
					await DialogueBox.type("YOU'VE BEEN HEALED. YOU'LL BE CHARGED 5sn FOR THIS TRANSACTION")
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
			await DialogueBox.type("warning: division by zero is undefined [-Wdivision-by-zero]")
			DialogueBox.skipping = true
			await caster.target.hurt(caster.target.hp/2)
			await bs._progress()
		)
	).grab_focus()
	
	new_button("Demanding", func(): 
		MenuManager.clear(false)
		await DialogueBox.type("WOW. RUDE.")
		await bs._progress()
	)
