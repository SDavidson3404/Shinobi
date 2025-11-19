extends Area3D

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entering
func _on_body_entered(body: Node3D) -> void:
	# If body is in group player
	if body.is_in_group("player"):
		# Set current scene's parent node
		var current_scene = get_tree().current_scene.name
		# Depending on node, set path
		if current_scene == "level 1":
			current_scene = "level_1.tscn"
		elif current_scene == "level 2":
			current_scene = "level_2.tscn"
		elif current_scene == "level_3":
			current_scene = "level_3.tscn"
		# Change to scene
		SceneManager.change_scene(current_scene)
