extends ProgressBar

# ============== VARIABLES ================
@export var max_potency: float = 6.0 # Max Potency
@export var current_potency: float = 0.0 # Current Potency

signal max_collected # Signal to emit when max potency is met
signal collected # Signal to emit when collecting a collectible

# ============== READY ===============
# Runs when scene is loaded
func _ready() -> void:
	# Wait for a frame to occur
	await get_tree().process_frame
	current_potency = 0 # Set current potency to 0
	rotation_degrees = -45 # Rotate bar 45 degrees
	size = Vector2(101.5, 75.0) # Set size for bar
	show_percentage = false # Turn off percentage
	position = Vector2(5.0, 587.0) # Set position of bar
	# Connect to collectible and scenemanager
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	SceneManager.connect("changed_scene", Callable(self, "_on_changed_scene"))
	max_value = max_potency # Set max value of bar to max potency
	value = current_potency # Set value of bar to current potency
	var bg = StyleBoxFlat.new() # Create a new stylebox
	bg.bg_color = Color(0, 162, 255) # Set color of stylebox
	add_theme_stylebox_override("fill", bg) # Set bar to color

# ========== PHYSICS PROCESS ============
# Runs 60 frames a second
func _physics_process(_delta: float) -> void:
	# If current potency is equal to max, emit max collected
	if current_potency == max_potency:
		max_collected.emit()
		Potency.max_collected.emit()

# =========== COLLECTIBLE =============
# Runs when collectible collected
func _on_collectible_collected() -> void:
	current_potency += 1.0 # Increase current potency
	collected.emit() # Emit signal for collected
	value = current_potency # Set value of bar

# ============ SCENE ===========
# Runs when scene is changed
func _on_changed_scene():
	current_potency = 0.0 # Reset current potency
	value = current_potency # Set value of bar to reflect new potency
