extends MeshInstance3D

@onready var exit_area: Area3D = $"MeshInstance3D/Exit area"

func _ready() -> void:
	exit_area.monitoring = false
	connect("died", Callable(self, "_on_boss_died"))

func _on_boss_died():
	visible = true
	exit_area.monitoring = true
