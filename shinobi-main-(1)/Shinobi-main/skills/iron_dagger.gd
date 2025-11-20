extends Button
# Skill ID
@export var skill_id: String = "iron_dagger"
@onready var cancel: Button = $"../Text for upgrades/Iron Dagger/Cancel"
@onready var buy: Button = $"../Text for upgrades/Iron Dagger/Buy"
@onready var label: Label = $"../Text for upgrades/Iron Dagger/Label"
@onready var mesh: MeshInstance2D = $"../Text for upgrades/MeshInstance2D"

var Menu = false
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
	if SkillManager.can_unlock(skill_id) and not Menu:
		mesh.visible = true
		label.visible = true
		buy.visible = true
		cancel.visible = true
		Menu = true

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

func _on_buy_button_down() -> void:
	if SkillManager.can_unlock(skill_id):
		SkillManager.unlock(skill_id) # Unlock the skill
		update_visual() # Update the button color
		buy.visible = false
		cancel.visible = false
		mesh.visible = false
		label.visible = false
		Menu = false

func _on_cancel_button_down() -> void:
	buy.visible = false
	cancel.visible = false
	mesh.visible = false
	label.visible = false
	Menu = false
