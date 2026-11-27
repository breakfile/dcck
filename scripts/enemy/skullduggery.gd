extends EnemyData

var phase := 0

func death(enemy: Character):
	if phase == 1:
		Global.party.remove_at(1)
		return
	Global.bs.player.stream = load("res://music/my_own/harry_law.ogg")
	Global.bs.player.play()
	await DialogueBox.type("> Suddenly, someone lunged at Skullduggery!")
	enemy._hurt_anim(1953)
	await DialogueBox.type("> Skullduggery took 1953 damage!?")
	await DialogueBox.type("> Declan turned his head.\n> It was Callum.")
	await DialogueBox.type("Callum: Hey Declan! Look, no time to explain, alright? Let's just destroy this guy!")
	Global.party.append(Character.enemy_factory(enemy.tree, load("res://enemies/callumjoke.tres")))
	await DialogueBox.type("> Callum joined your party????????")
	enemy.max_hp = 1000
	enemy.hp = enemy.max_hp
	enemy.df_w = -1000
	
	Global.party[0].hp = Global.party[0].max_hp
	
	phase = 1
