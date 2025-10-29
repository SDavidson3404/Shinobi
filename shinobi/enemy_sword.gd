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
			# Ignore self (enemy)
	if body.is_in_group("enemies"):
		return
	var target = body
	while target and not target.has_method("take_damage"):
		target = target.get_parent()
	if target:
		target.take_damage(damage)
