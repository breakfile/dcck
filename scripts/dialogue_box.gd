extends CanvasLayer

signal finished
var verbose := true
var skipping := true

func type(text):
	if !verbose:
		return
	
	$PanelContainer/RichTextLabel.text = text
	visible = true
	$Timer.stop(); $Timer.start()
	$PanelContainer/RichTextLabel.visible_characters = 0
	await finished
	await get_tree().process_frame
	visible = false
	return

func _process(delta: float) -> void:
	if !verbose:
		return
	
	if $PanelContainer/RichTextLabel.visible_characters >= $PanelContainer/RichTextLabel.get_total_character_count():
		if Input.is_action_just_pressed("ui_accept"):
			finished.emit()
	if Input.is_action_just_pressed("ui_cancel") and skipping:
		$PanelContainer/RichTextLabel.visible_characters = $PanelContainer/RichTextLabel.get_total_character_count()
	if Input.is_action_pressed("menu"):
		$Timer.wait_time = 0.001
		if $PanelContainer/RichTextLabel.visible_characters >= $PanelContainer/RichTextLabel.get_total_character_count():
			finished.emit()
	else:
		$Timer.wait_time = 0.03

func _on_timer_timeout() -> void:
	if !verbose:
		return
	$PanelContainer/RichTextLabel.visible_characters += 1
