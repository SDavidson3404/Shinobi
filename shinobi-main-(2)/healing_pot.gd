extends Area3D

# ====================
# VARIABLE
# ====================
@export var heal_amount := 25 # Amount to heal

# ====================
# ON BODY ENTERED
# ====================
# Runs when body enters
func _on_body_entered(body):
	# If body is in player group
	if body.is_in_group("player"):
		# Run heal method
		body.heal(heal_amount)
		# Remove healing pot
		queue_free()
