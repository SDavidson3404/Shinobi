extends Area3D

# ====================
# VARIABLE
# ====================
var can_exit = false # Checks if can exit

# ====================
# READY
# ====================
# Runs upon scene loading, connect to max collected signal
func _ready(): Potency.connect("max_collected", Callable(self, "_on_max_collected"))

# ====================
# ON BODY ENTERED
# ====================
# Runs on body entered
func _on_body_entered(body: Node) -> void:
	# If can exit
	if can_exit:
		# If body is in group
		if body.is_in_group("player"):
			# Change scene
			SceneManager.change_scene("res://main menu.tscn")

# ====================
# ON MAX COLLECTED
# ====================
# Sets can exit to true upon max potency met
func _on_max_collected(): can_exit = true
