extends Area3D

signal collected

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.is_in_group("player"):
		collected.emit()
		Collectible.collected.emit()
		queue_free()
