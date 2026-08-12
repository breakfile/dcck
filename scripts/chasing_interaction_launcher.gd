class_name Chaser extends CharacterBody2D

@export var speed := 50.0
@export var chase_delay := 0.5

@onready var agent: NavigationAgent2D = $NavigationAgent2D

@export var target: Node2D
@export var goo: Area2D

var detected := false
var chasing := false
var chase_timer := 0.0

func _physics_process(delta):
	if !Global.active:
		return

	if target == null:
		return

	# Detect player
	for body in $DetectionRange.get_overlapping_bodies():
		if body.is_in_group("Player"):
			if !detected:
				detected = true
				var x = AudioStreamPlayer.new()
				x.stream = load("res://sfx/enemy_alerted.wav")
				add_child(x)
				x.play()
				goo.get_node("Alert").visible = true
				chase_timer = chase_delay
			break

	if !detected:
		velocity = Vector2.ZERO
		move_and_slide()
		goo.get_child(0).play("default")
		return

	# Wait before chasing
	if !chasing:
		chase_timer -= delta
		velocity = Vector2.ZERO
		move_and_slide()

		if chase_timer <= 0:
			chasing = true

		return

	# Chase player
	goo.get_child(0).play("run")

	agent.target_position = target.global_position

	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()

	velocity = direction * speed
	move_and_slide()
