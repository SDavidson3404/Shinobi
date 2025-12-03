extends Node2D

# ====================
# READY
# ====================
# On scene loading, capture mouse
func _ready() -> void: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ====================
# START GAME BUTTON
# ====================
# When pressing the start game button, load the level
func _on_start_game_button_down() -> void: SceneManager.change_scene("res://level.tscn")

# ====================
# TUTORIAL BUTTON
# ====================
# When tutorial button pressed, load tutorial
func _on_tutorial_button_down() -> void: SceneManager.change_scene("res://tutorial.tscn")

# ====================
# QUIT GAME BUTTON
# ====================
# On quit button pressed, quit game
func _on_quit_game_button_down() -> void: get_tree().quit()

# ====================
# SETTINGS BUTTON
# ====================
# On settings button pressed, change to settings
func _on_settings_button_down() -> void: SceneManager.change_scene("res://Settings.tscn")
