extends GridContainer

func _on_fight_pressed() -> void:
	MenuManager.pvb_ownparty = false
	MenuManager.pvb_onchoice = func(member):
		MenuManager.clear(false)
		Global.bs.current_member.target = member
		await load("res://skills/attack.tres").cast(Global.bs.current_member)
		Global.bs._progress()
		
	MenuManager.push(MenuManager.party)


func _on_check_pressed() -> void:
	MenuManager.pvb_ownparty = false
	MenuManager.pvb_onchoice = func(member):
		MenuManager.clear(false)
		Global.bs.current_member.target = member
		await load("res://skills/check.tres").cast(Global.bs.current_member)
		Global.bs._progress()
		
	MenuManager.push(MenuManager.party)


func _on_run_pressed() -> void:
	MenuManager.clear(false)
	if Global.bs.can_escape:
		await DialogueBox.type("> You ran away...")
		Global.bs._stop()
	else:
		await DialogueBox.type("> Can't run from this battle!")
		await Global.bs._progress()


func _on_talk_pressed() -> void:
	MenuManager.pvb_ownparty = false
	MenuManager.pvb_onchoice = func(member:Character):
		MenuManager.clear(false)
		Global.bs.current_member.target = member
		member.on_talk.call(Global.bs.current_member, Global.bs)
		
	MenuManager.push(MenuManager.party)


func _on_skill_pressed() -> void:
	MenuManager.selected_skillcaster = Global.bs.current_member
	MenuManager.push(MenuManager.skill)
