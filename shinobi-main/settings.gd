extends Node2D

# ====================
# VARIABLES
# ====================
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/Fullscreen # Checkbox for fullscreen
@onready var resolution_option: OptionButton = $VBoxContainer/Resolution # Options button

# ====================
# READY
# ====================
# Runs on loading scene
func _ready():
	# Fullscreen setup
	fullscreen_checkbox.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_checkbox.connect("toggled", Callable(self, "_on_fullscreen_toggled"))

	# Resolution setup
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("1280x720")
	resolution_option.add_item("800x600")
	resolution_option.connect("item_selected", Callable(self, "_on_resolution_selected"))

# ====================
# FULLSCREEN TOGGLED
# ====================
# Runs on toggling fullscreen
func _on_fullscreen_toggled(pressed: bool):
	# If pressed, set to fullscreen
	if pressed: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Otherwise, set to windowed
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# ====================
# RESOLUTION SELECTED
# ====================
# Runs upon resolution selected
func _on_resolution_selected(index: int):
	# Save resolution as variable
	var res = resolution_option.get_item_text(index).split("x")
	# Set window size
	DisplayServer.window_set_size(Vector2i(int(res[0]), int(res[1])))


# ====================
# RETURN TO MENU
# ====================
# Return to main menu upon pressed
func _on_button_button_down() -> void: SceneManager.change_scene("res://main menu.tscn")
