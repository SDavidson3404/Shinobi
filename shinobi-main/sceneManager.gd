extends Node

# ====================
# SIGNALS
# ====================
signal changed_scene # Change scene signal

# ====================
# CHANGE SCENE
# ====================
# Function to change scene
func change_scene(path: String):
	# Emit changed scene
	changed_scene.emit()
	call_deferred("_deferred_change_scene", path)


func _deferred_change_scene(path: String):
	get_tree().change_scene_to_file(path)
