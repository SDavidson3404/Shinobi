extends CSGBox3D

func _on_enemy_enemy_killed() -> void:
	queue_free()
