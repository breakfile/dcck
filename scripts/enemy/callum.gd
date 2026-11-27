extends EnemyData

# TODO: SECOND PHASE
# <10000HP: All MP is restored for all party members, and Callum focuses on brute force physical attacks.
# He says "I just realised, none of you actually block physical attacks!" or something like that.
# Callum's defense and attack also reset,
# (cont.) and he has a new talk command to lower his defense but up his attack.

# TODO: THIRD PHASE
# <200HP: 1v1 against Callum and Declan, all other party members are removed (but their states are remembered)
# Callum now blocks everything except physical.

var phase := 1

func ai(enemy: Character, bs: BattleSystem):
	await super.ai(enemy, bs)
	
	if (enemy.hp <= 10000 and phase == 1):
		phase = 2
		await DialogueBox.type("> Callum checked your party!")
		for character in Global.party:
			enemy.target = character
			await load("res://skills/check.tres").cast(enemy)
		await DialogueBox.type("You know, I just realised something!")
		await DialogueBox.type("None of you actually resist physical attacks.")
		await DialogueBox.type("Well, consider it noted!")
		await DialogueBox.type("Don't worry, I'll still give you a chance!")
		for character in Global.party:
			character.ailment = Character.Ailments.NORMAL
			character.hp = character.max_hp
			character.mp = character.max_mp
			character.at_w = 0
			character.df_w = 0
		await DialogueBox.type("> Your stats reset!")
		await DialogueBox.type("> Callum's stats were restored!\n> Callum's skills changed!\n> Callum's TALK changed!")
		
		enemy.ai_skills = [load("res://skills/attack.tres")]
		
		enemy.at_w = 0
		enemy.df_w = 0
	if (enemy.hp <= 5800 and phase == 2):
		phase = 3
		enemy.at_w = -35
		enemy.df_w = 30000
		enemy.hp = 7
		enemy.fire_mult = 0
		enemy.freeze_mult = 0
		
		await DialogueBox.type("I've had enough games, Declan! No more!")
		await DialogueBox.type("You're stronger than you look, I'll admit that.")
		await DialogueBox.type("I came here with the intention of making you look a fool.")
		await DialogueBox.type("But you can just use your magic. OF COURSE you can just use your magic! You have the Cerebra!")
		await DialogueBox.type("So, no more magic. Just you, and I, punching, and punching, and punching, until one of us gives in! Got it!?")
		
		Global.stock = Global.party.slice(1)
		Global.party = [Global.party[0]]
		
		for character in Global.party:
			character.ailment = Character.Ailments.NORMAL
			character.hp = character.max_hp
			character.mp = character.max_mp
			character.at_w = 0
			character.df_w = 0
		
		await DialogueBox.type("> Your party members left the room... it's just you..")

func talk(caster: Character, bs: BattleSystem):
	MenuManager.clear(false)
	MenuManager.say_label.text = "Do?"
	MenuManager.push(MenuManager.say)
	
	if phase == 1:
		new_button("Mention Lachlan", func():
			MenuManager.clear(false)
			await DialogueBox.type("Callum: ...Lachlan...")
			await caster.target.weigh_defense(-20)
			await bs._progress()
		).grab_focus()
		new_button("Mention \"Him\"", func():
			MenuManager.clear(false)
			await DialogueBox.type("> Callum did not respond.")
			await caster.target.weigh_attack(-40)
			await bs._progress()
		)
		new_button("Punch yourself", func():
			MenuManager.clear(false)
			await DialogueBox.type("> Adrenaline flows through you!")
			await caster.weigh_attack(20)
			await caster.weigh_defense(-10)
			await bs._progress()
		)
	elif phase == 2:
		new_button("Light punch", func():
			MenuManager.clear(false)
			await DialogueBox.type("Callum: Hey!!")
			await caster.target.weigh_defense(-20)
			await caster.target.weigh_attack(10)
			await bs._progress()
		).grab_focus()
	
	if caster.protection.name != "---":
		new_button("Unequip Protection", func():
			MenuManager.clear(false)
			caster.target = caster
			await DialogueBox.type("> %s unequipped the %s." % [caster.character_name, caster.protection.name])
			DialogueBox.verbose = false
			load("res://items/resiliance.tres").on_use(caster)
			DialogueBox.verbose = true
			await bs._progress()
		)
