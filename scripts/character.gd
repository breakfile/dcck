class_name Character extends RefCounted

func hurt(base_damage: float, atk_type: AttackType = AttackType.PHYS):
	var intake = 1.0
	match atk_type:
		AttackType.FIRE: intake = fire_mult
		AttackType.ICE: intake = freeze_mult
		AttackType.PHYS: intake = phys_mult

	if intake <= 0:
		await _void_anim()
		await DialogueBox.type("> %s voided the attack!\n> It was futile." % character_name)
	else:
		var value = randi_range(-3, 3)
		var dmg = max(1, floor(base_damage * intake) + value)
		hp = max(0, hp - dmg)
		_hurt_anim(dmg)
		await DialogueBox.type("> %s took %d damage!" % [character_name, dmg])
		if hp < 1:
			await bs.handle_death(self)

func _hurt_anim(damage: int):
	if sprite is PlayerInfoSprite: sprite.is_animating = true
	
	play_sfx(load("res://sfx/hit.wav"))
	if sprite:
		var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
		hit_number.text = str(damage)
		sprite.add_child(hit_number)
		
		sprite.self_modulate = Color(2, 0, 0)
		await tree.create_timer(0.15).timeout
		sprite.self_modulate = Color(1, 1, 1)
	
	if sprite is PlayerInfoSprite: sprite.is_animating = false

func _void_anim():
	if sprite is PlayerInfoSprite: sprite.is_animating = true
	
	play_sfx(load("res://sfx/resist.wav"))
	if sprite:
		var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
		hit_number.text = "Void"
		sprite.add_child(hit_number)

		var make_white = func():
			sprite.self_modulate = Color(18.892, 18.892, 18.892)
			await tree.create_timer(0.15).timeout
			sprite.self_modulate = Color.WHITE
		make_white.call()
	
	if sprite is PlayerInfoSprite: sprite.is_animating = false

enum Ailments {
	NORMAL,
	KO,
	POISON,
	CONFUSION
}

var character_name: String
var desc: String
var max_hp: int
signal died

var hp: int = 0

var max_mp: int
var mp: int
var lv: int
var at: int
var df: int
var xp: int

var bs: BattleSystem

var at_w := 0
var df_w := 0

func weigh_attack(weight):
	at_w += weight
	if weight < 0:
		await DialogueBox.type("> %s's attack decreased by %d!" % [character_name, abs(weight)])
	else:
		await DialogueBox.type("> %s's attack increased by %d!" % [character_name, weight])

func weigh_defense(weight):
	df_w += weight
	if weight < 0:
		await DialogueBox.type("> %s's defense decreased by %d!" % [character_name, abs(weight)])
	else:
		await DialogueBox.type("> %s's defense increased by %d!" % [character_name, weight])

var weapon: Equipment
var protection: Equipment

var default_phys_mult := 1.0
var default_fire_mult := 1.0
var default_freeze_mult := 1.0

var phys_mult := 1.0
var fire_mult := 1.0
var freeze_mult := 1.0

var ailment: Ailments = Ailments.NORMAL

enum AttackType {
	FIRE,
	ICE,
	PHYS
}

var exp_drop := 0

var target: Character = null

var tree: SceneTree

var ai_skills: Array[Skill]

func _init(tree: SceneTree, new_name: String, new_desc: String, new_lv: int, fire_m: float = 1, freeze_m: float = 1, phys_m: float = 1, new_max_hp: int = -1, new_max_mp: int = -1, new_at: int = -1, new_df: int = -1):
	self.tree = tree
	weapon = Equipment.new()
	weapon.name = "---"
	protection = Equipment.new()
	protection.name = "---"
	
	character_name = new_name
	
	phys_mult = phys_m
	fire_mult = fire_m
	freeze_mult = freeze_m
	
	default_phys_mult = phys_m
	default_fire_mult = fire_m
	default_freeze_mult = freeze_m
	
	desc = new_desc
	level_up(new_lv)
	xp = 10*(lv-1)
	
	if new_max_hp != -1: max_hp = new_max_hp; hp = max_hp
	if new_max_mp != -1: max_mp = new_max_mp; mp = max_mp
	if new_at != -1: at = new_at
	if new_df != -1: df = new_df

var texture: Texture2D
var sprite: Sprite2D



func heal(heal_amount: int, heal_ko: bool = false):
	if ailment == Ailments.KO:
		if heal_ko:
			play_sfx(load("res://sfx/heal.wav"))
			ailment = Ailments.NORMAL
			hp = min(heal_amount, max_hp)
			if sprite:
				var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
				hit_number.text = str(hp)
				hit_number.modulate = Color(0, 1, 0.5)
				sprite.add_child(hit_number)
			await DialogueBox.type("> %s was revived!" % character_name)
		else:
			if sprite:
				var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
				hit_number.text = "Miss"
				sprite.add_child(hit_number)
			await DialogueBox.type("> It had no effect on %s...\n> It was futile." % character_name)
		return

	play_sfx(load("res://sfx/heal.wav"))
	hp = min(hp + heal_amount, max_hp)
	if hp >= max_hp:
		if sprite:
			var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
			hit_number.text = "Max"
			hit_number.modulate = Color(0, 1, 0.5)
			sprite.add_child(hit_number)
		await DialogueBox.type("> %s's HP are maxed out." % [character_name])
	else:
		if sprite:
			var hit_number = load("res://prefabs/damage_number.tscn").instantiate()
			hit_number.text = str(heal_amount)
			hit_number.modulate = Color(0, 1, 0.5)
			sprite.add_child(hit_number)
		await DialogueBox.type("> %s recovered %d HP." % [character_name, heal_amount])

func level_up(new_lv: int):
	new_lv = min(new_lv, 99) # In case _verbose variant is not used
	lv = new_lv
	at = 20+floor(lv**1.4)
	df = 10+floor(lv**1.1)
	max_hp = floor(at*2.5)
	hp = max_hp
	max_mp = floor(df*2.5)
	mp = max_mp

func play_sfx(stream: AudioStream):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	tree.current_scene.add_child(asp)
	asp.play()
	return

func level_up_verbose(new_lv: int):
	play_sfx(load("res://sfx/lv+.wav"))
	new_lv = min(new_lv, 99)
	await DialogueBox.type("> " + character_name + " is now level " + str(new_lv) + "!")
	level_up(new_lv)

var on_talk: Callable
var ai: Callable

static func enemy_factory(new_tree: SceneTree, data: EnemyData):
	var c = Character.new(
		new_tree,
		data.name,
		data.description,
		data.level,
		data.fire_multiplier,
		data.ice_multiplier,
		data.physical_multiplier,
		data.max_hp,
		data.max_mp,
		data.attack,
		data.defense
	)
	c.exp_drop = data.exp_drop
	c.target = c
	DialogueBox.verbose = false
	if data.weapon != null:
		data.weapon.on_use(c)
	if data.protection != null:
		data.protection.on_use(c)
	DialogueBox.verbose = true
	
	c.ai_skills = data.additional_skills
	c.on_talk = data.talk.bind()
	c.ai = data.ai.bind()
	
	if data.texture:
		c.texture = data.texture
	
	return c
	
