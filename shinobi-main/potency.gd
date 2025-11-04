extends ProgressBar

@export var max_potency: float = 6.0
@export var current_potency: float = 0.0

signal max_collected
signal collected

func _ready() -> void:
	await get_tree().process_frame
	current_potency = 0
	value = 0
	rotation_degrees = -45
	size = Vector2(101.5, 75.0)
	show_percentage = false
	position = Vector2(5.0, 587.0)
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	SceneManager.connect("changed_scene", Callable(self, "_on_changed_scene"))
	max_value = max_potency
	value = current_potency
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 162, 255)
	add_theme_stylebox_override("fill", bg)


func _physics_process(_delta: float) -> void:
	if current_potency == max_potency:
		max_collected.emit()
		Potency.max_collected.emit()


func _on_collectible_collected() -> void:
	current_potency += 1.0
	collected.emit()
	value = current_potency

func _on_changed_scene():
	current_potency = 0.0
	value = current_potency
