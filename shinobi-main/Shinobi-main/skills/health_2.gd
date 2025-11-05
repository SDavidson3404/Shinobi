extends Button
@export var skill_id: String = "health2"

func _ready():
	SkillManager.connect("skills_loaded", Callable(self, "update_visual"))
	update_visual()

func _pressed():
	if SkillManager.can_unlock(skill_id):
		SkillManager.unlock(skill_id)
		update_visual()

func update_visual():
	if SkillManager.skills[skill_id]["unlocked"]:
		modulate = Color(1,1,1)      # Bright for unlocked
	else:
		modulate = Color(0.4,0.4,0.4) # Dim for locked
