extends ProgressBar

@export var max_potency = 6.0
@export var current_potency = 0.0

signal max_collected
signal collected

func _ready() -> void:
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	max_value = max_potency
	value = current_potency

func _physics_process(_delta: float) -> void:
	if current_potency == max_potency:
		max_collected.emit()
		Potency.max_collected.emit()

func _on_collectible_collected() -> void:
	current_potency += 1.0
	collected.emit()
	value = current_potency
