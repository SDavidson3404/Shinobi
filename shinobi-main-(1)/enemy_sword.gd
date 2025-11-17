extends Area3D
class_name Sword

# ====================
# VARIABLES
# ====================
@export var damage: int = 8 # Damage
var can_damage: bool = false # Checks if can damage

# ====================
# ENABLE DAMAGE
# ====================
# Sets can damage to true
func enable_damage(): can_damage = true

# ====================
# DISABLE DAMAGE
# ====================
# Sets can damage to false
func disable_damage(): can_damage = false

# ====================
# ON BODY ENTERED
# ====================
# Function to run when body enters
func _on_body_entered(body: Node3D) -> void:
	# If cannot damage, do nothing
	if not can_damage:
		return
	# If body is in group enemies, do nothing
	if body.is_in_group("enemies"):
		return
	# If body has method take damage
	if body.has_method("take_damage"):
		# Do method
		body.take_damage(damage)
