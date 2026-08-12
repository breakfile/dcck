class_name EnemyData extends Resource

@export var name: String = "Spigot"
@export var level: int = 1
@export var exp_drop: int = 10
# Check dialogue pulls from this
@export_multiline var description: String = "Tell me about yourself."
@export var texture: Texture2D

@export_group("Affinities")
@export var fire_multiplier: float = 1
@export var ice_multiplier: float = 1
@export var physical_multiplier: float = 1

@export_group("Statistics")
# -1 means automatically work it out based off level
# Most regular encounters use this but I like to tweak 'em for boss fights
@export var max_hp := -1
@export var max_mp := -1
@export var attack := -1
@export var defense := -1

@export_group("Equipment")
@export var weapon: Equipment
@export var protection: Equipment

@export_group("Skills for A.I.")
@export var additional_skills: Array[Skill] = [preload("res://skills/attack.tres")]

func talk(caster: Character, battle_system: BattleSystem):
	await DialogueBox.type("> %s doesn't care about talking!" % name)
	await battle_system._progress()

func ai(enemy: Character, battle_system: BattleSystem):
	var all = enemy.protection.skills.duplicate()

	for skill in all:
		if skill.cost > enemy.mp:
			all.erase(skill)

	all.append_array(enemy.ai_skills)

	var skill = all.pick_random()

	if skill is DamageSkill or skill is AilmentSkill:
		enemy.target = Global.party.filter(func(c): return c.hp > 0).pick_random()
	else:
		enemy.target = battle_system.enemies.pick_random()

	if skill:
		await skill.cast(enemy)
