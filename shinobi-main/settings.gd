extends Node2D

# ====================
# VARIABLES
# ====================
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/Fullscreen # Checkbox for fullscreen
@onready var volume_slider: HSlider = $VBoxContainer/Volume # Volume slider
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

	# Audio setup
	volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))

# ====================
# FULLSCREEN TOGGLED
# ====================
# Runs on toggling fullscreen
func _on_fullscreen_toggled(pressed: bool):
	# If pressed:
	if pressed:
		# Set to fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# Otherwise
	else:
		# Set to windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

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
# ON VOLUME CHANGED
# ====================
# Change volume of main audio server
func _on_volume_changed(value: float): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

# ====================
# RETURN TO MENU
# ====================
# Return to main menu upon pressed
func _on_button_button_down() -> void: SceneManager.change_scene("res://main menu.tscn")
