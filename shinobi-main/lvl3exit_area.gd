extends Area3D

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entering
func _on_body_entered(body: Node) -> void:
	# If body is in player group
	if body.is_in_group("player"):
		# Up points
		SkillManager.player_points += 3
		# Save skills
		SkillManager.save_skills()
		# Set level to done
		LevelManager.levels_completed["level_3"] = true
		LevelManager.save_skills()
		# Change to next scene
		change_to_next_scene()

# ====================
# CHANGE SCENE
# ====================
# Loads next scene
func change_to_next_scene(): SceneManager.change_scene("res://level_4.tscn")
