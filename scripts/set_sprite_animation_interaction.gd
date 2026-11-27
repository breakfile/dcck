class_name PlayPlayerSpriteAnimationInteraction extends Interaction

@export var animation: String

func on_interaction():
	Global.player.aic = true
	var x = Global.player.get_node("Sprite") as AnimatedSprite2D
	x.play(animation)
