extends Label


func _physics_process(_delta: float) -> void:
	text = "Player Points: " + str(SkillManager.player_points)
