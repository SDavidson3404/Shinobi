extends Area3D

# ====================
# VARIABLES
# ====================
var can_exit = false # Checks if can exit

# ====================
# READY
# ====================
# Runs on scene loading
func _ready():
	# Connect to max collected signal
	Potency.connect("max_collected", Callable(self, "_on_max_collected"))

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entering exit
func _on_body_entered(body: Node) -> void:
	# If you can exit:
	if can_exit:
		# If body is in player group
		if body.is_in_group("player"):
			# Give player points
			SkillManager.player_points += 3
			# Save points
			SkillManager.save_skills()
			# Set level to done
			LevelManager.levels_completed["level_2"] = true
			LevelManager.save_skills()
			change_to_next_scene()

# ====================
# CHANGE SCENE
# ====================
# Changes to the next level
func change_to_next_scene(): SceneManager.change_scene("res://level_3.tscn")

# ====================
# ON MAX COLLECTED
# ====================
# Sets can exit to true if max potency met
func _on_max_collected(): can_exit = true
