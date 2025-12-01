extends Node

# ======= VARIABLES =======
var skills = {} # Create dictionary for skills
var player_points := 0 # Current points
var init := false # Checks if Initialized

func load_skills():
	skills = {
		"dodge": {"unlocked": false, "prereq": []},
		"double_jump": {"unlocked": false, "prereq": ["dodge"]},
		"wall_run": {"unlocked": false, "prereq": ["double_jump"]},
		"wall_scramble": {"unlocked": false, "prereq": ["wall_run"]},
		"spear_unlock": {"unlocked": false, "prereq": ["wall_scramble"]},
		"dagger_unlock": {"unlocked": false, "prereq": ["spear_unlock"]},
		"burst_mode": {"unlocked": false, "prereq": ["dagger_unlock"]},
		"stamina1": {"unlocked": false, "prereq": ["wall_scramble"]},
		"stamina2": {"unlocked": false, "prereq": ["stamina1"]},
		"stamina3": {"unlocked": false, "prereq": ["stamina2"]},
		"stamina4": {"unlocked": false, "prereq": ["stamina3"]},
		"stamina5": {"unlocked": false, "prereq": ["stamina4"]},
		"health1": {"unlocked": false, "prereq": ["wall_scramble"]},
		"health2": {"unlocked": false, "prereq": ["health1"]},
		"health3": {"unlocked": false, "prereq": ["health2"]},
		"health4": {"unlocked": false, "prereq": ["health3"],},
		"health5": {"unlocked": false, "prereq": ["health4"]},
		"dull_dagger": {"unlocked": false, "prereq": ["dagger_unlock"]},
		"sharp_dagger": {"unlocked": false, "prereq": ["dull_dagger"]},
		"iron_dagger": {"unlocked": false, "prereq": ["sharp_dagger"]},
		"gem_dagger": {"unlocked": false, "prereq": ["iron_dagger"]},
		"buster_dagger": {"unlocked": false, "prereq": ["gem_dagger"]},
		"dull_spear": {"unlocked": false, "prereq": ["spear_unlock"]},
		"sharp_spear": {"unlocked": false, "prereq": ["dull_spear"]},
		"steel_spear": {"unlocked": false, "prereq": ["sharp_spear"]},
		"gilded_spear": {"unlocked": false, "prereq": ["steel_spear"]},
		"the_ultima_spear": {"unlocked": false, "prereq": ["gilded_spear"]},
		"dull_sword": {"unlocked": false, "prereq": ["wall_scramble"]},
		"sharp_sword": {"unlocked": false, "prereq": ["dull_sword"]},
		"forged_sword": {"unlocked": false, "prereq": ["sharp_sword"]},
		"steel_sword": {"unlocked": false, "prereq": ["forged_sword"]},
		"pure_sword": {"unlocked": false, "prereq": ["steel_sword"]},
	}

# ========= CAN UNLOCK? =========
# Function checks if skill CAN be unlocked
func can_unlock(id: String) -> bool:
	# Create variable to store skill by id
	var skill = skills[id]
	# If skill is unlocked, return NO
	if skill["unlocked"]:
		return false
	# If player doesn't have enough points, return NO
	if player_points < 1:
		return false
	# For skills needed to unlock:
	for pre in skill["prereq"]:
		# If skill not in unlocked, return NO
		if not skills[pre]["unlocked"]:
			return false
	# If none of checks come back, then return TRUE
	return true

# ======== UNLOCK ========
# Function to unlock spell
func unlock(id: String):
	if can_unlock(id): # If you can unlock it
		skills[id]["unlocked"] = true # Set unlocked to true
		player_points -= 1

# ======== READY ==========
func _ready():
	# If initialized, do nothing
	if init:
		return
	init = true # Set initialized to true
	# If not connected, connect to scene manager to get changed scene signal
	if not SceneManager.is_connected("changed_scene", Callable(self, "_on_scene_changed")):
		SceneManager.connect("changed_scene", Callable(self, "_on_scene_changed"))

# ======== CHECK =========
# Function to check if skill is unlocked
func check_unlocked(id: String) -> bool:
	# If skill not in skills list, return no
	if not skills.has(id):
		return false
	# return whether skill is unlocked or not
	return skills[id]["unlocked"]

# ======= SCENE CHANGED =======
# Function for when scene is changed, load skills
func _on_scene_changed(): load_skills()
