extends Node2D
@onready var level_1: Button = $"World 1/Level 1"
@onready var level_2: Button = $"World 1/Level 2"
@onready var level_3: Button = $"World 1/Level 3"
@onready var level_4: Button = $"World 2/Level 4"
@onready var level_5: Button = $"World 2/Level 5"
@onready var level_6: Button = $"World 2/Level 6"
@onready var level_7: Button = $"World 3/Level 7"
@onready var level_8: Button = $"World 3/Level 8"
@onready var level_9: Button = $"World 3/Level 9"
@onready var button: Button = $Button

func _ready() -> void:
	if not SceneManager.is_connected("changed_scene", Callable(self, "_on_scene_changed")):
		SceneManager.connect("changed_scene", Callable(self, "_on_scene_changed"))

func _on_scene_changed():
	if LevelManager.levels_completed["level_10"]:
		button.modulate = Color(106, 106, 112, 1.0)
		level_9.modulate = Color(106, 106, 112, 1.0)
		level_8.modulate = Color(106, 106, 112, 1.0)
		level_7.modulate = Color(106, 106, 112, 1.0)
		level_6.modulate = Color(106, 106, 112, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_9"]:
		button.modulate = Color(23, 51, 104, 1.0)
		level_9.modulate = Color(106, 106, 112, 1.0)
		level_8.modulate = Color(106, 106, 112, 1.0)
		level_7.modulate = Color(106, 106, 112, 1.0)
		level_6.modulate = Color(106, 106, 112, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_8"]:
		level_9.modulate = Color(23, 51, 104, 1.0)
		level_8.modulate = Color(106, 106, 112, 1.0)
		level_7.modulate = Color(106, 106, 112, 1.0)
		level_6.modulate = Color(106, 106, 112, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_7"]:
		level_8.modulate = Color(23, 51, 104, 1.0)
		level_7.modulate = Color(106, 106, 112, 1.0)
		level_6.modulate = Color(106, 106, 112, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_6"]:
		level_7.modulate = Color(23, 51, 104, 1.0)
		level_6.modulate = Color(106, 106, 112, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_5"]:
		level_6.modulate = Color(23, 51, 104, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_4"]:
		level_5.modulate = Color(23, 51, 104, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_3"]:
		level_4.modulate = Color(23, 51, 104, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_2"]:
		level_3.modulate = Color(23, 51, 104, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_1"]:
		level_2.modulate = Color(23, 51, 104, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	else:
		level_1.modulate = Color(23, 51, 104, 1.0)

func _on_level_1_button_down() -> void:
	SceneManager.change_scene("res://level_1.tscn")

func _on_level_2_button_down() -> void:
	if LevelManager.levels_completed["level_1"]:
		SceneManager.change_scene("res://level_2.tscn")

func _on_level_3_button_down() -> void:
	if LevelManager.levels_completed["level_2"]:
		SceneManager.change_scene("res://level_3.tscn")

func _on_level_4_button_down() -> void:
	if LevelManager.levels_completed["level_3"]:
		SceneManager.change_scene("res://level_4.tscn")

func _on_level_5_button_down() -> void:
	if LevelManager.levels_completed["level_4"]:
		SceneManager.change_scene("res://level_5.tscn")

func _on_level_6_button_down() -> void:
	if LevelManager.levels_completed["level_5"]:
		SceneManager.change_scene("res://level_6.tscn")

func _on_level_7_button_down() -> void:
	if LevelManager.levels_completed["level_6"]:
		SceneManager.change_scene("res://level_7.tscn")

func _on_level_8_button_down() -> void:
	if LevelManager.levels_completed["level_7"]:
		SceneManager.change_scene("res://level_8.tscn")

func _on_level_9_button_down() -> void:
	if LevelManager.levels_completed["level_8"]:
		SceneManager.change_scene("res://level_9.tscn")

func _on_button_button_down() -> void:
	if LevelManager.levels_completed["level_9"]:
		SceneManager.change_scene("res://level_10.tscn")
