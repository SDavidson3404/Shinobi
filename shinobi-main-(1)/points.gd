extends Area3D

# ====================
# ON BODY ENTERED
# ====================
# Runs when body enters
func _on_body_entered(body: Node3D) -> void:
	# If body is in player group
	if body.is_in_group("player"):
		# Add point
		SkillManager.player_points += 1
		# Save skills
		SkillManager.save_skills()
		# Remove node
		queue_free()
