extends Label

# ====================
# PHYSICS PROCESS
# ====================
# Runs 60 frames a second
func _physics_process(_delta: float) -> void:
	# Set text to amount of points
	text = "Player Points: " + str(SkillManager.player_points)
