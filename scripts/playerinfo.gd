class_name PlayerInfoSprite extends Sprite2D

var chara: Character
var bm: BattleSystem
var is_animating = false
@export var number := 0

@onready var j = preload("res://sprites/nocharacter.png")

func _process(_x):
	if Global.party.size() >= number+1:
		chara = Global.party[number]
		chara.sprite = self
		bm = Global.bs
	else:
		chara = null
	
	var rtl = get_parent().get_node("PanelContainer2/RichTextLabel") as RichTextLabel
	
	if chara:
		if Global.party.find(chara) != 0:
			if chara.texture:
				texture = chara.texture
			else:
				texture = j
		
		$Name.text = chara.character_name
		$Hp.max_value = chara.max_hp
		$Hp.value = chara.hp
		$Mp.max_value = chara.max_mp
		$Mp.value = chara.mp
		
		$HPslash.text = "HP %d/%d" % [chara.hp, chara.max_hp]
		$HPslash.modulate = Color.WHITE
		$MPslash.text = "MP %d/%d" % [chara.mp, chara.max_mp]
		
		if chara.ailment == Character.Ailments.KO:
			$Name.modulate = Color.RED
		elif bm and bm.current_member == chara:
			$Name.modulate = Color.YELLOW
		else:
			$Name.modulate = Color.WHITE
		
		if !is_animating:
			match chara.ailment:
				Character.Ailments.NORMAL:
					chara.sprite.self_modulate = Color.WHITE
				Character.Ailments.KO:
					chara.sprite.self_modulate = Color.RED
					$HPslash.text = "KNOCKOUT"
					$HPslash.modulate = Color.RED
				Character.Ailments.POISON:
					chara.sprite.self_modulate = Color.GREEN
					$HPslash.text = "POISONED"
					$HPslash.modulate = Color.GREEN
				Character.Ailments.CONFUSION:
					$HPslash.text = "CONFUSED"
					chara.sprite.self_modulate = Color.ORANGE
					$HPslash.modulate = Color.ORANGE
				Character.Ailments.GLOWING:
					$HPslash.text = "GLOWING"
					chara.sprite.self_modulate = Color(0, 0.5, 1)
					$HPslash.modulate = Color(0, 0.5, 1)
				Character.Ailments.FLOATING:
					$HPslash.text = "FLOATING"
					chara.sprite.self_modulate = Color(1, 0, 1)
					$HPslash.modulate = Color(1, 0, 1)
				
			if rtl.get_total_character_count() > 0:
				visible = false
			else:
				visible = true
	else:
		visible = false
