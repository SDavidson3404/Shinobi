extends Node

@onready var lines: Node2D = $lines

# ======= PHYSICS PROCESS =======
# Runs 60 frames per second
func _physics_process(_delta: float) -> void: update_visual()
			
# ========= PRESSED =========
# Function runs when pressed
func _pressed(skill_id):
	if SkillManager.can_unlock(skill_id):
		SkillManager.unlock(skill_id) # Unlock the skill
		update_visual() # Update the button color

# ========= UPDATE VISUALS ==========
# Update the color of the button
func update_visual():
	if lines != null:
		for child in lines.get_children():
			if child is Button:
				# If unlocked, make it white
				if SkillManager.skills[child.name]["unlocked"]: child.modulate = Color(1,1,1)
				# Else, if you can unlock the skill, make blue
				elif SkillManager.can_unlock(child.name): child.modulate = Color(0.0, 0.776, 1.026, 1.0)
				# Else, make it grey
				else: child.modulate = Color(0.4,0.4,0.4) # Dim for locked
