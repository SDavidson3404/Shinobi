extends Area3D

var can_exit = false

func _ready():
	Potency.connect("max_collected", Callable(self, "_on_max_collected"))

func _on_body_entered(body: Node) -> void:
	if can_exit:
		if body.is_in_group("player"):
			SceneManager.change_scene("res://main menu.tscn")
	return

func _on_max_collected():
	can_exit = true
