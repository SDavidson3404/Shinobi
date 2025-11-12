extends Area3D

signal collected # Signal for collecting collectible

# Runs when body enters
func _on_body_entered(body: Node3D) -> void:
	# If body is in "player" group, emit collected and delete
	if body.is_in_group("player"):
		collected.emit()
		Collectible.collected.emit()
		queue_free()
