extends CSGBox3D
@onready var enemy: CharacterBody3D = $"../../Enemies/enemy"

func _on_enemy_enemy_killed() -> void:
	queue_free()
