extends Area3D
class_name Sword

@export var damage: int = 10
var can_damage: bool = false

func enable_damage():
	can_damage = true

func disable_damage():
	can_damage = false

func _on_body_entered(body: Node3D) -> void:
	if not can_damage:
		return
	if body.is_in_group("enemies"):
		return
	if not body.has_method("take_damage"):
		return
	if body:
		body.take_damage(damage)
