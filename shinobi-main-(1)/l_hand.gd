extends Area3D
signal damaged

func _ready() -> void:
	add_to_group("enemies")
	
func take_damage(amount):
	print("hit")
	damaged.emit(amount)
