extends Node

signal skills_loaded

# ======= VARIABLES =======
var skills = {} # Create dictionary for skills
var player_points := 0 # Current points
var init := false # Checks if Initialized

func load_skills():
	skills = {
		"dodge": {"unlocked": false, "prereq": [], "cost": 1},
		"double_jump": {"unlocked": false, "prereq": ["dodge"], "cost": 2},
		"wall_run": {"unlocked": false, "prereq": ["double_jump"], "cost": 3},
		"wall_scramble": {"unlocked": false, "prereq": ["wall_run"], "cost": 4},
		"weapon_throw": {"unlocked": false, "prereq": ["wall_scramble"], "cost": 5},
		"spear_unlock": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"dagger_unlock": {"unlocked": false, "prereq": ["spear_unlock"], "cost": 3},
		"burst_mode": {"unlocked": false, "prereq": ["dagger_unlock"], "cost": 4},
		"stamina1": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"stamina2": {"unlocked": false, "prereq": ["stamina1"], "cost": 2},
		"stamina3": {"unlocked": false, "prereq": ["stamina2"], "cost": 3},
		"stamina4": {"unlocked": false, "prereq": ["stamina3"], "cost": 4},
		"stamina5": {"unlocked": false, "prereq": ["stamina4"], "cost": 5},
		"health1": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"health2": {"unlocked": false, "prereq": ["health1"], "cost": 2},
		"health3": {"unlocked": false, "prereq": ["health2"], "cost": 3},
		"health4": {"unlocked": false, "prereq": ["health3"], "cost": 4},
		"health5": {"unlocked": false, "prereq": ["health4"], "cost": 5},
		"dull_dagger": {"unlocked": false, "prereq": ["dagger_unlock"], "cost": 1},
		"sharp_dagger": {"unlocked": false, "prereq": ["dull_dagger"], "cost": 2},
		"iron_dagger": {"unlocked": false, "prereq": ["sharp_dagger"], "cost": 3},
		"gem_dagger": {"unlocked": false, "prereq": ["iron_dagger"], "cost": 4},
		"buster_dagger": {"unlocked": false, "prereq": ["gem_dagger"], "cost": 5},
		"dull_spear": {"unlocked": false, "prereq": ["spear_unlock"], "cost": 1},
		"sharp_spear": {"unlocked": false, "prereq": ["dull_spear"], "cost": 2},
		"steel_spear": {"unlocked": false, "prereq": ["sharp_spear"], "cost": 3},
		"gilded_spear": {"unlocked": false, "prereq": ["steel_spear"], "cost": 4},
		"the_ultima_spear": {"unlocked": false, "prereq": ["gilded_spear"], "cost": 5},
		"dull_sword": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"sharp_sword": {"unlocked": false, "prereq": ["dull_sword"], "cost": 2},
		"forged_sword": {"unlocked": false, "prereq": ["sharp_sword"], "cost": 3},
		"steel_sword": {"unlocked": false, "prereq": ["forged_sword"], "cost": 4},
		"pure_sword": {"unlocked": false, "prereq": ["steel_sword"], "cost": 5},
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
	if player_points < skill["cost"]:
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
		player_points -= skills[id]["cost"] # Decuct points
		save_skills()  # Save the skills

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
	# Load current skills
	load_skills_state()
	# emit skills loaded
	skills_loaded.emit()
	# return whether skill is unlocked or not
	return skills[id]["unlocked"]

# ======= SCENE CHANGED =======
# Function for when scene is changed, load skills
func _on_scene_changed(): load_skills_state()

# =========== SAVE ===========
# Function to save skills
func save_skills():
	# Set save data as variable
	var save_data = {
		"player_points": player_points,
		"save_skills": skills,
	}
	# Set json text as variable
	var json = JSON.stringify(save_data)
	# Save file as variable
	var file = FileAccess.open("user://skills.json", FileAccess.ModeFlags.WRITE)
	# If file valid:
	if file:
		file.store_string(json) # Write save to file
		file.close() # Close file

# ======== LOAD ==========
# Function to load from file
func load_skills_state():
	# Set the skills first
	load_skills()
	# Set file path to variable
	var file_path = "user://skills.json"
	# If file exists
	if FileAccess.file_exists(file_path):
		# Open file to read
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		# If file is valid
		if file:
			# Get text as variable
			var text = file.get_as_text()
			file.close()
			# Write into new JSON as readable format
			var json = JSON.new()
			# If JSON text is valid
			if json.parse(text) == OK:
				# Save data as variable
				var data = json.get_data()
				# Get player points and update current points
				player_points = data.get("player_points", 15)
				# Load skills into variable
				var saved_skills = data.get("save_skills", {})
				# For skill in saved skills:
				for key in saved_skills.keys():
					# If skill is unlocked:
					if skills.has(key):
						# Update skill in dictionary to say is unlocked
						skills[key]["unlocked"] = saved_skills[key]["unlocked"]
	# Emit the skills loaded signal
	skills_loaded.emit()
