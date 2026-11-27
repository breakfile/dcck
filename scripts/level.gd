class_name Level extends Node2D

@export var title: String
@export var music: AudioStream
@export var can_open_menu := true

func _ready():
	if !Global.chase_sequence:
		if music:
			if GlobalAudioStream.stream != music or !GlobalAudioStream.playing:
				GlobalAudioStream.stream = music
				GlobalAudioStream.play()
		else:
			GlobalAudioStream.stop()
	else:
		music = load("res://music/my_own/run.ogg")
		if GlobalAudioStream.stream != music or !GlobalAudioStream.playing:
			GlobalAudioStream.stream = music
			GlobalAudioStream.play()
	
	for member in Global.party:
		if member.ailment == member.Ailments.GLOWING:
			Global.active = false
			await DialogueBox.type("> %s stopped glowing." % [member.character_name])
			member.ailment = member.Ailments.NORMAL
			Global.active = true
