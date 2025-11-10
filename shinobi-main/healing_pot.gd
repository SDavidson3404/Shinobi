extends Area3D

@export var heal_amount := 25

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.heal(heal_amount)
		queue_free()
