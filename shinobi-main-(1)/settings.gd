extends Node2D

@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/Fullscreen
@onready var volume_slider: HSlider = $VBoxContainer/Volume
@onready var resolution_option: OptionButton = $VBoxContainer/Resolution

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

func _on_fullscreen_toggled(pressed: bool):
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_selected(index: int):
	var res = resolution_option.get_item_text(index).split("x")
	DisplayServer.window_set_size(Vector2i(int(res[0]), int(res[1])))

func _on_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://main menu.tscn")
