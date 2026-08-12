extends CharacterBody2D


@export var speed := 64

func _ready():
	$Sprite.play(Global.facing + "_idle")
	Global.player = self
	Fader.fade_out()

func _physics_process(_delta: float) -> void:
	if not Global.active: $Sprite.play(Global.facing + "_idle"); return
	
	if Input.is_action_pressed("ui_cancel"):
		speed = 128
	else:
		speed = 64
		
	$Sprite.speed_scale = float(speed)/64
	
	if Input.is_action_just_pressed("ui_down"): Global.facing = "f"
	if Input.is_action_just_pressed("ui_up"): Global.facing = "b"
	
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
		$Sprite.play(Global.facing + "_walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		if $Sprite.frame == 1 or $Sprite.frame == 3:
			$Sprite.play(Global.facing + "_idle")

	move_and_slide()
