extends EnemyData

func ai(enemy: Character, battle_system: BattleSystem):
	await DialogueBox.type("Now, face the power of my PERCUSSION ATTACK!")
	battle_system.player.stop()
	await DialogueBox.type("> [color=red][shake]But something happened to Cohen...")
	await enemy.hurt(349238)
