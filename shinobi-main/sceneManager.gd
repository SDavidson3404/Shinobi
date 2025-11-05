extends Node

signal changed_scene

func change_scene(path: String):
	changed_scene.emit()
	get_tree().change_scene_to_file(path)
