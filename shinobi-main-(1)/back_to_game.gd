extends Button

# Runs when button is pressed
func _on_button_down() -> void:
	# Runs the function from main menu to load game
	MainMenu._on_load_button_down()
