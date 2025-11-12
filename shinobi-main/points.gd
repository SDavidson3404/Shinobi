extends Area3D

var collected = false

# ====================
# ON BODY ENTERED
# ====================
# Runs when body enters
func _on_body_entered(body: Node3D) -> void:
	if collected:
		queue_free()
	if not collected:
		# If body is in player group
		if body.is_in_group("player"):
			# Add point
			SkillManager.player_points += 1
			# Save skills
			SkillManager.save_skills()
			collected = true
			# Remove node
			queue_free()
