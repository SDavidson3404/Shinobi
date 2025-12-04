extends Area3D

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entered
func _on_body_entered(body: Node) -> void:
	# If body is player
	if body.is_in_group("player"):
		# Change scene
		if get_tree().current_scene.name == "tutorial":
			SceneManager.change_scene("res://main menu.tscn")
		elif get_tree().current_scene.name == "Level":
			SceneManager.change_scene("res://victory_+_credits.tscn")
