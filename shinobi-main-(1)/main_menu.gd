extends Node2D

# ====================
# VARIABLES
# ====================
var saved_level = 0 # Saved level

# ====================
# READY
# ====================
# On scene loading, capture mouse
func _ready() -> void: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ====================
# START GAME BUTTON
# ====================
# When pressing the start game button, load level 1
func _on_start_game_button_down() -> void: SceneManager.change_scene("res://level_1.tscn")

# ====================
# TUTORIAL BUTTON
# ====================
# When tutorial button pressed, load tutorial
func _on_tutorial_button_down() -> void: SceneManager.change_scene("res://tutorial.tscn")

# ====================
# QUIT GAME BUTTON
# ====================
# On quit button pressed, quit game
func _on_quit_game_button_down() -> void: get_tree().quit()

# ====================
# SETTINGS BUTTON
# ====================
# On settings button pressed, change to settings
func _on_settings_button_down() -> void: SceneManager.change_scene("res://Settings.tscn")

# ====================
# LOAD BUTTON
# ====================
# Loads saved level upon pressed
func _on_load_button_down() -> void:
	# Save file path as variable
	var file_path = "res://save_game.json"
	# If file exists
	if FileAccess.file_exists(file_path):
		# Open file in read mode
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		# If file is valid
		if file:
			# Save text as variable
			var text = file.get_as_text()
			# Close file
			file.close()
			# Create JSON variable
			var json = JSON.new()
			# Add text to JSON variable
			var result = json.parse(text)
			# If result is valid
			if result == OK:
				# Get save data as variable
				var save_data = json.get_data()
				# set level to saved level
				saved_level = save_data.get("current_level", 1)
				# Change to scene
				SceneManager.change_scene(str(saved_level))
				# Load skills
				SkillManager.load_skills()  # Initialize default skill tree
				# Set saved skills
				var saved_skills = save_data.get("skills", {})
				# For skill in list
				for skill_name in saved_skills.keys():
					# If skill exists
					if SkillManager.skills.has(skill_name):
						# If is unlocked, set to unlocked
						SkillManager.skills[skill_name]["unlocked"] = saved_skills[skill_name]["unlocked"]
