extends ProgressBar

# ============== VARIABLES ================
@export var max_potency: float = 6.0 # Max Potency
@export var current_potency: float = 0.0 # Current Potency
var emitted = false # Checks if signal is emitted for max collected

signal max_collected # Signal to emit when max potency is met
signal collected # Signal to emit when collecting a collectible

# ============== READY ===============
# Runs when scene is loaded
func _ready() -> void:
	await get_tree().process_frame # Wait for a frame
	custom_minimum_size = Vector2(101.5, 74.5)
	set_pivot_offset(Vector2(0, 0))  # top-left pivot
	# Position of bar relative to screen size
	anchor_left = 0.005
	anchor_top = 0.9
	anchor_right = 0.005
	anchor_bottom = 0.9
	rotation_degrees = -45 # Rotation
	show_percentage = false # No percentage
	current_potency = 0 # Set current potency to zero
	max_value = max_potency # Set max value of bar
	value = current_potency # Set regular value of bar
	# Bar color
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 162, 255)
	add_theme_stylebox_override("fill", bg)
	# Connect signals
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	SceneManager.connect("changed_scene", Callable(self, "_on_changed_scene"))

# =========== COLLECTIBLE =============
# Runs when collectible collected
func _on_collectible_collected() -> void:
	current_potency += 1.0 # Increase current potency
	collected.emit() # Emit signal for collected
	value = current_potency # Set value of bar
	if not emitted: # If not emitted
		# If current potency is more or equal to max potency
		if current_potency >= max_potency:
			# Emit signal
			max_collected.emit()
			Potency.max_collected.emit()
			# Set emitted to true
			emitted = true

# ============ SCENE ===========
# Runs when scene is changed
func _on_changed_scene():
	current_potency = 0.0 # Reset current potency
	value = current_potency # Set value of bar to reflect new potency
	emitted = false # Set emitted to false
