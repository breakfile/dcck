extends EnemyData

func ai(enemy: Character, battle_system: BattleSystem):
	var hp_before := enemy.hp
	var loc: Array[Item] = [
		load("res://items/warm_cerebrum.tres"),
		load("res://items/cold_cerebrum.tres"),
		load("res://items/recv_cerebrum.tres"),
		load("res://items/str_cerebrum.tres")
	]
	loc.erase(enemy.protection)
	enemy.target = enemy
	await loc.pick_random().on_use(enemy)
	await super.ai(enemy, battle_system)
	if (enemy.hp == enemy.max_hp):
		await DialogueBox.type("> It backfired on Onguk!")
		var rm: Character = Global.party.pick_random()
		await DialogueBox.type("> %s fully recovered their MP!" % [rm.character_name])
		rm.mp = rm.max_mp
		enemy.hp = hp_before
