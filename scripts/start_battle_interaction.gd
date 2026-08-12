class_name StartBattleInteraction extends Interaction

@export var enemy_list: Array[EnemyData]
@export var song: AudioStream = preload("res://music/my_own/harry_sockcutter.ogg")
@export var can_escape := true
@export var background := preload("res://sprites/paper_bg.png")
@export var autoscroll := Vector2(10, 10)

func play_sfx(stream: AudioStream):
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	add_child(asp)
	asp.play()
	await asp.finished
	return

func on_interaction():
	if song: GlobalAudioStream.stream_paused = true
	await play_sfx(load("res://sfx/battle_bell.wav"))
	await Fader.fade_in()
	
	Global.in_battle = true
	
	var x = load("res://globals/battle_system.tscn").instantiate() as BattleSystem
	if root is Chaser:
		if !root.chasing:
			x.advantage = true
	
	Global.bs = x
	
	x.song = song
	x.enemy_list = enemy_list
	x.can_escape = can_escape
	get_tree().current_scene.add_child(x)
	x.bg.texture = background
	x.parallax.repeat_size = background.get_size()
	x.parallax.autoscroll = autoscroll
	await x.finished
	
	Global.in_battle = false
	
	if song:
		GlobalAudioStream.fade_in()
		GlobalAudioStream.stream_paused = false
