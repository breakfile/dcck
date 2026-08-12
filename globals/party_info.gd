extends RichTextLabel

var ailment_texts = {
	Character.Ailments.NORMAL: "[img]sprites/ailment/normal.png[/img]Fine",
	Character.Ailments.KO: "[img]sprites/ailment/ko.png[/img][color=red]Unconscious[/color]",
	Character.Ailments.POISON: "[img]sprites/ailment/poison.png[/img][color=green]Poisoned[/color]",
	Character.Ailments.CONFUSION: "[img]sprites/ailment/poison.png[/img][color=orange]Confused[/color]"
}

func _process(x):
	var new_text = ""
	for member in Global.party:
		new_text += "%s
%s
%3dHP %3dMP%s
" % [member.character_name, ailment_texts[member.ailment], member.hp, member.mp, "\n" if Global.party.find(member) != 3 else ""]
	if new_text != text:
		text = new_text
