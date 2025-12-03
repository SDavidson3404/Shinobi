extends CSGBox3D

# Function runs when enemy is killed
func _on_enemy_enemy_killed() -> void: queue_free()
