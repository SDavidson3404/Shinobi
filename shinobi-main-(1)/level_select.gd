extends Node2D
@onready var level_1: Button = $"World 1/Level 1"
@onready var level_2: Button = $"World 2/Level 2"
@onready var level_3: Button = $"VBoxContainer/Level 3"
@onready var level_4: Button = $"World 1/Level 4"
@onready var level_5: Button = $"World 2/Level 5"
@onready var level_6: Button = $"VBoxContainer/Level 6"

func _ready() -> void:
	if LevelManager.levels_completed["level_5"]:
		level_6.modulate = Color(0.177, 40.096, 98.418, 1.0)
		level_5.modulate = Color(106, 106, 112, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_4"]:
		level_5.modulate = Color(0.177, 40.096, 98.418, 1.0)
		level_4.modulate = Color(106, 106, 112, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_3"]:
		level_4.modulate = Color(0.177, 40.096, 98.418, 1.0)
		level_3.modulate = Color(106, 106, 112, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_2"]:
		level_3.modulate = Color(0.177, 40.096, 98.418, 1.0)
		level_2.modulate = Color(106, 106, 112, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	elif LevelManager.levels_completed["level_1"]:
		level_2.modulate = Color(0.177, 40.096, 98.418, 1.0)
		level_1.modulate = Color(106, 106, 112, 1.0)
	else:
		level_1.modulate = Color(0.177, 40.096, 98.418, 1.0)

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
