extends Node2D

var saved_level = 0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_start_game_button_down() -> void:
	SceneManager.change_scene("res://level_1.tscn")

func _on_tutorial_button_down() -> void:
	SceneManager.change_scene("res://tutorial.tscn")

func _on_quit_game_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	SceneManager.change_scene("res://Settings.tscn")

func _on_load_button_down() -> void:
	var file_path = "res://save_game.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			
			var json = JSON.new()              # Create a JSON instance
			var result = json.parse(text)      # Parse the text
			if result == OK:                   # Check if parsing succeeded
				var save_data = json.get_data()   # Retrieve the dictionary
				saved_level = save_data["current_level"]
				SceneManager.change_scene(saved_level + ".tscn")
				print("Game loaded successfully!")
			else:
				print("Failed to parse JSON:", json.get_error_message())
		else:
			print("Failed to open save file!")
	else:
		print("No save file found.")
