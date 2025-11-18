extends Button

var saved_level = 0 # Saved level
# Runs when button is pressed
func _on_button_down() -> void:
	# Save file path as variable
	var file_path = "user://save_game.json"
	# If file exists
	if FileAccess.file_exists(file_path):
		# Open file in read mode
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		var content = file.get_as_text().strip_edges()
		if not content.is_empty():
			# Save text as variable
			var texts = file.get_as_text()
			# Close file
			file.close()
			# Create JSON variable
			var json = JSON.new()
			# Add text to JSON variable
			var result = json.parse(texts)
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
				var saved_levels = save_data.get("levels", {})
				for level in saved_levels.keys():
					if LevelManager.levels_completed.has(level):
						LevelManager.levels_completed[level] = saved_levels[level]
