extends EnemyData

func death(enemy: Character):
	await DialogueBox.type("> Callum's Christmas Lights had a power surge!")
	enemy._hurt_anim(14314)
	await DialogueBox.type("> Callum was electrocuted!")
