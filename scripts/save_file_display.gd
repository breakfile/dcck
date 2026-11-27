extends RichTextLabel

func _ready():
	if not FileAccess.file_exists("user://dcsave"):
		text = "No file to continue!"
		return

	var file := FileAccess.open("user://dcsave", FileAccess.READ)
	if file == null:
		text = "Can't open the save?"
		return

	var fat: String = file.get_as_text()
	var save_data: Variant = JSON.parse_string(fat)

	if save_data == null or not save_data is Dictionary:
		text = "Save file is corrupted?"
		return

	text = "%s, Level %d\n%s" % [
		save_data["true_name"],
		save_data["party"][0]["lvl"],
		save_data["header"]
	]
	
	if save_data["true_name"].to_lower() == "harry":
		text += "\nEXTREME MODE"
