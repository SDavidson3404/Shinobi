extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var current_scene = get_tree().current_scene.name
		if current_scene == "level 1":
			current_scene = "level_1.tscn"
		elif current_scene == "level 2":
			current_scene = "level_2.tscn"
		elif current_scene == "level_3":
			current_scene = "level_3.tscn"
		SceneManager.change_scene(current_scene)
