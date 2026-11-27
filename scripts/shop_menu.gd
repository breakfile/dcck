class_name ShopMenuInteraction extends Interaction

@export var items: Array[Item]
@export var relative_price: Array[int]

func new_button(text: String, logic: Callable):
	var b := Button.new()
	MenuManager.say_grid.add_child(b)
	b.text = text
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(logic)
	MenuManager.say_grid.reset_size()
	return b
	
signal purchase

func on_interaction():
	MenuManager.say_label.text = "Buy what?"
	MenuManager.push(MenuManager.say)
	
	new_button("Nothing", func():
			MenuManager.clear(false)
			await DialogueBox.type("> You didn't buy anything.")
			purchase.emit()
	).grab_focus()
	for item in items:
		var g = new_button("%s for %ssn" % [item.name, relative_price[items.find(item)]], func():
			MenuManager.clear(false)
			if Global.snails >= relative_price[items.find(item)]:
				await DialogueBox.type("> You bought %s." % [item.name])
				Global.snails -= relative_price[items.find(item)]
				Global.items.append(item)
			else:
				await DialogueBox.type("> You didn't have enough snails (sn).");
			purchase.emit()
		)
		g.focus_entered.connect(func():
			MenuManager.description_textbox.text = item.desc
		)
		g.focus_exited.connect(func():
			MenuManager.description_textbox.text = ""
		)
		
	await purchase
