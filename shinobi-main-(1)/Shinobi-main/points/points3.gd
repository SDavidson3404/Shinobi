extends Area3D

# In your collectible's script
@export var collectible_id : String = "3"  # Set in the Inspector

func _ready() -> void:
	if CollectibleManager.collected_items[collectible_id]:
		queue_free()
		
# ====================
# ON BODY ENTERED
# ====================
# Runs when body enters
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# Add point
		SkillManager.player_points += 1
		# Save skills
		SkillManager.save_skills()
		# Remove node
		CollectibleManager.collected_items[collectible_id] = true
		queue_free()
