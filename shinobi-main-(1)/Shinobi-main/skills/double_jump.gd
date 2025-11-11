extends Button
# Skill ID
@export var skill_id: String = "double_jump"

# ======= READY =======
# Runs on scene loading
func _ready(): SkillManager.connect("skills_loaded", Callable(self, "update_visual"))

# ======= PHYSICS PROCESS =======
# Runs 60 frames per second
func _physics_process(_delta: float) -> void: update_visual()

# ========= PRESSED =========
# Function runs when pressed
func _pressed():
	# If you can unlock it:
	if SkillManager.can_unlock(skill_id):
		SkillManager.unlock(skill_id) # Unlock the skill
		update_visual() # Update the button color

# ========= UPDATE VISUALS ==========
# Update the color of the button
func update_visual():
	# If unlocked, make it white
	if SkillManager.skills[skill_id]["unlocked"]:
		modulate = Color(1,1,1)
	# Else, if you can unlock the skill, make purple
	elif SkillManager.can_unlock(skill_id):
		modulate = Color(255, 0, 9)
	# Else, make it grey
	else:
		modulate = Color(0.4,0.4,0.4) # Dim for locked
