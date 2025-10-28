extends Area3D
class_name Sword

@export var damage: int = 10
var can_damage: bool = false

func _ready():
	# Connect signal for hitting bodies
	connect("body_entered", Callable(self, "_on_body_entered"))

func enable_damage():
	can_damage = true

func disable_damage():
	can_damage = false

func _on_body_entered(body: Node3D) -> void:
	if not can_damage:
		return
	var target = body
	while target and not target.has_method("take_damage"):
		target = target.get_parent()
	if target:
		target.take_damage(damage)
