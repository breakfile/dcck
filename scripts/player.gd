extends CharacterBody2D


@export var speed := 64
var aic := false

func _ready():
	if Global.sf_spawning:
		position = Global.sf_spawnpos
		Global.sf_spawning = false
	
	$Sprite.play(Global.facing + "_idle")
	Global.player = self
	Fader.fade_out()

func _physics_process(_delta: float) -> void:
	var in_ladder = false
	for area in $NameChecker.get_overlapping_areas():
		if area.is_in_group("Ladder"):
			in_ladder = true
	
	if not Global.active: 
		$Sprite.speed_scale = 1
		velocity.x = 0
		velocity.y = 0
		if !aic:
			if in_ladder:
				$Sprite.play("ladder_still")
			else:
				$Sprite.play(Global.facing + "_idle")
		return
	
	aic = false
	
	if Input.is_action_pressed("ui_cancel"):
		if not in_ladder:
			speed = 128
		else:
			speed = 64
	else:
		speed = 64
		
	$Sprite.speed_scale = float(speed)/64
	
	if Input.is_action_just_pressed("ui_down"): Global.facing = "f"
	if Input.is_action_just_pressed("ui_up"): Global.facing = "b"
	
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
		if in_ladder:
				$Sprite.play("ladder_ud")
		else:
			$Sprite.play(Global.facing + "_walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		if $Sprite.frame == 1 or $Sprite.frame == 3:
			if in_ladder:
				$Sprite.play("ladder_still")
			else:
				$Sprite.play(Global.facing + "_idle")

	move_and_slide()
