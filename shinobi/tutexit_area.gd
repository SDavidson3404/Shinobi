extends Area3D

var can_exit = false

@export var next_scene_path: String = "res://level_1.tscn"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	Potency.connect("max_collected", Callable(self, "_on_max_collected"))

func _on_body_entered(body: Node) -> void:
	if can_exit:
		if body.is_in_group("player"):
			change_to_next_scene()

func change_to_next_scene():
	get_tree().change_scene_to_file(next_scene_path)

func _on_max_collected():
	can_exit = true
