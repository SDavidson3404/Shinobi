extends Node

func _ready() -> void:
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == 0:
		set_volume(75)

func set_volume(value):
	value /= 100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
