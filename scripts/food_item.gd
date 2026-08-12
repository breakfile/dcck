class_name FoodItem extends Item

enum EatType {
	ATE,
	DRANK
}

@export var expire: bool = true

@export var heal_ko: bool = false
@export var food_description: EatType
@export var heal_amount: int = 5

func on_use(caster: Character):
	await DialogueBox.type("> " + caster.target.character_name + (" ate the " if food_description == EatType.ATE else " drank the ") + name + ".")		
	
	if heal_amount > 0:
		await caster.target.heal(heal_amount, heal_ko)
	
	if expire:
		Global.items.remove_at(Global.items.find(self))
	return
