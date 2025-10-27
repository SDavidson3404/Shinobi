extends ProgressBar

@export var max_potency = 6.0
@export var current_potency = 0.0

func _ready() -> void:
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	max_value = max_potency
	value = current_potency

func _on_collectible_collected() -> void:
	current_potency += 1.0
	value = current_potency
	print("Collected! Current potency:", current_potency)
