extends Area3D

signal collected

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		collected.emit()
		Collectible.collected.emit()
		queue_free()
