extends Area3D

# ====================
# VARIABLES
# ====================
var can_exit = false # Checks if you can exit

# ====================
# READY
# ====================
# Runs on scene loaded
func _ready():
	# Connect to max collected signal
	Potency.connect("max_collected", Callable(self, "_on_max_collected"))

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entering
func _on_body_entered(body: Node) -> void:
	# If you can exit
	if can_exit:
		# If body is in player group
		if body.is_in_group("player"):
			# Up points
			SkillManager.player_points += 3
			# Save skills
			SkillManager.save_skills()
			# Set level to done
			LevelManager.levels_completed["level_5"] = true
			LevelManager.save_skills()
			# Change to next scene
			change_to_next_scene()

# ====================
# CHANGE SCENE
# ====================
# Loads next scene
func change_to_next_scene(): SceneManager.change_scene("res://level_6.tscn")

# ====================
# MAX COLLECTED
# ====================
# Sets can exit to true if max potency met
func _on_max_collected(): can_exit = true
