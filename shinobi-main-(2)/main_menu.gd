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
			
			var json = JSON.new()
			var result = json.parse(text)
			if result == OK:
				var save_data = json.get_data()
				
				# Load level
				saved_level = save_data.get("current_level", 1)
				SceneManager.change_scene(str(saved_level) + ".tscn")
				
				# Load skills
				SkillManager.load_skills()  # Initialize default skill tree
				var saved_skills = save_data.get("skills", {})
				for skill_name in saved_skills.keys():
					if SkillManager.skills.has(skill_name):
						SkillManager.skills[skill_name]["unlocked"] = saved_skills[skill_name]["unlocked"]
				
				print("Game and skills loaded successfully!")
			else:
				print("Failed to parse JSON:", json.get_error_message())
		else:
			print("Failed to open save file!")
	else:
		print("No save file found.")
